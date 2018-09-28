#include <stdio.h>
#include <stddef.h>
#include <stdalign.h>
#include "my_struct.h"

int main(int argc, char *argv[])
{
  printf("instance Storable MyStructType where\n");

  printf("    sizeOf _ = %ld\n", sizeof(struct MyStruct));
  printf("    alignment _ = %ld\n", alignof(struct MyStruct));

  printf("    peek ptr = do\n");
  printf("        _foo <- peekByteOff ptr %ld\n",
         offsetof(struct MyStruct, foo));
  printf("        _bar <- peekByteOff ptr %ld\n",
         offsetof(struct MyStruct, bar));
  printf("        return (MyStructType _foo _bar)\n");

  printf("    poke ptr (MyStructType _foo _bar) = do\n");
  printf("        pokeByteOff ptr %ld _foo\n",
         offsetof(struct MyStruct, foo));
  printf("        pokeByteOff ptr %ld _bar\n",
         offsetof(struct MyStruct, bar));

  return 0;
}
