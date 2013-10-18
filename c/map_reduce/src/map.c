#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>

struct ThreadData {
  int start, end;
  int *fd;
};

struct ReduceData {
  int *fd;
};

char *scanNext(char **word, FILE **file, int uid) {
  fscanf(*file, "%m[A-Za-z]%*[^$,. \t\v\f\n\r]", word);
  fgetc(*file);
  if (*word) {
    printf("(%d) -> %s (@%d)\n", uid, *word, ftell(*file));
    return *word;
  }
}

void *map(struct ThreadData *td) {
  int uid = rand() % 50 + 100;

  //printf("[%d][STARTED] %d-%d\n", uid, td->start, td-> end);
  FILE *fp;
  char *readWord;
  char c;

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
    int result;
    while(!feof(fp) && ftell(fp) <= td->end) {
      scanNext(&readWord, &fp, uid);
      if (readWord) {
        result = write(td->fd[1], readWord, (strlen(readWord) + 1));
        //if (result != 1){
        //  perror("write");
        //}
      }
    }
    if (ftell(fp) == td->end + 1) { // It means last char is a space, so next batch will not know if string is truncated. Will process here
      scanNext(&readWord, &fp, uid);
      if (readWord) {
        result = write(td->fd[1], readWord, (strlen(readWord) + 1));
        //if (result != 1){
        //  perror("write");
        //}
      }
    }
    fclose(fp);
  }
  free(readWord);
  //printf("[%d][FINISHED]\n", uid);
  
  return NULL;
}

void *reduce(struct ReduceData *rd) {
  printf("[STARTED REDUCE]\n");
  char buffer[256];

  int result;

  while(1) {
    result = read(rd->fd[0], buffer, sizeof(buffer));
    if (result < 1) {
      perror("read");
      exit(2);
    }
    printf("Read: %s\n", buffer);
  } 

  printf("[FINISHED REDUCE]\n");
  return NULL;
}

int main(void) {
  pthread_t thread[4];
  struct ThreadData data[4];
  
  int fd[2];
  pipe(fd);
  int fd2[2];
  pipe(fd2);
  pthread_t reduce_t[1];
  struct ReduceData reduce_data[1];
  reduce_data[0].fd = fd;

  data[0].start = 0;
  data[0].end = 9;
  data[0].fd = fd;

  data[1].start = 10;
  data[1].end = 19;
  data[1].fd = fd2;

  data[2].start = 20;
  data[2].end = 29;
  data[2].fd = fd2;

  data[3].start = 30;
  data[3].end = 39;
  data[3].fd = fd2;

  int i;
  pthread_create(&reduce_t[0], NULL, (void *)reduce, &reduce_data[0]);
  for (i = 0; i < 4; i++) {
    pthread_create(&thread[i], NULL, (void *)map, &data[i]);
  }

  pthread_join(reduce_t[0], NULL);
  for (i = 0; i < 4; i++) {
    pthread_join(thread[i], NULL);
  }
  pthread_exit(NULL);

  return 0;
}
