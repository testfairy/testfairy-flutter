#!/usr/bin/env bash

set -ex

# prepare
#yes | gem uninstall --all cocoapods
#gem install -n /usr/local/bin cocoapods -v 1.10.1
#alias pod="pod _1.10.1_"
pod --version

# build
cd example
flutter -v build ios --no-codesign > /dev/null
cd ../example-dart1
# We don't actually want to redirect stdout to /dev/null but CI complains due to length of the build logs
flutter -v build ios --no-codesign > /dev/null
cd ..

# lint
flutter analyze $PWD/lib
#flutter analyze $PWD/example/lib
#flutter analyze $PWD/example/test
#flutter analyze $PWD/example/test_driver
#flutter analyze $PWD/example-dart1/lib
#flutter analyze $PWD/example-dart1/test
#flutter analyze $PWD/example-dart1/test_driver

