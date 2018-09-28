#!/usr/bin/env nix-shell
#! nix-shell -i bash

ghc -c -O SimpleHsFromC.hs

ghc --make -no-hs-main -optc-O main.c SimpleHsFromC -o SimpleHsFromC

./SimpleHsFromC
