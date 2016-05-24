#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>

main()
{
	char *buf;

	printf("hello, pid is %d\n", getpid());

	//buf = malloc(2<<20);

	while(1);
}
