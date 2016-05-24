#include <stdio.h>
#include <stdlib.h>	// exit()
#include <sys/types.h>
#include <sys/stat.h>
#define _XOPEN_SOURCE 500
#include <unistd.h>
#include <fcntl.h>
#include <string.h>	// memset()
#include <pthread.h>
#include <errno.h>

#define NUM_THREADS	100
#define FILE_PATH	"/mnt/usb/"
#define FILE_SIZE	256
#define DATA_SIZE	4096
#define LOOP		30000

struct flock 	f;
pthread_t	thread[NUM_THREADS];
char		data[DATA_SIZE] = {0};

void
init_flock(void)
{
	f.l_type = F_RDLCK;
	f.l_whence = SEEK_SET;
}

void
write_data(int fd)
{
	int	ret;
	off_t	off;

	off = lseek(fd, 0, SEEK_SET);
	if (off != 0) {
		printf("file lseek failed %d %d %d\n", pthread_self(), off, errno);
		exit(off);
	}

	ret = write(fd, data, DATA_SIZE);
	if (ret != DATA_SIZE) {
		printf("file write failed %d %d %d\n", pthread_self(), ret, errno);
		exit(ret);
	}

}

void *
thread_runner(void *threadid)
{
	long	tid = (long) threadid;
	char	file_name[FILE_SIZE];
	int	ret;
	int	fd;
	int	index;

	ret = sprintf(file_name,"%scon_write.%d_%d", FILE_PATH, getpid(), pthread_self());
	if ( ret < 0) {
		printf("sprintf failed %d\n", ret);
		exit(ret);
	}
	printf("thread runner #%ld %s\n", tid, file_name);

	fd = open(file_name, O_RDWR | O_CREAT | O_SYNC);
	if (fd < 0) {
		printf("file open failed %d %d %d\n", pthread_self(), ret, errno);
		exit(ret);
	}
	printf("%s is opened w/ fd %d\n", file_name, fd);

	for (index = 0 ; index < LOOP ; index ++) {
		write_data(fd);
		//sleep(1);
	}

	ret = close(fd);
	if (ret < 0) {
		printf("file close failed %d %d %d\n", pthread_self(), ret, errno);
		exit(ret);
	}

	printf("thread runner #%ld close\n", tid, file_name);
	pthread_exit(NULL);
}

main()
{
	int	ret;
	long	th;
	int	index;
	char	*mem = "B16B00B5";
	int	mem_pattern = 0xB16B00B5;

	for ( index = 0 ; index < DATA_SIZE ; ) {
		//data[index++] = 0xb5;
		//data[index++] = 0x00;
		//data[index++] = 0x6b;
		//data[index++] = 0xb1;
		data[index++] = 'b';
		data[index++] = '1';
		data[index++] = '6';
		data[index++] = 'b';
		data[index++] = '0';
		data[index++] = '0';
		data[index++] = 'b';
		data[index++] = '5';
	}
	
	// create threads	
	for (th = 0 ; th < NUM_THREADS ; th++) {
		printf("In main: creating thread %'d\n", th);

		ret = pthread_create(&thread[th], NULL, 
					thread_runner, (void *) th);

		if (ret) {
			printf("pthread create failed %d\n", ret);
			exit(1);
		}
	}

	// wait for threads to finish
	for (th = 0 ; th < NUM_THREADS ; th++) {
		ret = pthread_join(thread[th], NULL);

		if (ret) {
			printf("pthread join failed %d %d\n", th, ret);
			exit(1);
		}
	}
	exit(0);
}
