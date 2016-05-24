#include <stdio.h>

// mem
#include <sys/mman.h>	// mlock()
#include <stdlib.h>	// malloc()
#include <string.h>	// memcpy()

// file related
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

// rlimit()
#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>

// time
#include <sys/time.h>

#define roundup(x, y) ((((x) + ((y) - 1)) / (y)) * (y))
#define GB	(1<<30)
main()
{
	// file related
	int		fd;
	char		*fname = "dummy_core";
	int		page_size = sysconf(_SC_PAGE_SIZE);
	struct stat	statbuf;
	size_t		file_size = 0;

	struct rlimit	rlimit;

	// time
	struct timeval	start_time, end_time;
	long		mtime, seconds, useconds;

	char		*buf, *mem_buf;
	size_t		read_size = 0;
	size_t		total_size = 0;
	int		index = 0;

	// set rlimit for memory
	rlimit.rlim_max = RLIM_INFINITY;
	rlimit.rlim_cur = RLIM_INFINITY;
	if (setrlimit(RLIMIT_AS, &rlimit) < 0) {
		fprintf(stderr,"setrlimit RLIMIT_AS failed!\n");
		_exit(2);
	}

	if (setrlimit(RLIMIT_DATA, &rlimit) < 0) {
		fprintf(stderr,"setrlimit RLIMIT_DATA failed!\n");
		_exit(2);
	}

	if (setrlimit(RLIMIT_MEMLOCK, &rlimit) < 0) {
		fprintf(stderr,"setrlimit RLIMIT_MEMLOCK failed!\n");
		_exit(2);
	}

	if (setrlimit(RLIMIT_RSS, &rlimit) < 0) {
		fprintf(stderr,"setrlimit RLIMIT_RSS failed!\n");
		_exit(2);
	}

	if ((fd = open(fname, O_RDONLY)) < 0) {
		fprintf(stderr,"dcore: open(%s) failed!\n", fname);
		_exit(2);
	}
	if (fstat(fd, &statbuf) < 0) {
		fprintf(stderr,"dcore: stat(%s) failed!\n", fname);
		_exit(2);
	}
	file_size = roundup(statbuf.st_size, page_size);

	printf("file_size is %ld\n", file_size);

	if (file_size > (size_t)(35 * (size_t)GB) ) {
		file_size = (size_t) (35 * (size_t)GB);
	}

	if ((buf = malloc(file_size)) == NULL) {
		fprintf(stderr, "buf malloc failed\n");
		_exit(2);
	}

	if ((mem_buf = malloc(file_size)) == NULL) {
		fprintf(stderr, "mem_buf malloc failed\n");
		_exit(2);
	}

	if (mlock(buf, file_size)) {
		fprintf(stderr, "buf mlock failed\n");
		_exit(2);
	}

	if (mlock(mem_buf, file_size)) {
		fprintf(stderr, "mem_buf mlock failed\n");
		_exit(2);
	}

	// start testing
	printf("start loading...\n");

	while (total_size < file_size) {
		read_size = read(fd, buf+total_size , GB);

		if ( read_size != GB ) {
			fprintf(stderr, "read_size %ld doesn't match file_size %ld\n",
			read_size, file_size);
		}

		total_size += read_size;
		index++;

		printf("%d %ld\n", index, total_size);
	}

	if (total_size != file_size) {
			fprintf(stderr, "total_size %ld doesn't match file_size %ld\n",
			total_size, file_size);
	}

	printf("read %ld bytes to memory\n", total_size);
	printf("start memcpy\n");

	gettimeofday(&start_time, NULL);
	memcpy(mem_buf, buf, total_size);
	gettimeofday(&end_time, NULL);

	seconds = end_time.tv_sec - start_time.tv_sec;
	useconds = end_time.tv_usec - start_time.tv_usec;

	mtime = seconds * 1000 + (useconds/1000);

	printf("total time in msec is %ld\n", mtime);
#if 0
	read_size = read(fd, buf, file_size);

	if ( read_size != file_size ) {
		fprintf(stderr, "read_size %ld doesn't match file_size %ld\n",
			read_size, file_size);
	}

	printf("read %ld bytes to memory\n", read_size);
#endif

}
