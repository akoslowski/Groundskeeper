#!/bin/sh

echo "Testing..."
if ! swift test; then
    echo "Test failed. :-|"
    exit
fi

echo "Compiling playground..."
if swift build -c release; then
    echo "Copying playground to /usr/local/bin/playground"
    cp .build/release/playground /usr/local/bin/playground
fi
