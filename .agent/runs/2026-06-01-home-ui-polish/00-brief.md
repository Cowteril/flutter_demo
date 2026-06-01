# Brief

## User Request

The user shared a screenshot of the new homepage. The visible issue is that unselected filter chips render as light/white blocks with white text, making them unreadable. The page also benefits from a clearer section boundary before the full drama list.

## Goal

Polish the home page UI without changing homepage behavior:

- Fix filter chip contrast in selected and unselected states.
- Keep the search and vertical-feed entry working.
- Add clearer structure between featured recommendations and the full drama list.

## Scope

- `client/lib/features/home/presentation/drama_home_page.dart`
- Verification artifacts under this run directory.

## Out Of Scope

- Backend search changes.
- Real poster artwork.
- Navigation or feed behavior rewrites.
