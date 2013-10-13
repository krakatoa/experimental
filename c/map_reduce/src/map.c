#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>

struct ThreadData {
  int start, end;
};

void scanNext(char **word, FILE **file, int uid) {
  fscanf(*file, "%m[A-Za-z]%*[^$,. \t\v\f\n\r]", word);
  fgetc(*file);
  if (*word) {
    //printf("(%d) -> %s (@%d)\n", uid, *word, ftell(*file));
    printf("(%d) -> %s\n", uid, *word);
  }
}

void *map(struct ThreadData *td) {
  //int r = rand() % 15;
  //sleep(r);
  int uid = rand() % 50 + 100;
  //printf("Inside thread %d\n", uid);

  printf("[%d][STARTED] %d-%d\n", uid, td->start, td-> end);
  FILE *fp;
  char *readWord;
  char c = '\0';

  fp = fopen("input.txt", "r");
  if (fp == NULL) {
    printf("Could not open input file.\n");
  } else {
    fseek(fp, td->start, SEEK_SET);
    c = fgetc(fp);
    fseek(fp, td->start, SEEK_SET);
    if (isspace(c)) {
      printf("era un espacio nomas...\n");
    } else {
      if (td->start > 0) {
        fscanf(fp, "%*[A-Za-z]%m[^$,. \t\v\f\n\r]", &readWord);
      }
    }
    while(!feof(fp) && ftell(fp) <= td->end) {
      scanNext(&readWord, &fp, uid);
    }
    if (ftell(fp) == td->end + 1) { // It means last char is a space, so next batch will not know if string is truncated. Will process here
      scanNext(&readWord, &fp, uid);
    }
    fclose(fp);
  }
  free(readWord);
  printf("[%d][FINISHED]\n", uid);
  
  return NULL;
}


int main(void) {
  pthread_t thread[4];
  struct ThreadData data[4];
  data[0].start = 0;
  data[0].end = 9;
  data[1].start = 10;
  data[1].end = 19;
  data[2].start = 20;
  data[2].end = 29;
  data[3].start = 30;
  data[3].end = 39;

  int i;
  for (i = 0; i < 4; i++) {
    pthread_create(&thread[i], NULL, (void *)map, &data[i]);
  }
  for (i = 0; i < 4; i++) {
    pthread_join(thread[i], NULL);
  }


  return 0;
}
