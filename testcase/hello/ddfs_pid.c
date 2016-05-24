#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

main()
{
	FILE *ps_pipe;
	int pid;
	int ret;

	int bytes_read;
	int nbytes = 4096;
	char *my_string;

	/* open 2 pipes */
	ps_pipe = popen("pidof ddfs", "r");

	/* check that pipes are non-null, therefore open */
	if (!ps_pipe) {
		fprintf(stderr, "pipes failed.\n");
		return EXIT_FAILURE;
	}

	/* Read from ps_pipe until two newlines */
	my_string = (char *) malloc (nbytes +1);
	bytes_read = getdelim(&my_string, &nbytes, "\n\n", ps_pipe);

	/* close ps_pipe, checking for errors */
	if (pclose(ps_pipe) != 0) {
		fprintf(stderr, "could not run 'pidof', or other error.\n");
		return EXIT_FAILURE;
	}

	pid = atoi(my_string);

	/* send output of 'ps -a' to 'grep init', with two newlines */
	printf("pid is %d\n", pid);

	ret = kill(pid, SIGABRT);

	if (ret) {
		printf("kill failed\n");
		exit(10);
	}

	sleep(2);

	ret = kill(pid, SIGABRT);

	if (ret) {
		printf("kill failed\n");
		exit(12);
	}

	return 0;

}
