#include <stdio.h>
#include <stdlib.h>

#include <string.h>

typedef struct {
  int *primes;
  int count;
} Result;

int isPrime(int n, int* divisors, int divisorsLength) {
  if (n > 2) {
    int i;
    for (i = 0; i < divisorsLength; i++) {
      if (n % divisors[i] == 0) {
        return 0;
      }
    }
    return 1;  
  } else {
    return 1;
  }
}

char* nextRotation(char *n) {
  int len = strlen(n);
  char *newRotation = (char *)calloc(len + 1, sizeof(int) * (len + 1));
  
  int i;
  for (i = 0; i < len - 1; i++) {
    newRotation[i] = n[i + 1];
  }
  newRotation[len - 1] = n[0];
  return newRotation; 
}

int exists(int *arr, int length, int value) {
  int i;
  for (i = 0; i < length; i++) {
    if (arr[i] == value) {
      return 1;
    }
  }
  return 0;
}

int containsAll(int *arrA, int lengthA, int *arrB, int lengthB) {
  int i;
  for (i = 0; i < lengthB; i++) {
    if (exists(arrA, lengthA, arrB[i]) == 0) {
      return 0;
    }
  }
  return 1;
}

Result rotations(int n) {
  int *rotations = (int *)malloc(sizeof(int));
  int rotationsCount = 1;

  char *lit;
  int litLength = snprintf(NULL, 0, "%d", n);
  lit = (char *)calloc(litLength + 1, sizeof(int) * (litLength + 1));
  sprintf(lit, "%d", n);
  
  int i;
  char *tmp;
  int res;
  for (i = 0; i < litLength; i++) {
    tmp = lit;
    lit = nextRotation(lit);
    free(tmp);

    if (lit[0] != '0') {
      int res = exists(rotations, rotationsCount - 1, atoi(lit)); // do not add an already existent number to the rotations array
      if (res == 0) {
        rotations[rotationsCount - 1] = atoi(lit);
        rotationsCount++;
        rotations = (int *)realloc(rotations, sizeof(int) * rotationsCount);
      }
    }
  }
  free(lit);

  Result r = {.primes = rotations, .count = rotationsCount - 1};
  return r;
}

Result getPrimes(int a, int b) {
  int *primes = (int *)malloc(sizeof(int));
  int primesCount = 1;

  int n;
  for (n = a; n <= b; n++) {
    if (isPrime(n, primes, primesCount - 1) == 1) {
      primes[primesCount - 1] = n;
      primes = (int *)realloc(primes, (primesCount + 1) * sizeof(int));
      primesCount++;
    }
  }
  
  Result r = {.primes = primes, .count = primesCount - 1};
  //r.primes = primes;
  //r.count = primesCount - 1;
  return r;
}

int main(void) {
  Result primes = getPrimes(2, 1000000);
  int i;
  Result r;

  int count = 0;
  for (i=0; i < primes.count; i++) {
    //printf("%d,", primes.primes[i]);
    r = rotations(primes.primes[i]);
    if (containsAll(primes.primes, primes.count, r.primes, r.count) == 1) {
      printf("%d,", primes.primes[i]);
      count++;
    }
  }
  printf("\nThere were %d circular primes.", count);

/*
  char *s = nextRotation("197");
  printf("%s", s);
  free(s);
*/

/*
  Result r = rotations(13000);
  int i;
  for (i = 0; i < r.count; i++) {
    printf("%d\n", r.primes[i]);
  }
*/  

  /*int a[4] = {2,3,4,5};
  int b[2] = {2,5};
  printf("containsAll(a,b): %d\n", containsAll(a, 4, b, 2));

  int c[2] = {2,5};
  int d[4] = {2,3,4,5};
  printf("containsAll(c,d): %d\n", containsAll(c, 2, d, 4));

  int e[1] = {5};
  int f[3] = {2,3,4};
  printf("containsAll(e,f): %d\n", containsAll(e, 1, f, 3));

  int g[2] = {11,13};
  int h[2] = {11,11};
  printf("containsAll(g,h): %d\n", containsAll(g, 2, h, 2));

  int i[2] = {11,13};
  int j[1] = {11};
  printf("containsAll(i,j): %d\n", containsAll(i, 2, j, 1));
  */

  return 0;
};
