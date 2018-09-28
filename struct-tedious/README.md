# struct

This is an example of working with a C struct via the Storable type class in
Haskell. It also demonstrates creating a little C program to generate the
correct sizeOf, alignment, and field offsets. Very tedious and manual.
Hopefully avoidable by using something like hsc2hs or c2hs.

This is based on the example here: https://wiki.haskell.org/FFI_complete_examples

```
./run.sh
```
