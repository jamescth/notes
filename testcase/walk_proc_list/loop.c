#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

main()
{
	int	fd;
	int	ret;
	char	MINI[]={"minidump"};
	FILE	*fp;

	printf("pid is %d\n", getpid());

	fd = open("/proc/diskdump", O_RDWR, 0);

	if (fd < 0) {
		printf("open failed\n");
		exit(1);
	}

	ret = write(fd, "minidump", 8);

	if (ret < 0) {
		printf("write failed ret %d\n", ret);
		exit(1);
	}
#if 0
	fp = fopen("/proc/diskdump", "r+");
	if (fp == NULL) {
		printf("fopen failed\n");
		exit(1);
	}

	fwrite("minidump", 8, 1, fp);
#endif
	//kill(getpid(), SIGSTOP);
	abort();
}
