#ifndef _DD_KPERF_H
#define _DD_KPERF_H

#include <linux/kernel.h>
#include <linux/module.h>
//#include <asm-x86_64/atomic.h>

#define ALLOCATED_SIZE		4096
#define ENTRY_SIZE		8

#define ASSERT_CONCAT_(a, b)	a##b
#define ASSERT_CONCAT(a, b)	ASSERT_CONCAT_(a, b)
#define ct_assert(e)	enum { ASSERT_CONCAT(assert_line_, __LINE__) = 1/(!!(e)) }

// time stamp
#define TIME_STAMP_BYTES(time)	(time & 0xffff)
#define TIME_SHIFT_ORDER	((sizeof(long) - (2 * sizeof(char))) * sizeof(long))

enum {
	PER_CPU_BUF_ENTRY = 1024
};

struct dd_kperf_percpu {
	void		*dd_kp_buf;
	size_t		dd_kp_bufsize;		// used for debug purpose to check boundry
	unsigned long	dd_kp_index;		// change to atmoic?  tool/cpu can access at the same time
	unsigned long	dd_kp_ver;
};

void test(void);
int dd_kprobe_init(void);
void dd_kprobe_exit(void);

// frame
enum components {
	DKLOG_KERNEL,
	DKLOG_NET,
	DKLOG_SAS,
	DKLOG_VTL,
	DKLOG_COMP_MAX
};

char *Comp_Strings[] = {
	"KERNEL",
	"NET",
	"SAS",
	"VTL"
};

// per component
enum comp1_func {
	LOC1,
	LOC2,
	LOC3,
	LOC_MAX
};

char *comp1_func_str[] = {
	"LOC1",
	"LOC2",
	"LOC3"
};

enum msgs {
	NONE,
	INIT,
	ENTER,
	EXIT,
	FAIL,
	ERROR,
	PANIC,
	MSG_MAX
};

char *msg_Strings[] = {
	"None",
	"INIT",
	"ENTER",
	"EXIT",
	"FAIL",
	"ERROR",
	"PANIC"
};

struct dklog {
	char	*dklog_name;		// component name
	char	**dklog_func;		// component defined func
	char	**dklog_msg;		// component defined msg
};

struct dklog	my_dk[DKLOG_COMP_MAX];
#endif
