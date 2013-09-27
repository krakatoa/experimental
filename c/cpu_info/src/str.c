#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "str.h"

char* serialize(char* vendor, char* brand) {
  char* resp;
  int len = snprintf(NULL, 0, "%s, %s", vendor, brand);
  resp = (char *)malloc(len + 1);
  sprintf(resp, "%s,%s", vendor, brand);
}
