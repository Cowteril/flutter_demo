# 手势识别模型训练笔记

本文档记录 v0.2 §5.6 / §6.2 中 TFLite + Quick Draw 手势分类器的训练流水线、关键决策与风险点。

App 端集成只依赖 `GestureClassifier` 抽象接口，本流水线产出的 `gesture_classifier.tflite` 是其中一种实现，可与 `StubGestureClassifier` / 开源预训练模型在 DI 层平等替换。

## 1. 任务定义

- **输入**：用户在施法画布上画的笔画序列，渲染为 64×64 单通道灰度图
- **输出**：5 类分类标签 + 置信度
  - `lightning` → 雷击
  - `fire` → 火焰
  - `sword` → 突进
  - `snowflake` → 冰封
  - `star` → 治愈
- **指标目标**：离线测试集 top-1 ≥ 92%，主测设备真机 top-1 ≥ 80%，端侧推理延迟 < 100ms，模型体积 < 5MB

## 2. 数据获取

Quick, Draw! 数据集三种格式：

| 格式 | 内容 | 用途 |
| --- | --- | --- |
| `npy bitmap` | 已渲染 28×28 灰度图 npy 打包 | 不推荐——升采样到 64×64 引入插值伪影 |
| `simplified ndjson` | 笔画 RDP 简化、缩放到 256×256 | **本项目使用**——自渲到 64×64，训练-推理分布对齐 |
| `raw ndjson` | 原始笔画 + 时间戳 + 国别 + recognized | 不需要 |

下载源：`gs://quickdraw_dataset/full/simplified/` 或 GitHub 镜像。每类约 100-150MB，5 类共约 500MB-1GB。

**关键决策：自渲 ndjson 而非用预制 npy bitmap**

理由：训练数据与推理数据的渲染函数必须完全一致。多写一个 `strokes_to_bitmap()` 是后续 Stub→TFLite swap 不翻车的关键。

## 3. 数据预处理

Quick, Draw! stroke 格式：`[[x1, x2, ...], [y1, y2, ...], [t1, t2, ...]]`，每个笔画一组。

```python
def strokes_to_bitmap(strokes, size=64, line_width=2):
    xs = [x for s in strokes for x in s[0]]
    ys = [y for s in strokes for y in s[1]]
    bbox_w = max(xs) - min(xs)
    bbox_h = max(ys) - min(ys)
    bbox_cx = (max(xs) + min(xs)) / 2
    bbox_cy = (max(ys) + min(ys)) / 2

    # 保持长宽比缩放，留 20% padding
    scale = (size * 0.8) / max(bbox_w, bbox_h)
    offset_x = size / 2 - bbox_cx * scale
    offset_y = size / 2 - bbox_cy * scale

    img = PIL.Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(img)
    for stroke in strokes:
        points = [(x * scale + offset_x, y * scale + offset_y)
                  for x, y in zip(stroke[0], stroke[1])]
        draw.line(points, fill=255, width=line_width)
    return np.array(img) / 255.0
```

**容易踩的点**：

- **笔画粗细 normalize**：训练样本统一笔宽（建议 2px@64×64）。用户真机画笔粗细不一，推理前必须用同一个 `strokes_to_bitmap()` 渲染
- **bbox padding**：留 10-20% 边距，防止训练样本贴边而推理 bbox 小时缩放后过粗
- **数据增强**：随机旋转 ±10°、随机缩放 0.9-1.1、随机平移 ±2px
- **不要镜像增强**：雷击 Z 字镜像后是反 Z，可能与 `sword` 混淆

## 4. 模型架构

两个候选：

### 选项 A：MobileNetV2 + transfer learning

```python
base = tf.keras.applications.MobileNetV2(
    input_shape=(64, 64, 3),
    include_top=False,
    weights='imagenet',
    alpha=0.35,  # 最小宽度乘数，模型 ~2MB
)
base.trainable = False

model = tf.keras.Sequential([
    layers.Lambda(lambda x: tf.image.grayscale_to_rgb(x)),
    base,
    layers.GlobalAveragePooling2D(),
    layers.Dropout(0.3),
    layers.Dense(5, activation='softmax'),
])
```

两阶段训练：冻结 backbone 先训分类头，再解冻最后 50 层 fine-tune（LR 1e-5）。

### 选项 B：从零训轻量 CNN（推荐）

```python
model = tf.keras.Sequential([
    layers.Conv2D(32, 3, activation='relu', input_shape=(64, 64, 1)),
    layers.MaxPool2D(),
    layers.Conv2D(64, 3, activation='relu'),
    layers.MaxPool2D(),
    layers.Conv2D(128, 3, activation='relu'),
    layers.GlobalAveragePooling2D(),
    layers.Dense(64, activation='relu'),
    layers.Dropout(0.3),
    layers.Dense(5, activation='softmax'),
])
```

参数量 ~100K，量化后 < 500KB。

**选 B 的理由**：

- 5 类分类对 ImageNet 预训练特征依赖度低（涂鸦与真实照片域差异巨大）
- MobileNetV2 在 64×64 单通道涂鸦上 overkill
- 答辩可讲"针对任务规模做了 NAS 直觉决策，不盲目套大模型"
- 包体显著更小

## 5. 训练配置

```python
# 每类抽 50K 样本（Quick Draw 每类 10-15 万，无需全用）
# 5 类 × 50K = 25 万样本
# 8:1:1 split → 20 万训练 / 2.5 万验证 / 2.5 万测试

optimizer = tf.keras.optimizers.Adam(learning_rate=1e-3)
loss = 'sparse_categorical_crossentropy'
metrics = ['accuracy']

callbacks = [
    tf.keras.callbacks.EarlyStopping(patience=5, restore_best_weights=True),
    tf.keras.callbacks.ReduceLROnPlateau(factor=0.5, patience=2),
]

model.fit(train_ds, validation_data=val_ds, epochs=30, callbacks=callbacks)
```

- **Batch size**：轻量 CNN 用 256，MobileNet 用 64
- **算力**：Colab 免费 T4 即可，无需本地 GPU
- **预期收敛**：5 类 Quick Draw 子集，轻量 CNN 验证集 top-1 通常 92-96%
- **不达标排查**：top-1 < 88% 时先查数据增强是否过强、类别样本是否严重不均

## 6. 量化与 TFLite 导出

### 路径 A：训练后量化 PTQ（推荐起手）

```python
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]

def representative_dataset():
    for batch in val_ds.take(100):
        yield [tf.cast(batch[0], tf.float32)]

converter.representative_dataset = representative_dataset
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8

tflite_model = converter.convert()
with open('gesture_classifier.tflite', 'wb') as f:
    f.write(tflite_model)
```

PTQ 通常掉点 1-3%（top-1 96% → 93-95%），可接受。

### 路径 B：量化感知训练 QAT

PTQ 掉点严重才上。`tfmot.quantization.keras.quantize_model(model)` 包一层重训，掉点通常 < 0.5%，训练时间约翻倍。

**起手 PTQ，掉点可接受就锁定**。

## 7. 评估

### 离线评估

- 测试集 2.5 万样本 top-1 准确率
- 按类别看混淆矩阵，重点关注 `lightning`/`sword`（都偏直线）混淆率

### 真机评估

- 自己手机画 50-100 个样本（每类 10-20 个），过 TFLite 推理
- 通常比离线测试集低 5-15%，原因：
  - 触屏笔画粗细分布偏差
  - 用户画图速度比训练样本快
  - 屏幕坐标系与训练 bbox 居中策略偏差

**真机准确率 < 80% 的处理顺序**：

1. 检查渲染流水线是否真的与训练一致（笔宽、padding、归一化）
2. 在真机样本上做置信度分布分析，调 §5.6 的 `[0.7, 0.4]` 阈值
3. 必要时加触屏风格增强重训

### 延迟评估

TFLite Benchmark Tool 在主测设备跑 `gesture_classifier.tflite`，看 `inference_avg`。轻量 CNN + int8 在中端机通常 5-30ms，远低于 100ms 目标。

## 8. 项目特有的风险点

| 风险 | 说明 | 处理 |
| --- | --- | --- |
| 训练-推理分布漂移 | 训练样本是 PC 鼠标画的，推理是手指触屏画的 | 训练加触屏风格增强：笔宽随机化、轻微抖动、起笔/收笔淡化 |
| 类别样本不均 | Quick Draw 每类样本量不等，`snowflake` 偏少 | 每类强制采样到 50K，少数类做更多增强 |
| 单笔 vs 多笔行为差异 | `fire` 可能 3-5 笔，`sword` 通常 1-2 笔 | 验证集前看笔画数分布，模型自然会学到 |
| 抬笔判定 | Flutter `PanGestureRecognizer` 无天然抬笔事件 | 推理时机：超过 800ms 无新触摸点 trigger 分类，不强制用户主动 submit |
| 类名映射 | Quick Draw 类名是英文 | 模型输出 label index，应用层一张映射表，Stub/TFLite 共用 |

## 9. 与 Stub 实现的对齐

`StubGestureClassifier`（v0.2 plan §6.2）使用三个启发式特征：宽高比、笔画断点数、是否 Z 字。训练后的真实模型应在测试集上验证这三个特征在模型 attention 中确有体现，确保 swap 后置信度分布与 Stub 不发生戏剧性偏移（避免 §5.6 阈值需要重新校准）。

可选做法：训练完用 Grad-CAM 看 `lightning` / `fire` / `sword` 三类的 attention 区域，确认模型抓的是直线段 / 多笔簇 / Z 字转折，而不是数据集偏差（背景噪声、签名水印等）。

## 10. 配套开源资源

- **Google 官方教程**：`tensorflow.org/datasets/catalog/quickdraw_bitmap`，可 `tfds.load('quickdraw_bitmap')`
- **预训练社区模型**：GitHub 搜 `quickdraw tflite`，有若干 345 类模型，可裁剪输出层到 5 类
- **数据可视化**：`quickdraw.withgoogle.com/data` 预览每类真实涂鸦风格

## 11. 总结

主线：`simplified ndjson → 自渲 64×64 → 轻量 CNN → PTQ int8 → TFLite`。

目标：离线 top-1 ≥ 92%、真机 ≥ 80%、推理 < 50ms、模型 < 5MB。

集成原则：Stub 接口先锁，训练独立并行做，导出后一行 DI swap。
