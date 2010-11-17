FLAGS=-L-lfuse -L-lrt -L-ldl
FUSE=../../src/fuse.d ../../src/fuse_opt.d ../../src/fuse_common.d ../../src/fuse_helper.d


tagfs : func.o
	dmd $(FLAGS) hello.d func.o $(FUSE)

func.o: func.c
	gcc -g -Wall `pkg-config fuse --cflags --libs` func.c -c
