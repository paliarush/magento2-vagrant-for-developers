#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    echo "OSX"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Linux"
elif [ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]; then
    echo "Windows"
elif [ "$(expr substr $(uname -s) 1 6)" == "CYGWIN" ]; then
    echo "Windows"
else
    echo "Unknown host OS"
    exit 255
fi