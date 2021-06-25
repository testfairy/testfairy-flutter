#!/usr/bin/env bash

set -ex

# build
cd example
flutter -v build apk > /dev/null
cd ../example-dart1
flutter -v build apk
cd ..

# lint
flutter analyze $PWD/lib
#flutter analyze $PWD/example/lib
#flutter analyze $PWD/example/test
#flutter analyze $PWD/example/test_driver
#flutter analyze $PWD/example-dart1/lib
#flutter analyze $PWD/example-dart1/test
#flutter analyze $PWD/example-dart1/test_driver