#include <stdio.h>
#include <signal.h>
#include <stdlib.h>	// exit()
#include <string.h>	// memset()
#include <sys/stat.h>
#include "fcntl.h"

main()
{
	int	fd;

	fd = open("/proc/diskdump", O_RDWR, 0);
	if (0 <= fd) {
	        write(fd, "dump", 5);

		write(fd, "minidump", 8);
        	close(fd);
	}

}
