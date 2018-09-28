# simple-hs-from-c

```
./run.sh
```

Simple example of calling Haskell code from C.

See: https://wiki.haskell.org/Calling_Haskell_from_C

Note that the `hs_add_root` and `__stginit_` stuff is not necessary in recent versions
of GHC (and will cause linker errors): https://ghc.haskell.org/trac/ghc/ticket/3252
