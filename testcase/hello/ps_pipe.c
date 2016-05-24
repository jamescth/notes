#include <stdio.h>
#include <stdlib.h>

main()
{
	FILE *ps_pipe;
	FILE *grep_pipe;

	int bytes_read;
	int nbytes = 4096;
	char *my_string;

	/* open 2 pipes */
	ps_pipe = popen("ps -A", "r");
	grep_pipe = popen("grep init", "w");

	/* check that pipes are non-null, therefore open */
	if ((!ps_pipe) || (!grep_pipe)) {
		fprintf(stderr, "One or both pipes failed.\n");
		return EXIT_FAILURE;
	}

	/* Read from ps_pipe until two newlines */
	my_string = (char *) malloc (nbytes +1);
	bytes_read = getdelim(&my_string, &nbytes, "\n\n", ps_pipe);

	/* close ps_pipe, checking for errors */
	if (pclose(ps_pipe) != 0) {
		fprintf(stderr, "could not run 'ps', or other error.\n");
	}

	/* send output of 'ps -a' to 'grep init', with two newlines */
	fprintf(grep_pipe, "%s\n\n", my_string);

	/* close grep_pipe,  checking for errors */
	if (pclose(grep_pipe) != 0) {
		fprintf(stderr, "could not run 'grep', or other error.\n");
	}

	return 0;

}
