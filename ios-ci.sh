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
../../flutter/bin/flutter -v build ios --no-codesign || echo Failing on purpose to validate that null safity is mandatory
../../flutter/bin/flutter -v build ios --enable-experiment=non-nullable --no-sound-null-safety --no-codesign --profile
cd ..

# lint
../flutter/bin/flutter analyze $PWD/lib
#../flutter/bin/flutter analyze $PWD/example/lib
#../flutter/bin/flutter analyze $PWD/example/test
#../flutter/bin/flutter analyze $PWD/example/test_driver


