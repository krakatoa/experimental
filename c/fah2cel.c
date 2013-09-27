#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  double fahrenheit = atof(argv[1]);
  
  double celsius = (fahrenheit - 32) / 1.8;

  printf("In Fahrenheit: %.2f\n", fahrenheit);
  printf("In Celsius: %.2f\n", celsius);
}
