#!/usr/bin/env bash

cd example
flutter -v build apk --enable-experiment=non-nullable --no-sound-null-safety
cd ..