#!/usr/bin/env bash

set -e
set -x

# prepare
yes | gem uninstall --all cocoapods
gem install -n /usr/local/bin cocoapods -v 1.9.0
alias pod="pod _1.9.0_"
pod --version
pip install six
brew update || true
brew install libimobiledevice ideviceinstaller ios-deploy
cd ..
git clone https://github.com/flutter/flutter.git -b dev --depth 1
cd testfairy-flutter

# build
cd example
../../flutter/bin/flutter -v build ios --simulator --no-codesign || echo Failing on purpose
mv ios/Podfile ios/_podfile
echo "use_frameworks!" > ios/Podfile
cat ios/_podfile >> ios/Podfile
cat ios/Podfile
rm ios/_podfile
pod --version
pod repo update
cd ios
pod install
cd ..
../../flutter/bin/flutter -v build ios --simulator --no-codesign --enable-experiment=non-nullable --no-sound-null-safety
cd ..

# lint
../flutter/bin/flutter analyze $PWD/lib
#../flutter/bin/flutter analyze $PWD/example/lib
#../flutter/bin/flutter analyze $PWD/example/test
#../flutter/bin/flutter analyze $PWD/example/test_driver
#../flutter/bin/flutter analyze $PWD/example/integration_test
