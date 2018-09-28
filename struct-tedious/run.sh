#!/usr/bin/env nix-shell
#! nix-shell -i bash

gcc -pedantic -std=c11 -Wall -Werror \
  -o print_struct_storable \
  print_struct_storable.c

cat MyStructFragment.hs > MyStruct.hs

./print_struct_storable >> MyStruct.hs

ghc -Wall -O2 -c MyStruct.hs
ghc --make -Wall -O2 -no-hs-main -optc -O2 main.c MyStruct -o MyStruct

./MyStruct
