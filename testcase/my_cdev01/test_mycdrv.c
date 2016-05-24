#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
	int length, fd1, fd2, rc;

	char *nodename = "/dev/mycdrv";
	char message[] = "*** TESTING CHAR/DRIVER ***\n";

	length = sizeof(message);

	if (argc > 1)
		nodename = argv[1];

	fd1 = open(nodename, O_RDWR);
	printf(" opened file descriptor 1st time  = %d\n", fd1);

	fd2 = open(nodename, O_RDWR);
	printf(" opened file descriptor 2nd time = %d\n", fd2);

	rc = write(fd1, message, length);
	printf("return code from write = %d on %d, message=%s\n",
		rc, fd1, message);

	memset(message, 0, length);

	rc = read(fd2, message, length);
	printf("return code from read = %d on %d, message=%s\n",
		rc, fd2, message);

	close (fd1);
	close (fd2);
	exit(0);
}
