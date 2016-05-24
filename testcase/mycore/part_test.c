#include <stdio.h>
#include <assert.h>
#include <errno.h>
#include <stdlib.h>	// exit()
#include <string.h>	// memset()
#include <strings.h>	// bzero()
#include <unistd.h>	// fsync()

#include <sys/time.h>	// gettimeofday()

// open()
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define PART2		2
#define PART6		6
#define PART6_TEST	"/ddr/var/core/tt"
#define KB		(1<<10)
#define BUF_SIZE	(512*KB)
#define GB_ITERATION	((1<<30)/BUF_SIZE)

struct cmd_flag
{
	int	cf_part2;
	int	cf_part6;
	int	cf_repeats;
	int	cf_datasize;
	char *	cf_dev;
};

// default flag values
struct cmd_flag	flags = {0,0,1,5,0};

usage()
{
	printf("\n******************\n");
	printf("part_test -[option]\n");
	printf("-2        test partition 2 throughput\n");
	printf("-6        test partition 6 throughput\n");
	printf("-d        device\n");
	printf("-r <num>  repeat the throughput test <num> times. \n");
	printf("          The default value is 1.\n");
	printf("-s <size> Config the total writing size in Gb for throughput\n");
	printf("          The default value is 5 Gb.\n");
}

cmd_parsing(int argc, char **argv)
{
	int c;
	int this_option_optind;

	while ((c = getopt(argc, argv, "s:r:d:26")) != -1) {
		this_option_optind = optind ? optind : 1;
		switch(c) {
		case '2':
			flags.cf_part2 = 1;
			break;
		case '6':
			flags.cf_part6 = 1;
			break;
		case 'd':
			flags.cf_dev = optarg;
			break;
		case 's':
			printf("test size is set to '%s' GB\n", optarg);
			flags.cf_datasize = atoi(optarg);
			break;
		case 'r':
			printf("test will repeat '%s' times\n", optarg);
			flags.cf_repeats = atoi(optarg);
			break;
		default:
			printf("?? getopt returned character code 0%o ??\n", c);
			usage();
			exit(11);
		}
	}

	if (optind < argc) {
		printf ("non-option ARGV-element: ");
		while (optind < argc)
			printf("%s ", argv[optind++]);
		printf("\n");
		exit(12);
	}

	if (flags.cf_part2 && (flags.cf_dev == NULL)) {
		printf("\n*******************************************************\n");
		printf("Please use -d to indicate a crash partition for testing\n");
		printf("Here are all the crash devices in the DDR:\n");
		printf("*******************************************************\n");
		system("cat /proc/crashdump_config");
		exit(13);
	}
}

long todiff(struct timeval *tod1, struct timeval *tod2)
{
	long t1, t2;
	t1 = tod1->tv_sec * 1000000 + tod1->tv_usec;
	t2 = tod2->tv_sec * 1000000 + tod2->tv_usec;
	return t1 - t2;
}

part_test(int part)
{
	int	fd;
	int	ret;
	int	i;
	char	buf[BUF_SIZE];
	struct timeval	tod1, tod2;
	double	timediff;
	size_t	size,size1, size2;

	if (part == PART2) {
		fd = open(flags.cf_dev, O_RDWR);
	} else if (part == PART6) {
		fd = open(PART6_TEST, O_CREAT | O_RDWR);
	} else {
		printf("part_test invalid argu %d\n", part);
		exit(5);
	}

	if (-1 == fd) {
		printf("open failed\n");
		printf("%s \n",flags.cf_dev);
		printf("errno is %d\n", errno);
		exit(6);
	}

	bzero(buf, BUF_SIZE);

	// for partition2 test, we start from 100Mb offset
	// to avoid trashing the useful data
	if (flags.cf_part2) {
		if (lseek(fd, 100<<20, SEEK_SET) < 0) {
			printf("lseek failed\n");
			exit(7);
		}
	}

	gettimeofday(&tod1, NULL);

	for ( i=0 ; i < flags.cf_datasize*GB_ITERATION ; i++) {
		ret = write(fd, buf, BUF_SIZE);

		if ( -1 == ret) {
			printf("write failed\n");
			printf("errno is %d\n", errno);
			exit(8);
		}
		if (i%1000 == 0) {
			printf(".");
		}
	}

	fsync(fd);
	gettimeofday(&tod2, NULL);
	timediff = todiff(&tod2, &tod1) / 1000000.0;
	size = (flags.cf_datasize * (long)(1<<30));

	printf("\n part%d test took %5.3f seconds\n", part, timediff);
	printf("zise is %lld throughput is %10.3lf Mb/sec\n",
		size, size / timediff / 1000000);

	close(fd);

}

main(int argc, char *argv[])
{
	int	repeat;

	if (argc < 2) {
		usage();
		exit(1);
	}

	cmd_parsing(argc, argv);

	if (flags.cf_part2) {
		repeat = 1;
		do {
			part_test(PART2);
		} while (repeat++ < flags.cf_repeats);
	}

	if (flags.cf_part6) {
		repeat = 1;
		do {
			part_test(PART6);
		} while (repeat++ < flags.cf_repeats);
	}
}
