# Plan

## Goal

创建一个可维护的前端创意清单，记录当前 Flutter 客户端已有基础、已讨论创意、MVP 范围、前端分层、数据需求和后续扩展点。

## Non-goals

- 不新增或修改 Flutter 功能代码。
- 不引入依赖。
- 不编写后端或 AI 识别逻辑。

## Assumptions

- 创意清单主要面向后续产品讨论和前端实现拆解。
- YAML 比纯 Markdown 更适合作为可扩展的中间格式。
- 当前阶段允许使用 mock 数据和比例坐标描述复杂互动。

## Tasks

- 新增 `docs/frontend_creative_ideas.yaml`。
- 记录当前已有前端基础。
- 记录已讨论的抖音式动效、剧情高光、投掷角色、角色追踪等创意。
- 为每个创意补充 MVP 范围、前端层、数据需求、扩展点和验收信号。
- 执行文档检查。

## Role Split

- Supervisor: 当前对话直接执行并维护 run artifacts。
- Planner: 小型文档任务，未单独派生 agent；计划写入本文件。
- Researcher: 未单独派生 agent；依据已读取的 Flutter 项目结构和当前讨论内容。
- Coder: 小型文档任务，直接新增文档。
- Reviewer: 由 Supervisor 对最终文件做结构和范围检查。
- Tester: 由 Supervisor 执行可复现的文件存在性和内容检查。

## Acceptance Criteria

- AC-001: 项目目录下存在结构化创意清单文件。
- AC-002: 创意清单包含当前项目已有前端基础，便于和后续创意对应。
- AC-003: 创意清单至少覆盖沉浸式竖滑、双击爱心、剧情高光、情绪粒子、剧情分支、向讨厌角色投掷、角色追踪命中等已讨论创意。
- AC-004: 每个创意包含稳定 id、状态、优先级、MVP 范围、前端层、数据需求和扩展点。
- AC-005: 本次变更不修改 Flutter 功能代码。

## Risks

- YAML 仅作为人工维护文档，当前没有项目内 schema 校验。
- 部分创意需要真实视频、素材或 AI 离线分析才能达到最终产品效果。

## Open Questions

- 后续是否要把该 YAML 直接作为前端 mock 配置读取。
- 投掷道具的视觉风格需要偏卡通、恶搞还是更游戏化。
