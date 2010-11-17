module testfuse;

import std.string;
import std.conv;
import std.c.stdlib;
import std.c.string;
import core.stdc.errno;
import std.stdio;


import fuse;
import fuse_common;
import fuse_opt;

auto hello_str = "Hello World!\n";
auto hello_path = "/hello";

static fuse_operations hello_oper;
extern(C) int c_hello_getattr(const char *path, stat_t *stbuf);
extern(C) int c_hello_readdir(const char *path, void *buf, fuse_fill_dir_t filler, off_t offset, fuse_file_info *fi);
extern(C) int c_hello_open(const char *path, fuse_file_info *fi);
extern(C) int c_hello_read(const char *path, char *buf, size_t size, off_t offset, fuse_file_info *fi);

int main(string[] args)
{
    hello_oper.getattr = &hello_getattr;
    hello_oper.readdir = &hello_readdir;
    hello_oper.open	 = &hello_open;
    hello_oper.read	 = &hello_read;

	char*[] argv;
	foreach(arg; args) {
		argv ~= (arg ~ "\0").dup.ptr;
	}
    return fuse_main(argv.length, argv.ptr, &hello_oper);
 return 0;
}

extern (C):

int hello_getattr(const char *path, stat_t *stbuf) {
	return c_hello_getattr(path, stbuf);
}
//int hello_getattr(const char *path, stat_t *stbuf)
//{
//    int res = 0;
//	 writeln("Calling read Attribute: ", to!string(path));
//
//    memset(stbuf, 0, stat_t.sizeof);
//    if(strcmp(path, toStringz("/")) == 0) {
//		 writeln("Is DIR");
//        stbuf.st_mode = (S_IFDIR | 0755);
//	 	writeln("after set ", stbuf.st_mode);
//        stbuf.st_nlink = 2;
//    }
//    else if(strcmp(path, toStringz(hello_path)) == 0) {
//		 writeln("Is File");
//        stbuf.st_mode = S_IFREG | 0444;
//        stbuf.st_nlink = 1;
//        stbuf.st_size = hello_str.length;
//    }
//    else
//        res = -ENOENT;
//	 writeln("st_mode ", stbuf.st_mode);
//	 writeln("st_mode ", (S_IFDIR | 0775));
//	 writeln("enoent ", res);
//
//    return res;
//}

static int hello_readdir(const char *path, void *buf, fuse_fill_dir_t filler,
                         off_t offset, fuse_file_info *fi) {
	return c_hello_readdir(path, buf, filler, offset, fi);
}
//static int hello_readdir(const char *path, void *buf, fuse_fill_dir_t filler,
//                         off_t offset, fuse_file_info *fi)
//{
//    cast(void) offset;
//    cast(void) fi;
//
//    if(strcmp(path, "/") != 0)
//        return -ENOENT;
//
//    filler(buf, ".", null, 0);
//    filler(buf, "..", null, 0);
//    filler(buf, toStringz(hello_path) + 1, null, 0);
//
//    return 0;
//}

static int hello_open(const char *path, fuse_file_info *fi) {
	return c_hello_open(path, fi);
}
//static int hello_open(const char *path, fuse_file_info *fi)
//{
//    if(strcmp(path, toStringz(hello_path)) != 0)
//        return -ENOENT;
//
//    if((fi.flags & 3) != O_RDONLY)
//        return -EACCES;
//
//    return 0;
//}

static int hello_read(const char *path, char *buf, size_t size, off_t offset,
                      fuse_file_info *fi) {
	return c_hello_read(path, buf, size, offset, fi);
}
//static int hello_read(const char *path, char *buf, size_t size, off_t offset,
//                      fuse_file_info *fi)
//{
//    size_t len;
//    cast(void) fi;
//    if(strcmp(path, toStringz(hello_path)) != 0)
//        return -ENOENT;
//
//    len = hello_str.length;
//    if (offset < len) {
//        if (offset + size > len)
//            size = len - cast(size_t) offset;
//        memcpy(buf, toStringz(hello_str) + offset, size);
//    } else
//        size = 0;
//
//    return size;
//}

