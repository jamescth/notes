#include <linux/kernel.h>
#include <linux/module.h>

// The probed addr is given by the user script
// The user script scans /proc/kallsyms
int init_module(void)
{
	console_verbose();

	return 0;
} // init_module

void cleanup_module(void)
{
	printk("module removed\n");
}

MODULE_LICENSE("GPL");
