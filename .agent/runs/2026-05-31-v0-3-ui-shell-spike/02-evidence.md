# Evidence

| Claim | Evidence | Source | Confidence | Impact | Follow-up |
| --- | --- | --- | --- | --- | --- |
| A vertical short-video feed is a suitable v0.3 shell. | `FlutterWiz/flutter_video_feed` implements a TikTok/Reels/Shorts-style vertical feed and LRU player caching. | `.agent/runs/2026-05-31-open-source-short-video-ui-research/02-evidence.md` | High | Reuse the feed architecture, not the whole app. | Add a vertical `PageView` around the existing player. |
| Importing the full reference app would add unrelated coupling. | The selected reference includes its own architecture and service assumptions, while the current demo already has player overlays, effects, and TFLite gesture casting. | Local code inspection and research verdict | High | Keep the integration small and preserve current behavior. | Adapt only the feed-shell pattern. |
| Local demo videos must stay off the remote repository. | User explicitly requested that copyrighted short-drama files are not uploaded publicly. | User requirement | High | Ignore source media and copied Flutter asset media. | Verify `git check-ignore` and `git ls-files`. |
| Backend integration is deferred, but the data-source boundary should remain replaceable. | User clarified that production uses frontend plus backend; the current demo can use videos directly. | User requirement | High | Keep local asset discovery separate from feed UI. | Replace `LocalVideoAssetCatalog` with an API-backed source later. |
