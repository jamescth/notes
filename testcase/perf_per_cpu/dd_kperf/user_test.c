#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>		// malloc()
#include <sys/time.h>

#include "dd_kperf.h"

struct dd_kperf_percpu	dd_kp;

unsigned long dd_clock_gettime(void)
{
	int ret;
	struct timeval tv;

	ret = gettimeofday(&tv, NULL);

	return ((tv.tv_sec * 1000) + (tv.tv_usec/1000));
}

int kp_init(void)
{
	memset(&dd_kp, 0, sizeof(struct dd_kperf_percpu));
	dd_kp.dd_kp_buf = malloc(ALLOCATED_SIZE);
	if (dd_kp.dd_kp_buf == NULL) {
		return ENOMEM;
	}

	dd_kp.dd_kp_bufsize = ALLOCATED_SIZE;
	dd_kp.dd_kp_ver = 1;

	return 0;
}

void dd_exit(void)
{
	if (dd_kp.dd_kp_buf) {
		free(dd_kp.dd_kp_buf);
	}
}

void dd_work(void)
{
	int	index;
	struct dd_kperf_percpu *local_kp = &dd_kp;

//	for (index = 0; index < (ALLOCATED_SIZE/ENTRY_SIZE) ; index++) {
	for (index = 0; index < DKLOG_COMP_MAX; index++) {
		printf("index %d string %s\n", index, Comp_Strings[index]);
	}
}

void reader_init(void)
{
	int	index;

	my_dk[DKLOG_KERNEL].dklog_func = comp1_func_str;
	my_dk[DKLOG_KERNEL].dklog_msg = msg_Strings;
}

void test_reader(void)
{
	int	func_index;
	int	msg_index;

	for ( func_index = 0 ; func_index < LOC_MAX ; func_index++) {
		printf("%s ", my_dk[DKLOG_KERNEL].dklog_func[func_index]);
	}
	printf("\nEnd func\n");

	for ( msg_index = 0 ; msg_index < MSG_MAX ; msg_index++) {
		printf("%s ", my_dk[DKLOG_KERNEL].dklog_msg[msg_index]);
	}
	printf("\nEnd msg\n");
	
}

main()
{
	int	ret;
	long	a = 0xffffffffffffffff;

	if (ret = kp_init()) {
		printf("ret %d\n", ret);
	}

	reader_init();

	printf("a 0x%lx \n& 0x%lx\n s 0x%lx\n",
		a, TIME_STAMP_BYTES(a), TIME_STAMP_BYTES(a)<<TIME_SHIFT_ORDER);

	test_reader();
	// work
	dd_work();

	// read

	// exit
	dd_exit();
}

