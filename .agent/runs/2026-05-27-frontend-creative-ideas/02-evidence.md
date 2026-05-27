# Evidence

## Project Context

- 当前客户端是 Flutter 项目，入口在 `client/lib/main.dart`。
- `client/lib/app/duanju_app.dart` 使用 `MockDramaRepository` 并进入 `DramaListPage`。
- `DramaListPage` 已有短剧列表卡片和进入播放页的导航。
- `DramaPlayerPage` 已有模拟播放器、播放暂停、拖动进度、高光时间线和互动弹层。
- `InteractionOverlay` 已有高光选项按钮和关闭能力。

## Discussion Inputs

- 用户希望先讨论前端创意，不处理后端功能。
- 已讨论“像抖音 APP 一样炫酷”的动效方向。
- 已讨论讨厌角色投掷鸡蛋、番茄、便便贴纸等恶搞道具。
- 已讨论通过角色轨迹、矩形框或 mask 让道具精准命中角色。

## Source Files Referenced

- `client/lib/app/duanju_app.dart`
- `client/lib/features/drama/presentation/drama_list_page.dart`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/interaction_overlay.dart`
- `client/lib/features/drama/data/mock_drama_repository.dart`
