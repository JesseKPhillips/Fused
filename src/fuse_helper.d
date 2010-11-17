/**
 * This module contains the names of a couple structures referenced
 * but not defined by the headers. These structs are not implement.
 */
module fuse_helper;

/// fuse.c
struct fusemod_so;
struct fuse_dirhandle;
/+{
	fuse_fill_dir_t filler;
	void *buf;
};
+/

/**
 * This structure is used in some Fuse operations.
 *
 * I have removed the body as I am not likely to get this
 * correct for all systems. If you wish edit the file and
 * check that the struct communicates with C.
 *
 * /usr/include/bit/statvfs.h
 */
struct statvfs;
/+
{
	ulong f_bsize;
	ulong f_frsize;
	fsblkcnt_t f_blocks;
	fsblkcnt_t f_bfree;
	fsblkcnt_t f_bavail;
	fsfilcnt_t f_files;
	fsfilcnt_t f_ffree;
	fsfilcnt_t f_favail;
	ulong f_fsid;
	ulong f_flag;
	ulong f_namemax;
	uint f_spare[6];
}; 
+/

