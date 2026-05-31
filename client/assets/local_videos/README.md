# Local Videos

Put local short-drama video assets here for development builds only.

The video files in this folder are intentionally ignored by Git and must not be pushed to the public repository.

Expected layout:

```text
assets/local_videos/drama01_ep001.mp4
assets/local_videos/catalog.json
```

Use `scripts/sync-local-videos.ps1` from the repository root to copy a small
local demo set from `videos/`.

The script writes flat video filenames so Flutter can bundle them from the
single `assets/local_videos/` asset directory. `catalog.json` keeps local titles
and episode numbers for the demo build; it is local-only and ignored by Git.

By default the script chooses the smallest episode file in each drama folder to
keep debug APK size manageable. Pass `-SelectionMode EpisodeOrder` if the demo
needs the earliest episodes instead.
