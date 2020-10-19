#!/usr/bin/env bash

cd example
flutter -v build ios --simulator --no-codesign --enable-experiment=non-nullable --no-sound-null-safety
cd ..