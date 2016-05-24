#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

main()
{
	printf("pid is %d\n", getpid());
	while(1);
}
