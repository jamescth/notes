#ifndef DUMPDEVICE_H
#define DUMPDEVICE_H

#include <stdbool.h>
#include "dumpheader.h"
#include "arch/arch_dumpdevice.h"

typedef struct _DumpDevice DumpDevice;

struct mem_segment {
	unsigned int	blk;
	unsigned int	len;
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



#endif
