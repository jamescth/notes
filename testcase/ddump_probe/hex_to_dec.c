/*
 * A test program for hex string to int
 */
#include <stdio.h>

char test[]="ffffffff88125dee";

char xtod(char c)
{
	if (c>='0' && c<='9') {
		return (c-'0');
	}
	else if (c>='A' && c<='F') {
		return (c-'A'+10);
	}
	else if (c>='a' && c<='f') {
		return (c-'a'+10);
	}

	return (c=0);
}

unsigned long HextoDec(char *hex)
{
	if (*hex==0)
		return 0;
	return HextoDec(hex-1)*16 + xtod(*hex);
}

unsigned long xstrtoi(char *hex)
{
	return HextoDec(hex+strlen(hex)-1);
}

main()
{
	char *input;
	unsigned long i;

	i = xstrtoi(test);

	printf("i is %ld %lx\n", i, i);
	for (i=0; i<sizeof(test); i++) {
		
	}
	
}
