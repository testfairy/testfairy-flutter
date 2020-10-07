#!/usr/bin/env bash

cd example
flutter drive --enable-experiment=non-nullable --no-sound-null-safety -v --target=test_driver/app.dart
cd ..