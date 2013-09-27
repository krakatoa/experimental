#include <stdio.h>

typedef struct {
  int version;
  int kind;
} Msg;

Msg testing(void)
{
  printf("Hola Mundo");
  Msg a;
  a.version = 1;
  a.kind = 2;
  return a;
}

static inline int estatica(void)
{
  return 5;
}

int devuelve_inc(int entero)
{
  return entero + estatica();
}
