#include <stdio.h>

#ifndef CONFIG_DDR
# define CONFIG_LINUX
#endif

#
main()
{

#ifdef CONFIG_DDR
	printf("def CONFIG_DDR \n");
#endif

#ifdef CONFIG_LINUX
	printf("def CONFIG_LINUX \n");
#endif

#ifndef CONFIG_DDR
	printf("ndef CONFIG_DDR \n");
#else
	printf("def CONFIG_DDR \n");
#endif


}
