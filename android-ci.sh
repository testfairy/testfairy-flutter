#!/usr/bin/env bash

set -ex

# prepare
yes | sdkmanager "platforms;android-28"
yes | sdkmanager "platforms;android-29"
wget https://services.gradle.org/distributions/gradle-3.5-bin.zip
unzip -qq gradle-3.5-bin.zip
export GRADLE_HOME=$PWD/gradle-3.5
export PATH=$GRADLE_HOME/bin:$PATH
cd ..
git clone https://github.com/flutter/flutter.git -b dev --depth 1
cd testfairy-flutter

# build
cd example
../../flutter/bin/flutter -v build apk
cd ../example-dart1
../../flutter/bin/flutter -v build apk
cd ..

# lint
../flutter/bin/flutter analyze $PWD/lib
#../flutter/bin/flutter analyze $PWD/example/lib
#../flutter/bin/flutter analyze $PWD/example/test
#../flutter/bin/flutter analyze $PWD/example/test_driver
#../flutter/bin/flutter analyze $PWD/example-dart1/lib
#../flutter/bin/flutter analyze $PWD/example-dart1/test
#../flutter/bin/flutter analyze $PWD/example-dart1/test_driver