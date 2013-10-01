#include <stdio.h>
#include <string.h>

%%{

  machine test_lexer;

  integer = ('+'|'-')?[0-9]+;

  action number {
    printf("Hola putos!: %c\n", fc);
  }

  main := |*
    integer* => number;
  *|;
}%%

%% write data nofinal;

int main( int argc, char **argv ) {
  int cs, act, res = 0;
  char *ts, *te;
  if ( argc > 1 ) {
    char *p = argv[1];
    char *pe = p + strlen(p) + 1;
    char *eof = 0;

    %% write init;
    %% write exec;
  }
  printf("result =%i\n", res);
  return 0;
}
