# Implementation

## Changed Files

- `client/lib/features/home/presentation/drama_home_page.dart`

## Summary

- Added `_SectionHeader` for `全部短剧` / `搜索结果` with a visible count.
- Reduced the list top padding so the new header reads as part of the list section.
- Reworked `_FilterBar` chip color resolution:
  - Selected: cyan background with dark text.
  - Pressed: dark blue-gray background.
  - Default: dark background with light text.
- Added explicit chip border, shape, tint, padding, and compact tap target to avoid unreadable Material theme fallback.
