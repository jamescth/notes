#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

#define M		(1 << 20)
#define K		(1 << 10)
#define BUF_SIZE	(1 * K)

#define READ		0
#define WRITE		1

void access_device(char *dev, int rw)
{
	int	fd;
	char	*buf;
	ssize_t	ret;

	buf = malloc(BUF_SIZE);

	if (buf == NULL) {
		printf("malloc failed\n");
		exit(1);
	}

	fd = open(dev, O_RDWR);
	// fd = open(dev, O_RDONLY);

	if (fd < 0) {
		printf("open device failed %s %d\n", dev, fd);
		exit(5);
	}
	
	if (rw) {
		ret = write(fd, buf, BUF_SIZE);
	} else {
		ret = read(fd, buf, BUF_SIZE);
	}

	if (ret != BUF_SIZE) {
		printf("something is wrong\n");
		exit(10);
	}

	printf("%x %x\n", buf[510], buf[551]);
	close(fd);
}

main()
{
	access_device("/dev/sda1", READ);
	access_device("/dev/sdb1", READ);
	access_device("/dev/sdc1", READ);
	
	access_device("/ddr/var/home/sysadmin/tt", WRITE);
}
