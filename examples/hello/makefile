FLAGS=-L-lfuse -L-lrt -L-ldl -L-lsqlite3

tagfs : func.o
	dmd testfuse.d statvfs.d fuse_opt.d fuse_helper.d fuse.d fuse_common.d func.o $(FLAGS)

func.o: func.c
	gcc -g -Wall `pkg-config fuse --cflags --libs` func.c -c

hello : hello.c
	gcc -g -Wall `pkg-config fuse --cflags --libs` hello.c -o hello
