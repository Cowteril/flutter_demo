# Evidence

## Dependency

`flutter pub add tflite_flutter:^0.12.1` succeeded after Windows Developer Mode was enabled.

Added packages:

- `tflite_flutter 0.12.1`
- `ffi 2.2.0`
- `quiver 3.2.2`

## Package API

Local pub cache inspection confirms:

- `Interpreter.fromAsset(String assetName)` loads a model from Flutter assets.
- `Interpreter.run(input, output)` supports single-input/single-output inference.
- `getInputTensor(0)` and `getOutputTensor(0)` expose shape, type, and quantization params.

## Build Issue

Initial Android build failed:

- `:tflite_flutter:compileDebugKotlin`
- Java task target: 11
- Kotlin task target: 17

Resolution:

- Align app and Android library subproject Java/Kotlin targets to JVM 11, matching `tflite_flutter`'s Android plugin.

## Test Environment Note

Windows widget tests cannot load `libtensorflowlite_c-win.dll` from Flutter engine artifacts. The classifier catches that error and falls back to heuristic recognition; tests pass.
