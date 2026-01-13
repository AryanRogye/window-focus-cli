#!/bin/bash

set -e

BIN=./build/Build/Products/Release/TestingAX_SkyLight

if [ ! -x "$BIN" ] || find TestingAX_SkyLight -newer "$BIN" | grep -q .; then
  xcodebuild \
    -project TestingAX_SkyLight.xcodeproj \
    -scheme TestingAX_SkyLight \
    -configuration Release \
    -derivedDataPath ./build
fi

"$BIN"
