# Brief

## User Request

根据新的 v0.2 计划开始开发 Android Demo v0.2。

## Goal

实现 v0.2 的第一个可交付切片 M1：稳定单播放器产品壳层，为后续 Feed、连击和手势施法打基础。

## Scope

- 关闭 Android Impeller 作为真机黑屏低风险 A/B 修复项。
- 增加播放器生命周期处理和视频初始化错误日志。
- 增加右侧短剧操作栏。
- 增加情绪温度计和同屏人数数据感 overlay。
- 增加 widget test 覆盖 v0.2 壳层。
- 纳入 v0.2 计划文档和手势模型训练笔记。

## Out Of Scope

- 不在本切片实现竖滑 Feed。
- 不在本切片实现多指连击。
- 不在本切片实现 TFLite / dot-pattern 施法。
- 不引入真实后端、远程视频或新素材。

## Constraints

- 真机当前未连接，主测设备黑屏修复只能完成 APK 侧改动和模拟器/构建验证。
- 不泄露任何 API key、token 或私有配置。
