#!/usr/bin/env bash

cd example
flutter -v build ios --simulator --no-codesign
cd ..


cd example-dart1
flutter -v build ios --simulator --no-codesign
cd ..
