/* Converted to D from .\fuse_t.h by htod */
module fuse;
/*
  FUSE: Filesystem in Userspace
  Copyright (C) 2001-2007  Miklos Szeredi <miklos@szeredi.hu>

  This program can be distributed under the terms of the GNU LGPLv2.
  See the file COPYING.LIB.
*/

public import core.sys.posix.fcntl;
public import core.sys.posix.sys.stat;
public import core.sys.posix.sys.time;
public import core.sys.posix.sys.types;
public import core.sys.posix.utime;

public import fuse_common;
public import fuse_helper;


/* ----------------------------------------------------------- *
 * Basic FUSE API					       *
 * ----------------------------------------------------------- */

extern (C):

/** Handle for a FUSE filesystem */
struct fuse_t;

/** Structure containing a raw command */
struct fuse_cmd;

/** Function to add an entry in a readdir() operation
 *
 * @param buf the buffer passed to the readdir() operation
 * @param name the file name of the directory entry
 * @param stat file attributes, can be NULL
 * @param off offset of the next entry or zero
 * @return 1 if buffer is full, zero otherwise
 */
alias int  function(void *buf, const char *name, stat_t *stbuf, off_t off)fuse_fill_dir_t;

/* Used by deprecated getdir() method */
alias fuse_dirhandle *fuse_dirh_t;
alias int function(fuse_dirh_t h, char *name, int type, ino_t ino)fuse_dirfil_t;

/**
 * The file system operations:
 *
 * Most of these should work very similarly to the well known UNIX
 * file system operations.  A major exception is that instead of
 * returning an error in 'errno', the operation should return the
 * negated error value (-errno) directly.
 *
 * All methods are optional, but some are essential for a useful
 * filesystem (e.g. getattr).  Open, flush, release, fsync, opendir,
 * releasedir, fsyncdir, access, create, ftruncate, fgetattr, lock,
 * init and destroy are special purpose methods, without which a full
 * featured filesystem can still be implemented.
 *
 * Almost all operations take a path which can be of any length.
 *
 * Changed in fuse_t 2.8.0 (regardless of API version)
 * Previously, paths were limited to a length of PATH_MAX.
 *
 * See http://fuse_t.sourceforge.net/wiki/ for more information.  There
 * is also a snapshot of the relevant wiki pages in the doc/ folder.
 */
struct fuse_operations
{
	/** Get file attributes.
	 *
	 * Similar to stat().  The 'st_dev' and 'st_blksize' fields are
	 * ignored.	 The 'st_ino' field is ignored except if the 'use_ino'
	 * mount option is given.
	 */
    int  function(char *, stat_t *)getattr;

	/** Read the target of a symbolic link
	 *
	 * The buffer should be filled with a null terminated string.  The
	 * buffer size argument includes the space for the terminating
	 * null character.	If the linkname is too long to fit in the
	 * buffer, it should be truncated.	The return value should be 0
	 * for success.
	 */
    int  function(char *, char *, size_t )readlink;

	/* Deprecated, use readdir() instead */
    deprecated int  function(char *, fuse_dirh_t , fuse_dirfil_t )getdir;

	/** Create a file node
	 *
	 * This is called for creation of all non-directory, non-symlink
	 * nodes.  If the filesystem defines a create() method, then for
	 * regular files that will be called instead.
	 */
    int  function(char *, mode_t , dev_t )mknod;

	/** Create a directory 
	 *
	 * Note that the mode argument may not have the type specification
	 * bits set, i.e. S_ISDIR(mode) can be false.  To obtain the
	 * correct directory type bits use  mode|S_IFDIR
	 * */
    int  function(char *, mode_t )mkdir;

	/** Remove a file */
    int  function(char *)unlink;

	/** Remove a directory */
    int  function(char *)rmdir;

	/** Create a symbolic link */
    int  function(char *, char *)symlink;

	/** Rename a file */
    int  function(char *, char *)rename;

	/** Create a hard link to a file */
    int  function(char *, char *)link;

	/** Change the permission bits of a file */
    int  function(char *, mode_t )chmod;

	/** Change the owner and group of a file */
    int  function(char *, uid_t , gid_t )chown;

	/** Change the size of a file */
    int  function(char *, off_t )truncate;

	/** Change the access and/or modification times of a file
	 *
	 * Deprecated, use utimens() instead.
	 */
    deprecated int  function(char *, utimbuf *)utime;

	/** File open operation
	 *
	 * No creation (O_CREAT, O_EXCL) and by default also no
	 * truncation (O_TRUNC) flags will be passed to open(). If an
	 * application specifies O_TRUNC, fuse_t first calls truncate()
	 * and then open(). Only if 'atomic_o_trunc' has been
	 * specified and kernel version is 2.6.24 or later, O_TRUNC is
	 * passed on to open.
	 *
	 * Unless the 'default_permissions' mount option is given,
	 * open should check if the operation is permitted for the
	 * given flags. Optionally open may also return an arbitrary
	 * filehandle in the fuse_file_info structure, which will be
	 * passed to all file operations.
	 *
	 * Changed in version 2.2
	 */
    int  function(char *, fuse_file_info *)open;

	/** Read data from an open file
	 *
	 * Read should return exactly the number of bytes requested except
	 * on EOF or error, otherwise the rest of the data will be
	 * substituted with zeroes.	 An exception to this is when the
	 * 'direct_io' mount option is specified, in which case the return
	 * value of the read system call will reflect the return value of
	 * this operation.
	 *
	 * Changed in version 2.2
	 */
    int  function(char *, char *, size_t , off_t , fuse_file_info *)read;

	/** Write data to an open file
	 *
	 * Write should return exactly the number of bytes requested
	 * except on error.	 An exception to this is when the 'direct_io'
	 * mount option is specified (see read operation).
	 *
	 * Changed in version 2.2
	 */
    int  function(char *, char *, size_t , off_t , fuse_file_info *)write;

	/** Get file system statistics
	 *
	 * The 'f_frsize', 'f_favail', 'f_fsid' and 'f_flag' fields are ignored
	 *
	 * Replaced 'struct statfs' parameter with 'struct statvfs' in
	 * version 2.5
	 */
    int  function(char *, statvfs *)statfs;

	/** Possibly flush cached data
	 *
	 * BIG NOTE: This is not equivalent to fsync().  It's not a
	 * request to sync dirty data.
	 *
	 * Flush is called on each close() of a file descriptor.  So if a
	 * filesystem wants to return write errors in close() and the file
	 * has cached dirty data, this is a good place to write back data
	 * and return any errors.  Since many applications ignore close()
	 * errors this is not always useful.
	 *
	 * NOTE: The flush() method may be called more than once for each
	 * open().	This happens if more than one file descriptor refers
	 * to an opened file due to dup(), dup2() or fork() calls.	It is
	 * not possible to determine if a flush is final, so each flush
	 * should be treated equally.  Multiple write-flush sequences are
	 * relatively rare, so this shouldn't be a problem.
	 *
	 * Filesystems shouldn't assume that flush will always be called
	 * after some writes, or that if will be called at all.
	 *
	 * Changed in version 2.2
	 */
    int  function(char *, fuse_file_info *)flush;

	/** Release an open file
	 *
	 * Release is called when there are no more references to an open
	 * file: all file descriptors are closed and all memory mappings
	 * are unmapped.
	 *
	 * For every open() call there will be exactly one release() call
	 * with the same flags and file descriptor.	 It is possible to
	 * have a file opened more than once, in which case only the last
	 * release will mean, that no more reads/writes will happen on the
	 * file.  The return value of release is ignored.
	 *
	 * Changed in version 2.2
	 */
    int  function(char *, fuse_file_info *)release;

	/** Synchronize file contents
	 *
	 * If the datasync parameter is non-zero, then only the user data
	 * should be flushed, not the meta data.
	 *
	 * Changed in version 2.2
	 */
    int  function(char *, int , fuse_file_info *)fsync;

	/** Set extended attributes */
    int  function(char *, char *, char *, size_t , int )setxattr;

	/** Get extended attributes */
    int  function(char *, char *, char *, size_t )getxattr;

	/** List extended attributes */
    int  function(char *, char *, size_t )listxattr;

	/** Remove extended attributes */
    int  function(char *, char *)removexattr;

	/** Open directory
	 *
	 * Unless the 'default_permissions' mount option is given,
	 * this method should check if opendir is permitted for this
	 * directory. Optionally opendir may also return an arbitrary
	 * filehandle in the fuse_file_info structure, which will be
	 * passed to readdir, closedir and fsyncdir.
	 *
	 * Introduced in version 2.3
	 */
    int  function(char *, fuse_file_info *)opendir;

	/** Read directory
	 *
	 * This supersedes the old getdir() interface.  New applications
	 * should use this.
	 *
	 * The filesystem may choose between two modes of operation:
	 *
	 * 1) The readdir implementation ignores the offset parameter, and
	 * passes zero to the filler function's offset.  The filler
	 * function will not return '1' (unless an error happens), so the
	 * whole directory is read in a single readdir operation.  This
	 * works just like the old getdir() method.
	 *
	 * 2) The readdir implementation keeps track of the offsets of the
	 * directory entries.  It uses the offset parameter and always
	 * passes non-zero offset to the filler function.  When the buffer
	 * is full (or an error happens) the filler function will return
	 * '1'.
	 *
	 * Introduced in version 2.3
	 */
    int  function(char *, void *, fuse_fill_dir_t , off_t , fuse_file_info *)readdir;

	/** Release directory
	 *
	 * Introduced in version 2.3
	 */
    int  function(char *, fuse_file_info *)releasedir;

	/** Synchronize directory contents
	 *
	 * If the datasync parameter is non-zero, then only the user data
	 * should be flushed, not the meta data
	 *
	 * Introduced in version 2.3
	 */
    int  function(char *, int , fuse_file_info *)fsyncdir;

	/**
	 * Initialize filesystem
	 *
	 * The return value will passed in the private_data field of
	 * fuse_context to all file operations and as a parameter to the
	 * destroy() method.
	 *
	 * Introduced in version 2.3
	 * Changed in version 2.6
	 */
    void * function(fuse_conn_info *conn)init;

	/**
	 * Clean up filesystem
	 *
	 * Called on filesystem exit.
	 *
	 * Introduced in version 2.3
	 */
    void  function(void *)destroy;

	/**
	 * Check file access permissions
	 *
	 * This will be called for the access() system call.  If the
	 * 'default_permissions' mount option is given, this method is not
	 * called.
	 *
	 * This method is not called under Linux kernel versions 2.4.x
	 *
	 * Introduced in version 2.5
	 */
    int  function(char *, int )access;

	/**
	 * Create and open a file
	 *
	 * If the file does not exist, first create it with the specified
	 * mode, and then open it.
	 *
	 * If this method is not implemented or under Linux kernel
	 * versions earlier than 2.6.15, the mknod() and open() methods
	 * will be called instead.
	 *
	 * Introduced in version 2.5
	 */
    int  function(char *, mode_t , fuse_file_info *)create;

	/**
	 * Change the size of an open file
	 *
	 * This method is called instead of the truncate() method if the
	 * truncation was invoked from an ftruncate() system call.
	 *
	 * If this method is not implemented or under Linux kernel
	 * versions earlier than 2.6.15, the truncate() method will be
	 * called instead.
	 *
	 * Introduced in version 2.5
	 */
    int  function(char *, off_t , fuse_file_info *)ftruncate;

	/**
	 * Get attributes from an open file
	 *
	 * This method is called instead of the getattr() method if the
	 * file information is available.
	 *
	 * Currently this is only called after the create() method if that
	 * is implemented (see above).  Later it may be called for
	 * invocations of fstat() too.
	 *
	 * Introduced in version 2.5
	 */
    int  function(char *, stat_t *, fuse_file_info *)fgetattr;

	/**
	 * Perform POSIX file locking operation
	 *
	 * The cmd argument will be either F_GETLK, F_SETLK or F_SETLKW.
	 *
	 * For the meaning of fields in 'struct flock' see the man page
	 * for fcntl(2).  The l_whence field will always be set to
	 * SEEK_SET.
	 *
	 * For checking lock ownership, the 'fuse_file_info->owner'
	 * argument must be used.
	 *
	 * For F_GETLK operation, the library will first check currently
	 * held locks, and if a conflicting lock is found it will return
	 * information without calling this method.	 This ensures, that
	 * for local locks the l_pid field is correctly filled in.	The
	 * results may not be accurate in case of race conditions and in
	 * the presence of hard links, but it's unlikly that an
	 * application would rely on accurate GETLK results in these
	 * cases.  If a conflicting lock is not found, this method will be
	 * called, and the filesystem may fill out l_pid by a meaningful
	 * value, or it may leave this field zero.
	 *
	 * For F_SETLK and F_SETLKW the l_pid field will be set to the pid
	 * of the process performing the locking operation.
	 *
	 * Note: if this method is not implemented, the kernel will still
	 * allow file locking to work locally.  Hence it is only
	 * interesting for network filesystems and similar.
	 *
	 * Introduced in version 2.6
	 */
    int  function(char *, fuse_file_info *, int cmd, flock *)lock;

	/**
	 * Change the access and modification times of a file with
	 * nanosecond resolution
	 *
	 * Introduced in version 2.6
	 */
    int  function(char *, timespec *tv)utimens;

	/**
	 * Map block index within file to block index within device
	 *
	 * Note: This makes sense only for block device backed filesystems
	 * mounted with the 'blkdev' option
	 *
	 * Introduced in version 2.6
	 */
    int  function(char *, size_t blocksize, uint64_t *idx)bmap;

	 /// Feild used for the following properties
    uint __bitfield1;

	/**
	 * Flag indicating, that the filesystem can accept a NULL path
	 * as the first argument for the following operations:
	 *
	 * read, write, flush, release, fsync, readdir, releasedir,
	 * fsyncdir, ftruncate, fgetattr and lock
	 */
    @property uint flag_nullpath_ok() { return (__bitfield1 >> 0) & 0x1; }
    @property uint flag_nullpath_ok(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }

	/**
	 * Reserved flags, don't set
	 */
    @property uint flag_reserved() { return (__bitfield1 >> 1) & 0x7fffffff; }
    @property uint flag_reserved(uint value) { __bitfield1 = (__bitfield1 & 0xffffffff00000001) | (value << 1); return value; }

	/**
	 * Ioctl
	 *
	 * flags will have FUSE_IOCTL_COMPAT set for 32bit ioctls in
	 * 64bit environment.  The size and direction of data is
	 * determined by _IOC_*() decoding of cmd.  For _IOC_NONE,
	 * data will be NULL, for _IOC_WRITE data is out area, for
	 * _IOC_READ in area and if both are set in/out area.  In all
	 * non-NULL cases, the area is of _IOC_SIZE(cmd) bytes.
	 *
	 * Introduced in version 2.8
	 */
    int  function(char *, int cmd, void *arg, fuse_file_info *, uint flags, void *data)ioctl;

	/**
	 * Poll for IO readiness events
	 *
	 * Note: If ph is non-NULL, the client should notify
	 * when IO readiness events occur by calling
	 * fuse_notify_poll() with the specified ph.
	 *
	 * Regardless of the number of times poll with a non-NULL ph
	 * is received, single notification is enough to clear all.
	 * Notifying more times incurs overhead but doesn't harm
	 * correctness.
	 *
	 * The callee is responsible for destroying ph with
	 * fuse_pollhandle_destroy() when no longer in use.
	 *
	 * Introduced in version 2.8
	 */
    int  function(char *, fuse_file_info *, fuse_pollhandle *ph, uint *reventsp)poll;
}

/** Extra context that may be needed by some filesystems
 *
 * The uid, gid and pid fields are not filled in case of a writepage
 * operation.
 */
struct fuse_context
{
	/** Pointer to the fuse_t object */
	fuse_t *fuse;

	/** User ID of the calling process */
	uid_t uid;

	/** Group ID of the calling process */
	gid_t gid;

	/** Thread ID of the calling process */
	pid_t pid;

	/** Private filesystem data */
	void *private_data;

	/** Umask of the calling process (introduced in version 2.8) */
	mode_t umask;
}

/**
 * Main function of FUSE.
 *
 * This is for the lazy.  This is all that has to be called from the
 * main() function.
 *
 * This function does the following:
 *   - parses command line options (-d -s and -h)
 *   - passes relevant mount options to the fuse_mount()
 *   - installs signal handlers for INT, HUP, TERM and PIPE
 *   - registers an exit handler to unmount the filesystem on program exit
 *   - creates a fuse_t handle
 *   - registers the operations
 *   - calls either the single-threaded or the multi-threaded event loop
 *
 * Note: this is currently implemented as a macro.
 *
 * @param argc the argument counter passed to the main() function
 * @param argv the argument vector passed to the main() function
 * @param op the file system operation
 * @param user_data user data supplied in the context during the init() method
 * @return 0 on success, nonzero on failure
 */
int fuse_main(int argc, char **argv, fuse_operations *op, void* user_data = null) {
	return fuse_main_real(argc, argv, op, (*(op)).sizeof, user_data);
}

/* ----------------------------------------------------------- *
 * More detailed API					       *
 * ----------------------------------------------------------- */

/**
 * Create a new FUSE filesystem.
 *
 * @param ch the communication channel
 * @param args argument vector
 * @param op the filesystem operations
 * @param op_size the size of the fuse_operations structure
 * @param user_data user data supplied in the context during the init() method
 * @return the created FUSE handle
 */
fuse_t * fuse_new(fuse_chan *ch, fuse_args *args, fuse_operations *op, size_t op_size, void *user_data);

/**
 * Destroy the FUSE handle.
 *
 * The communication channel attached to the handle is also destroyed.
 *
 * NOTE: This function does not unmount the filesystem.	 If this is
 * needed, call fuse_unmount() before calling this function.
 *
 * @param f the FUSE handle
 */
void  fuse_destroy(fuse_t *f);

/**
 * FUSE event loop.
 *
 * Requests from the kernel are processed, and the appropriate
 * operations are called.
 *
 * @param f the FUSE handle
 * @return 0 if no error occurred, -1 otherwise
 */
int  fuse_loop(fuse_t *f);

/**
 * Exit from event loop
 *
 * @param f the FUSE handle
 */
void  fuse_exit(fuse_t *f);

/**
 * FUSE event loop with multiple threads
 *
 * Requests from the kernel are processed, and the appropriate
 * operations are called.  Request are processed in parallel by
 * distributing them between multiple threads.
 *
 * Calling this function requires the pthreads library to be linked to
 * the application.
 *
 * @param f the FUSE handle
 * @return 0 if no error occurred, -1 otherwise
 */
int  fuse_loop_mt(fuse_t *f);

/**
 * Get the current context
 *
 * The context is only valid for the duration of a filesystem
 * operation, and thus must not be stored and used later.
 *
 * @return the context
 */
fuse_context * fuse_get_context();

/**
 * Get the current supplementary group IDs for the current request
 *
 * Similar to the getgroups(2) system call, except the return value is
 * always the total number of group IDs, even if it is larger than the
 * specified size.
 *
 * The current fuse_t kernel module in linux (as of 2.6.30) doesn't pass
 * the group list to userspace, hence this function needs to parse
 * "/proc/$TID/task/$TID/status" to get the group IDs.
 *
 * This feature may not be supported on all operating systems.  In
 * such a case this function will return -ENOSYS.
 *
 * @param size size of given array
 * @param list array of group IDs to be filled in
 * @return the total number of supplementary group IDs or -errno on failure
 */
int  fuse_getgroups(int size, gid_t *list);

/**
 * Check if the current request has already been interrupted
 *
 * @return 1 if the request has been interrupted, 0 otherwise
 */
int  fuse_interrupted();

/**
 * Obsolete, doesn't do anything
 *
 * @return -EINVAL
 */
int  fuse_invalidate(fuse_t *f, char *path);

/* Deprecated, don't use */
deprecated int  fuse_is_lib_option(char *opt);

/**
 * The real main function
 *
 * Do not call this directly, use fuse_main()
 */
int  fuse_main_real(int argc, char **argv, fuse_operations *op, size_t op_size, void *user_data);

/*
 * Stacking API
 */

/**
 * Fuse filesystem object
 *
 * This is opaque object represents a filesystem layer
 */
struct fuse_fs {
	fuse_operations op;
	fuse_module *m;
	void *user_data;
	int compat;
	int debug_flag;
};

/**
 * These functions call the relevant filesystem operation, and return
 * the result.
 *
 * If the operation is not defined, they return -ENOSYS, with the
 * exception of fuse_fs_open, fuse_fs_release, fuse_fs_opendir,
 * fuse_fs_releasedir and fuse_fs_statfs, which return 0.
 */
int  fuse_fs_getattr(fuse_fs *fs, const char *path, stat_t *buf);
/// Ditto
int  fuse_fs_fgetattr(fuse_fs *fs, const char *path, stat_t *buf, fuse_file_info *fi);
/// Ditto
int  fuse_fs_rename(fuse_fs *fs, char *oldpath, char *newpath);
/// Ditto
int  fuse_fs_unlink(fuse_fs *fs, const char *path);
/// Ditto
int  fuse_fs_rmdir(fuse_fs *fs, const char *path);
/// Ditto
int  fuse_fs_symlink(fuse_fs *fs, char *linkname, const char *path);
/// Ditto
int  fuse_fs_link(fuse_fs *fs, char *oldpath, char *newpath);
/// Ditto
int  fuse_fs_release(fuse_fs *fs, const char *path, fuse_file_info *fi);
/// Ditto
int  fuse_fs_open(fuse_fs *fs, const char *path, fuse_file_info *fi);
/// Ditto
int  fuse_fs_read(fuse_fs *fs, const char *path, char *buf, size_t size, off_t off, fuse_file_info *fi);
/// Ditto
int  fuse_fs_write(fuse_fs *fs, const char *path, char *buf, size_t size, off_t off, fuse_file_info *fi);
/// Ditto
int  fuse_fs_fsync(fuse_fs *fs, const char *path, int datasync, fuse_file_info *fi);
/// Ditto
int  fuse_fs_flush(fuse_fs *fs, const char *path, fuse_file_info *fi);
/// Ditto
int  fuse_fs_statfs(fuse_fs *fs, const char *path, statvfs *buf);
/// Ditto
int  fuse_fs_opendir(fuse_fs *fs, const char *path, fuse_file_info *fi);
/// Ditto
int  fuse_fs_readdir(fuse_fs *fs, const char *path, void *buf, fuse_fill_dir_t filler, off_t off, fuse_file_info *fi);
/// Ditto
int  fuse_fs_fsyncdir(fuse_fs *fs, const char *path, int datasync, fuse_file_info *fi);
/// Ditto
int  fuse_fs_releasedir(fuse_fs *fs, const char *path, fuse_file_info *fi);
/// Ditto
int  fuse_fs_create(fuse_fs *fs, const char *path, mode_t mode, fuse_file_info *fi);
/// Ditto
int  fuse_fs_lock(fuse_fs *fs, const char *path, fuse_file_info *fi, int cmd, flock *lock);
/// Ditto
int  fuse_fs_chmod(fuse_fs *fs, const char *path, mode_t mode);
/// Ditto
int  fuse_fs_chown(fuse_fs *fs, const char *path, uid_t uid, gid_t gid);
/// Ditto
int  fuse_fs_truncate(fuse_fs *fs, const char *path, off_t size);
/// Ditto
int  fuse_fs_ftruncate(fuse_fs *fs, const char *path, off_t size, fuse_file_info *fi);
/// Ditto
int  fuse_fs_utimens(fuse_fs *fs, const char *path, timespec *tv);
/// Ditto
int  fuse_fs_access(fuse_fs *fs, const char *path, int mask);
/// Ditto
int  fuse_fs_readlink(fuse_fs *fs, const char *path, char *buf, size_t len);
/// Ditto
int  fuse_fs_mknod(fuse_fs *fs, const char *path, mode_t mode, dev_t rdev);
/// Ditto
int  fuse_fs_mkdir(fuse_fs *fs, const char *path, mode_t mode);
/// Ditto
int  fuse_fs_setxattr(fuse_fs *fs, const char *path, char *name, char *value, size_t size, int flags);
/// Ditto
int  fuse_fs_getxattr(fuse_fs *fs, const char *path, char *name, char *value, size_t size);
/// Ditto
int  fuse_fs_listxattr(fuse_fs *fs, const char *path, char *list, size_t size);
/// Ditto
int  fuse_fs_removexattr(fuse_fs *fs, const char *path, char *name);
/// Ditto
int  fuse_fs_bmap(fuse_fs *fs, const char *path, size_t blocksize, uint64_t *idx);
/// Ditto
int  fuse_fs_ioctl(fuse_fs *fs, const char *path, int cmd, void *arg, fuse_file_info *fi, uint flags, void *data);
/// Ditto
int  fuse_fs_poll(fuse_fs *fs, const char *path, fuse_file_info *fi, fuse_pollhandle *ph, uint *reventsp);
/// Ditto
void  fuse_fs_init(fuse_fs *fs, fuse_conn_info *conn);
/// Ditto
void  fuse_fs_destroy(fuse_fs *fs);

/// Ditto
int  fuse_notify_poll(fuse_pollhandle *ph);

/**
 * Create a new fuse_t filesystem object
 *
 * This is usually called from the factory of a fuse_t module to create
 * a new instance of a filesystem.
 *
 * @param op the filesystem operations
 * @param op_size the size of the fuse_operations structure
 * @param user_data user data supplied in the context during the init() method
 * @return a new filesystem object
 */
fuse_fs * fuse_fs_new(fuse_operations *op, size_t op_size, void *user_data);

/**
 * Filesystem module
 *
 * Filesystem modules are registered with the FUSE_REGISTER_MODULE()
 * macro.
 *
 * If the "-omodules=modname:..." option is present, filesystem
 * objects are created and pushed onto the stack with the 'factory'
 * function.
 */
struct fuse_module
{
	/**
	 * Name of filesystem
	 */
    char *name;

	/**
	 * Factory for creating filesystem objects
	 *
	 * The function may use and remove options from 'args' that belong
	 * to this module.
	 *
	 * For now the 'fs' vector always contains exactly one filesystem.
	 * This is the filesystem which will be below the newly created
	 * filesystem in the stack.
	 *
	 * @param args the command line arguments
	 * @param fs NULL terminated filesystem object vector
	 * @return the new filesystem object
	 */
    fuse_fs * function(fuse_args *args, fuse_fs **fs)factory;

	 ///
    fuse_module *next;
	 ///
    fusemod_so *so;

	 ///
    int ctr;
}

/**
 * Register a filesystem module
 *
 * This function is used by FUSE_REGISTER_MODULE and there's usually
 * no need to call it directly
 */
void  fuse_register_module(fuse_module *mod);

/**
 * Register filesystem module
 *
 * For the parameters, see description of the fields in 'struct
 * fuse_module'
 */
//C     #define FUSE_REGISTER_MODULE(name_, factory_)				  	static __attribute__((constructor)) void name_ ## _register(void) 	{								  		static struct fuse_module mod =				  			{ #name_, factory_, NULL, NULL, 0 };		  		fuse_register_module(&mod);				  	}


/* ----------------------------------------------------------- *
 * Advanced API for event handling, don't worry about this...  *
 * ----------------------------------------------------------- */

/* NOTE: the following functions are deprecated, and will be removed
   from the 3.0 API.  Use the lowlevel session functions instead */

/** Function type used to process commands */
alias void  function(fuse_t *, fuse_cmd *, void *)fuse_processor_t;

/** This is the part of fuse_main() before the event loop */
fuse_t * fuse_setup(int argc, char **argv, fuse_operations *op, size_t op_size, char **mountpoint, int *multithreaded, void *user_data);

/** This is the part of fuse_main() after the event loop */
void  fuse_teardown(fuse_t *fuse_t, char *mountpoint);

/** Read a single command.  If none are read, return NULL */
fuse_cmd * fuse_read_cmd(fuse_t *f);

/** Process a single command */
void  fuse_process_cmd(fuse_t *f, fuse_cmd *cmd);

/** Multi threaded event loop, which calls the custom command
    processor function */
int  fuse_loop_mt_proc(fuse_t *f, fuse_processor_t proc, void *data);

/** Return the exited flag, which indicates if fuse_exit() has been
    called */
int  fuse_exited(fuse_t *f);

/** This function is obsolete and implemented as a no-op */
void  fuse_set_getcontext_func(fuse_context * function()func);

/** Get session from fuse_t object */
fuse_session * fuse_get_session(fuse_t *f);
