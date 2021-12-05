#!/bin/sh

echo "Compiling playground..."
if swift build -c release; then
    echo "Copying playground to /usr/local/bin/playground"
    cp .build/release/playground /usr/local/bin/playground
fi
