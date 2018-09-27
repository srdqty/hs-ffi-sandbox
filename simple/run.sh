#!/usr/bin/env nix-shell
#! nix-shell -i bash

ghc -O --make SimpleFFI.hs

./SimpleFFI
