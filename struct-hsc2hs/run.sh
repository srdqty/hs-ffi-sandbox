#!/usr/bin/env nix-shell
#! nix-shell -i bash

hsc2hs MyStruct.hsc

ghc -Wall -O2 -c MyStruct.hs
ghc --make -Wall -O2 -no-hs-main -optc -O2 main.c MyStruct -o MyStruct

./MyStruct
