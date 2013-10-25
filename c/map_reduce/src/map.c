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

void *skipFirst(FILE **file, int uid) {
  char buffer[256];
  int res;
  res = fscanf(*file, "%*[A-Za-z]%[^$,. \t\v\f\n\r]", NULL, buffer);
  
  if (res) { 
    fseek(*file, ftell(*file) - 1, SEEK_SET);
  }
}

void *scanNext(char **word, FILE **file, int uid) {
  char buffer[256];
  int res;
      //fscanf(*file, "%*[A-Za-z]%m[^$,. \t\v\f\n\r]", &readWord, NULL);
  res = fscanf(*file, "%[A-Za-z]%*[^$,. \t\v\f\n\r]", buffer, NULL);
  fseek(*file, ftell(*file) + 1, SEEK_SET);

  //char *buffer;// = NULL;
  //fscanf(*file, "%m[A-Za-z]%*[^$,. \t\v\f\n\r]", &buffer, NULL);
  //fgetc(*file);

  //char buffer[256];
  //fgets(buffer, sizeof(buffer), *file);
  //sscanf(buffer, "%[A-Za-z]%*[^$,. \t\v\f\n\r]", buffer, NULL);

  if (res) {
    //printf("(%d) -> %s (@%d)\n", uid, buffer, ftell(*file));
    
    //free(*word);
    *word = (char *)malloc(strlen(buffer) + 1);
    memcpy(*word, buffer, strlen(buffer) + 1);

    //free(buffer);
    //*word = buffer;
  }
}

void *map(struct ThreadData *td) {
  int uid = rand() % 50 + 100;

  //printf("[%d][STARTED] %d-%d\n", uid, td->start, td-> end);
  FILE *fp;
  char *readWord = NULL;
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
      if (td->start > 0) { skipFirst(&fp, uid); }
    }
    int result;
    while(!feof(fp) && ftell(fp) <= td->end + 1) {
      scanNext(&readWord, &fp, uid);
      if (readWord) {
        printf("(%d) -> %s (@%d)\n", uid, readWord, ftell(fp));
        result = write(td->fd[1], readWord, (strlen(readWord) + 1));
        free(readWord);
        //if (result != 1){
        //  perror("write");
        //}
      }
    }
    fclose(fp);
  }
  //printf("[%d][FINISHED]\n", uid);
  pthread_exit(NULL);
  
  return NULL;
}

void *reduce(struct ReduceData *rd) {
  printf("[STARTED REDUCE]\n");
  char buffer[256];

  int result;

  while(1) {
    result = read(rd->fd[0], buffer, sizeof(buffer));
    //result = read(rd->fd[0], buffer, strlen(buffer) + 1);
    if (result < 1) {
      perror("read");
      exit(2);
    }
    printf("Read: %s\n", buffer);
  }

  printf("[FINISHED REDUCE]\n");
  pthread_exit(NULL);
  return NULL;
}

int main(void) {
  pthread_t thread[4];
  struct ThreadData data[4];

  int fd[2];
  pipe(fd);
  //int fd2[2];
  //pipe(fd2);
  pthread_t reduce_t[1];
  struct ReduceData reduce_data[1];
  reduce_data[0].fd = fd;

  data[0].start = 0;
  data[0].end = 9;
  data[0].fd = fd;

  data[1].start = 10;
  data[1].end = 19;
  data[1].fd = fd;

  data[2].start = 20;
  data[2].end = 29;
  data[2].fd = fd;

  data[3].start = 30;
  data[3].end = 39;
  data[3].fd = fd;

  int i;
  pthread_create(&reduce_t[0], NULL, (void *)reduce, &reduce_data[0]);
  for (i = 0; i < 4; i++) {
    pthread_create(&thread[i], NULL, (void *)map, &data[i]);
  }

  pthread_join(reduce_t[0], NULL);
  for (i = 0; i < 4; i++) {
    pthread_join(thread[i], NULL);
  }

  return 0;
}
