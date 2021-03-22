#!/usr/bin/env bash

cd example
flutter -v build apk
cd ..

cd example-dart1
flutter -v build apk
cd ..
