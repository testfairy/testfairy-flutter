#!/usr/bin/env bash

set -ex

# prepare
#yes | gem uninstall --all cocoapods
#gem install -n /usr/local/bin cocoapods -v 1.10.1
#alias pod="pod _1.10.1_"
pod --version
pip install six
brew update || true
brew install libimobiledevice ideviceinstaller ios-deploy
cd ..
git clone https://github.com/flutter/flutter.git -b dev --depth 1
cd testfairy-flutter

# build
cd example
../../flutter/bin/flutter -v build ios --no-codesign
cd ../example-dart1
../../flutter/bin/flutter -v build ios --no-codesign
cd ..


# lint
../flutter/bin/flutter analyze $PWD/lib
#../flutter/bin/flutter analyze $PWD/example/lib
#../flutter/bin/flutter analyze $PWD/example/test
#../flutter/bin/flutter analyze $PWD/example/test_driver
#../flutter/bin/flutter analyze $PWD/example-dart1/lib
#../flutter/bin/flutter analyze $PWD/example-dart1/test
#../flutter/bin/flutter analyze $PWD/example-dart1/test_driver

