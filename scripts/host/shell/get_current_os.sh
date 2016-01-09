#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    echo "OSX"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Linux"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    echo "Windows"
fi