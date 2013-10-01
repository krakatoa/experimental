#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  char *data;
  int allocated;
  int length;
} Data;
Data theData;

void data_init(Data *d) {
  printf("Initializing theData\n");
  d->length = 1;
  d->allocated = sizeof(char);
  d->data = (char *)calloc(d->length, d->allocated);
};

void data_append(Data *d, char p) {
  d->data = (char *)realloc(d->data, sizeof(char) * (d->length++));
  d->data[d->length - 2] = p;
  d->allocated = d->allocated + sizeof(char);
  printf("Appending: %c\n", p);
};


%%{
  machine test_lexer;

  action number {
    data_append(&theData, fc);
  }

  action other {
    printf("  Accumulated: %s\n", theData.data);
  }

  integer = (
    ( ('+'|'-')? [0-9]+ ) $number
  ) %!other;

  main := (integer)*;
}%%

%% write data;

int main( int argc, char **argv ) {
  int cs, act, res = 0;
  char *ts, *te;
  if ( argc > 1 ) {
    char *p = argv[1];
    char *pe = p + strlen(p) + 1;
    char *eof = 0;
    data_init(&theData);

    %% write init;
    %% write exec;
  }
  printf("result =%i\n", res);
  return 0;
}
