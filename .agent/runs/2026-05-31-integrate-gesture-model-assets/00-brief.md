# Brief

## Request

The gesture classifier export is ready under `client/20260531-034301`; move the files into the project.

## Scope

- Put runtime model files in the Flutter asset tree.
- Preserve training/export evidence outside the APK asset tree.
- Configure Flutter assets so the model can be bundled.
- Add a lightweight verification test for model and label asset loading.

## Constraints

- Do not leak API keys, tokens, or private credentials.
- Do not force GitHub upload if network is blocked.
- Keep inference integration separate unless explicitly implemented in this slice.
