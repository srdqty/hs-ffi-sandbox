#include <stdio.h>
#include <HsFFI.h>
#include "MyStruct_stub.h"
#include "my_struct.h"

int main(int argc, char *argv[])
{
  struct MyStruct myStruct;

  myStruct.foo = 7;
  myStruct.bar = 'x';

  hs_init(&argc, &argv);

  printf("%ld\n", foo(&myStruct));

  showStruct(&myStruct);

  hs_exit();

  return 0;
}
