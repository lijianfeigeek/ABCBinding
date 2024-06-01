#!/bin/sh

xcodebuild clean build -target ABCBinding -configuration Release
# rm -r ./lib
# cp -r ./build/Release-iphoneos/ ./lib
# rm -r ./build
