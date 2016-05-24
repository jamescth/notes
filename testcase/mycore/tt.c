#include <stdio.h>	// printf
#include <stdlib.h>	// exit
#include <unistd.h>	// getopt

#include <sys/time.h>
#include <time.h>

long todiff(struct timeval *tod1, struct timeval *tod2)
{
	long t1, t2;
	t1 = tod1->tv_sec * 1000000 + tod1->tv_usec;
	t2 = tod2->tv_sec * 1000000 + tod2->tv_usec;
	return t1 - t2;
}

main(int argc, char **argv)
{
	int c;
	int digit_optind = 0;
	int aopt = 0;
	int bopt = 0;
	char *copt = 0, *dopt = 0;
	int this_option_optind;

	struct timeval tod1, tod2;
	clock_t	t1, t2;

	t1 = clock();
	gettimeofday(&tod1, NULL);

	while ((c = getopt(argc, argv, "abc:d:012")) != -1) {
		this_option_optind = optind ? optind : 1;
		switch(c) {
		case '0':
		case '1':
		case '2':
			if (digit_optind != 0 && digit_optind != this_option_optind)
				printf("digits occur in two different argv-elements.\n");

			digit_optind = this_option_optind;
			printf("option %c, digit_optind %d\n", c, digit_optind);
			break;

		case 'a':
			printf("option a\n");
			aopt = 1;
			break;
		case 'b':
			printf("option b\n");
			bopt = 1;
			break;
		case 'c':
			printf("option c with value '%s'\n", optarg);
			copt = optarg;
			break;
		case 'd':
			printf("option d with value '%s'\n", optarg);
			dopt = optarg;
			break;
		case '?':
			break;
		default:
			printf("?? getopt returned character code 0%o ??\n", c);
		}
	}

	if (optind < argc) {
		printf ("non-option ARGV-element: ");
		while (optind < argc)
			printf("%s ", argv[optind++]);
		printf("\n");
	}

	t2=clock();
	gettimeofday(&tod2, NULL);

	printf("timeofday %5.2f seconds, clock %5.2f seconds.\n",
		todiff(&tod2, &tod1) / 1000000.0,
		(t2-t1)/(double)CLOCKS_PER_SEC);
}
