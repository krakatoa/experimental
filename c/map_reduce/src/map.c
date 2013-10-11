#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void scanNext(char **word, FILE **file) {
  fscanf(*file, "%m[A-Za-z]%*[^$,. \t\v\f\n\r]", word);
  fgetc(*file);
  if (*word) {
    printf("word: %s (at %d)\n", *word, ftell(*file));
  }
}

int main(void) {
  FILE *fp;
  char *readWord;

  int start = 0;
  int end = 10;

  fp = fopen("input.txt", "r");
  if (fp == NULL) {
    printf("Could not open input file.\n");
    return 1;
  } else {
    fseek(fp, start, SEEK_SET);
    if (start > 0) {
      fscanf(fp, "%*[A-Za-z]%m[^$,. \t\v\f\n\r]", &readWord);
    }
    while(!feof(fp) && ftell(fp) < end) {
      scanNext(&readWord, &fp);
    }
    if (ftell(fp) == end) { // It means last char is a space, so next batch will not know if string is truncated. Will process here
      scanNext(&readWord, &fp);
    }
    fclose(fp);
  }
  free(readWord);

  return 0;
}
