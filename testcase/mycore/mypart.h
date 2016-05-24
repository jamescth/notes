#ifndef MYPART_H
#define MYPART_H

#include <sys/types.h>

#define FAILED		-1
#define SUCCEEDED	0

/*
 * We restrict the number of possible dump devices
 */
#define NUM_DUMPDEVS    14 
#define MAX_DUMPUNITS   (NUM_DUMPDEVS)

/*
 * The disk dump begins at offset 74MB in each partition
 * so that dd_raid can use the first 64MB as a scratchpad 
 * for nvram recovery
 * and diagnostic test can use the later 10MB for logging
 */
#define DISK_DUMP_STARTOFF      (1024 * 1024 * 74) 

/* 
 * Number of blocks reserved for use as a bit map for 
 * indicating valid application dumps.
 */
#define APPDUMP_BMAP_BLOCKS	8


#define DUMP_HEADER_STARTED     0x1
#define DUMP_HEADER_COMPLETED   0x2

/* Return code for read_device_header(), write_pages(), validate_hdrs() */
enum {
	COMPLETE,
	BLOCK_SIZE_INVALID,
	SEEK_ERROR_IN_DUMP_HEADER,
	READ_ERROR_IN_DUMP_HEADER,
	SEEK_ERROR_IN_DUMP_SUB_HEADER,
	READ_ERROR_IN_DUMP_SUB_HEADER,
	READ_ERROR_IN_DUMP_ELF_HEADER,
	READ_ERROR_IN_SEEK_ELF_HEADER,
	SEEK_ERROR_IN_MEMORY_BITMAP,
	READ_ERROR_IN_MEMORY_BITMAP,
	READ_ERROR_IN_MSGBUF,
	NO_PANIC_DUMP_HEADER,
	SIZE_NOT_MATCH,
	NUMBER_OF_CPUS_INVALID,
	SEEK_ERROR_IN_DUMP_DEVICE,
	READ_ERROR_IN_DUMP_DEVICE,
	WRITE_ERROR_IN_DUMP_DEVICE,
	SEEK_ERROR_IN_DUMP_FILE,
	WRITE_ERROR_IN_DUMP_FILE,
	UNCOMPRESS_ERROR_IN_DUMP_FILE,
	DUMP_FILE_SIZE_UNDETERMINED,
	DUMP_SETUP_ERROR,
        INVALID_DEVNUM,
        MISSING_UNIT,
        PARTIAL_DUMP,
	NOMEMORY,
	WRITE_ERR_IN_SEG_MAPS,
	WRITE_ERROR_IN_DUMP_NOTES,
	INVALIDATE_PRI_HEADER
};

/*
 * struct DumpDevice: Representation of the dump device and the dump.
 *
 * Host data: 		device contents (headers etc)
 * Coredump data :	dump info
 *
 * struct fields:
 *
 * page_offset: (Crashdump only) Offset in the leniar address space where
 * 		the kernel is mapped.
 *
 * header: The core dump header (for kernel crashdump this is fixed at at 
 *	   DISK_DUMP_STARTOFF. For application dumps this varies based on 
 *	   diskdump block map)
 *
 * sub_header:  (Crashdump only)  - Currently stores the crashing thread's
 * 		register state.
 *
 * bitmap, bitmap_len (Crashdump only) Used to represent the valid pages 
 * 		in the crashdump
 *
 * msgbuf, msgbuf_len :  Contents of the dmesg buffer at the time of crashdump.
 *
 *
 * segments, num_segments: (Crashdump only) Groups of valid pages (each called
 * 			   a segment)
 *
 * device_fd: Descriptor the dump device.
 *
 * dumpfile_fd: Dump file descriptor. This is needed to fsync() the file 
 *              perodically.
 *
 * fp_popen:  FILE stream to popen() [Running gzip to save comprssed corefile]
 *
 * dumpfile_off: File offset in the popen() stream.
 *
 * data_offset: Offset of the data segment in the generated coredump.
 *
 * device_page_start: Start offset of the valid pages.
 *
 * appdump_startoff: 	 Starting offset of the application dump. 
 *
 * appdump_lastbmap_idx: Multiple application corefiles can be saved on the 
 * 			 dump device. This is used to checkoff visited 
 *			 block maps. 
 * dump_dir: Location of the generated coredump 
 *
 * device_name: Crashdump device name
 *
 * file_name: Generated coredump file name.
 */ 
struct _DumpDevice {

	/* Host data */
	long			page_offset;
	struct disk_dump_header	*header;
	struct disk_dump_sub_header	*sub_header;


	char			*bitmap;
	int			bitmap_len;
	char			*dumpable_bitmap;

	char			*msgbuf;
	int			msgbuf_len;

	int			byte, bit;

	struct mem_segment	*segments;
	int			 num_segments;

	/* Coredump data: */
	int			 device_fd;
	int			 dumpfile_fd; /* fd for the dump file */
	FILE 			 *fp_popen;   /* popen() FILE stream  */
	size_t			 dumpfile_off;
	size_t			 data_offset;
	size_t			 device_page_start;

	off_t			 appdump_startoff;   
	int			 appdump_lastbmap_idx; 

	const char		*dump_dir;
	char			*device_name;
	char			*file_name;
};

typedef struct _DumpDevice DumpDevice;

#define Err(x, ...)	fprintf(stderr, "%s: " x, "mypart", ## __VA_ARGS__)
#define Syserr(x, ...)	fprintf(stderr, "%s: unable to " x ": %s\n",\
					"mypart", ## __VA_ARGS__, strerror(errno))
#define Info(x...)	do { if (verbose) fprintf(stderr, x); } while (0)

#endif /* MYPART_H */

