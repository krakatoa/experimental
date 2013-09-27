#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char *argv[]) {
  double a = atof(argv[1]);
  double b = atof(argv[2]);
  double c = atof(argv[3]);

  double x1 = (-b + sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
  double x2 = (-b - sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
  
  printf("a: %.4f\n", a);
  printf("b: %.4f\n", b);
  printf("c: %.4f\n", c);
  printf("raiz x1: %.4f\n", x1);
  printf("raiz x2: %.4f\n", x2);
}
