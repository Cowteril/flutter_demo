# Evidence

## Source Export

Source directory:

- `client/20260531-034301/`

Files found:

- `gesture_classifier.keras` - 1,262,317 bytes
- `gesture_classifier.tflite` - 112,616 bytes
- `gesture_classifier_float32.tflite` - 409,512 bytes
- `gesture_classifier_int8.tflite` - 112,616 bytes
- `labels.json` - 89 bytes
- `metrics.json` - 613 bytes
- `confusion_matrix.csv` - 176 bytes
- `training_log.csv` - 2,597 bytes

## Metrics

From `metrics.json`:

- Classes: `lightning`, `fire`, `sword`, `snowflake`, `star`.
- Samples per class: 50,000.
- Total samples: 250,000.
- Test accuracy: 0.96484.
- Int8 TFLite evaluation accuracy: 0.9641 on 10,000 samples.
- Int8 TFLite size: 112,616 bytes.

## Safety Check

No credential-shaped content was found in the moved runtime or documentation files during review.
