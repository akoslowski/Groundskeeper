#!/bin/sh

swift build -c release
cp .build/release/playground /usr/local/bin/playground
