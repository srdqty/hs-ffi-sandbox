#!/usr/bin/env nix-shell
#! nix-shell -i bash

hsc2hs Regex.hsc

ghc -O2 -Wall Regex.hs `pkg-config libpcre --libs`

./Regex
