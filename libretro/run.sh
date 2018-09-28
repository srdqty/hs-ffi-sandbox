#!/usr/bin/env nix-shell
#! nix-shell -i bash

#c2hs Libretro.chs libretro.h

hsc2hs Libretro.hsc

#gcc -c -Wall -pedantic hs_libretro.c -I/nix/store/x6xqg5qn55vbdafg2kvgp3zgnha8z0bz-ghc-8.4.3-with-packages/lib/ghc-8.4.3/include

ghc -c hs_libretro.c Libretro.hs
