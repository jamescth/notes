#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

main()
{
	FILE	*fd;

	pid_t	pid;
	char	name[128];
	char	sts;

	int	ret;

	if ((fd = fopen("/proc/19957/stat", "r")) == NULL) {
		printf("open failed\n");
		exit(1);
	}

	ret = fscanf(fd, "%d %s %c", &pid, name, &sts);

	printf("ret %d pid %d name %s sts %c\n",
		ret, pid, NULL, sts);

	printf("1\n");
	//fseek(fd, 0, SEEK_SET);

	memset(name, '\0', sizeof(name));
	ret = fscanf(fd, "%d %s %c", &pid, NULL, &sts);

	printf("ret %d pid %d name %s sts %c\n",
		ret, pid, name, sts);

}
