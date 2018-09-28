#include <stdio.h>

#include <HsFFI.h>

#include "SimpleHsFromC_stub.h"


int main(int argc, char *argv[])
{
  int i;
  hs_init(&argc, &argv);

  i = fibonacci_hs(42);
  printf ("Fibonacci: %d\n", i);

  hs_exit();
  return 0;
}
