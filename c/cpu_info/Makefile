CC = gcc

go: ./src/test.c
	#$(CC) -o src/str.o src/str.c
	$(CC) -o test -I./src/libcpuid/libcpuid -lcpuid -lzmq src/test.c
