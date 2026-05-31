# Evidence

## Current State

- The model assets already exist under `client/assets/models/`.
- No UI entry point or gesture overlay existed before this slice.
- `SideActionBar` had follow, like, comment, share, and episode actions, but no casting action.

## Dependency Check

Attempted to add `tflite_flutter:^0.12.1`.

Result:

- Package resolution downloaded `tflite_flutter 0.12.1`, `ffi 2.2.0`, and `quiver 3.2.2`.
- Flutter then failed with: `Building with plugins requires symlink support. Please enable Developer Mode in your system settings.`

Decision:

- Do not keep the partially added dependency in this slice.
- Implement a heuristic classifier and dot-pattern fallback so the device demo has a working gesture path now.
- Revisit TFLite integration after Windows Developer Mode is enabled.

## Safety Check

Scoped credential scan found no private-key or token-shaped content in changed app files.
