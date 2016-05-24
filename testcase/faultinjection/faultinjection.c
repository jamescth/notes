#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kernel.h>
#include <linux/nmi.h>
#include <linux/notifier.h>



static void nullpointer_write(void)
{
    long* p;

    printk(KERN_INFO "fault injection: null pointer write...\n");
    p = (long*)0x0;

    *p = 1000;
}

long _dummy;
static void nullpointer_read(void)
{
    long* p;

    printk(KERN_INFO "fault injection: null pointer read...\n");
    p = (long*)0x0;
    _dummy = *p;
}

/* softlockup: interrupt is enabled, but scheduling cannot happen
 * somehow
 */
static void softlockup(void)
{
    int this_cpu = raw_smp_processor_id();
    printk(KERN_INFO "fault injection: softlockup on cpu %d...\n", 
            this_cpu);
    while(1)
        ;
}

static int __loop_forever(struct notifier_block* this, unsigned long event,
                    void* ptr)
{
    printk(KERN_INFO "fault injection: loop forever now ...\n");
    for (;;)
        ;

    return 0;
}

static void call_panic(void)
{
    panic("panic called from faultinjection.ko");
}

static struct notifier_block hang_on_panic_block = {
	.notifier_call = __loop_forever,
};

static void hang_on_panic(void)
{        
    printk(KERN_INFO "registering hang_on_panic notifier callback...\n");
    atomic_notifier_chain_register(&panic_notifier_list, 
            &hang_on_panic_block);
}

#define FAULT_NULLPOINTER_READ 0
#define FAULT_NULLPOINTER_WRITE 1
#define FAULT_SOFTLOCKUP 2
#define HANG_ON_PANIC 3  /* register a notifier that hangs on panic */
#define CALL_PANIC 4  /* call panic */

static int fault_type = CALL_PANIC;
module_param(fault_type, int, 0644);
MODULE_PARM_DESC(fault_type, "fault_type: nullpointer_read(0) "
    "nullpointer_write(1) softlockup(2) hang_on_panic(3) call_panic(4)");

static int my_init(void)
{
    if (fault_type == FAULT_NULLPOINTER_READ) {
        nullpointer_read();
    } else if (fault_type == FAULT_NULLPOINTER_WRITE) {
        nullpointer_write();
    } else if (fault_type == FAULT_SOFTLOCKUP) {
        softlockup();
    } else if (fault_type == HANG_ON_PANIC) {
        hang_on_panic();
    } else if (fault_type == CALL_PANIC) {
        call_panic();
    } else {
        printk(KERN_INFO "unknown fault_type: %d\n", fault_type);
    }
    return 0;
}

static void my_cleanup(void)
{
    printk(KERN_ERR "we didn't die???\n");
}


module_init(my_init);
module_exit(my_cleanup);

MODULE_LICENSE("GPL");
