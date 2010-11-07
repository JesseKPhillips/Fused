tagfs :
	dmd testfuse.d statvfs.d fuse_opt.d fuse_helper.d fuse.d fuse_common.d -L-lfuse -L-lrt -L-ldl

hello : hello.c
	gcc -g -Wall `pkg-config fuse --cflags --libs` hello.c -o hello
