#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/notifier.h>

typedef int (*ipmi_s_func)(struct notifier_block *, unsigned long, void *);
typedef void (*new_func)(void);

int init_module(void)
{
	int		ret;
	ipmi_s_func 	my_ipmi_func;
	new_func 	my_new_func;

	// this is for wdog_panic_handler()
	my_ipmi_func = (ipmi_s_func)0xffffffff880b6065;
	// ret = my_ipmi_func(NULL, 0, NULL);

	// this is for wdog_panic_reset_ipmi_timer()
	my_new_func = (new_func)0xffffffff880b6139;
	my_new_func();

	printk("call_s_func ret %d\n", ret);

	return 0;
}

void cleanup_module(void)
{
	printk("call_s_func module removed\n");
}

MODULE_LICENSE("GPL");
