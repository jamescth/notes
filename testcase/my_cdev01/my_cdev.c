#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/init.h>
#include <linux/slab.h>

#define MYDEV_NAME	"mycdrv"

static int		size =PAGE_SIZE;
static dev_t 		first;
static unsigned int 	count = 1;
static int 		my_major = 700, my_minor = 0;
static struct cdev 	*my_cdev;
static size_t 		ramdisk_size = (16 * PAGE_SIZE);

static struct kmem_cache	*my_cache;
module_param(size, int, S_IRUGO);

static int mycdrv_open(struct inode *inode, struct file *file)
{
	static int counter = 0;
	char *ramdisk = kmalloc(ramdisk_size, GFP_KERNEL);
	if (ramdisk == NULL) {
		printk(KERN_ERR "kmalloc() failed\n");
		return -1;
	}

	file->private_data = ramdisk;

	printk(KERN_INFO " attemping to open device: %s:\n", MYDEV_NAME);
	printk(KERN_INFO " MAJOR number = %d, MINOR number = %d\n",
		imajor(inode), iminor(inode));
	counter++;

	printk(KERN_INFO " successfully open device: %s:\n\n", MYDEV_NAME);
	printk(KERN_INFO " counter %d\n", counter);
	printk(KERN_INFO " ref=%d\n", module_refcount(THIS_MODULE));

	return 0;
}

static int mycdrv_release(struct inode *inode, struct file *file)
{
	char *ramdisk = file->private_data;

	if (file->private_data == NULL) {
		printk(KERN_ERR " No private data\n");
		return -1;
	}

	printk(KERN_INFO " CLOSING device: %s:\n\n", MYDEV_NAME);

	kfree(ramdisk);
	return 0;
}

static ssize_t
mycdrv_read(struct file *file, char __user * buf, size_t lbuf, loff_t *ppos)
{
	char *ramdisk = file->private_data;
	int nbytes = lbuf - copy_to_user(buf, ramdisk + *ppos, lbuf);
	*ppos += nbytes;

	printk(KERN_INFO "\n READING function, nbytes=%d, pos=%d\n",
		nbytes, (int)*ppos);
	return nbytes;
}

static ssize_t
mycdrv_write(struct file *file, const char __user * buf, size_t lbuf,
		loff_t *ppos)
{
	char *ramdisk = file->private_data;
	int nbytes = lbuf - copy_from_user(ramdisk + *ppos, buf, lbuf);
	*ppos += nbytes;
	printk(KERN_INFO "\n WRITING function, nbytes=%d, pos=%d\n", nbytes,
		(int)*ppos);
	return nbytes;
}

static const struct file_operations mycdrv_fops = {
	.owner	= THIS_MODULE,
	.read	= mycdrv_read,
	.write	= mycdrv_write,
	.open	= mycdrv_open,
	.release = mycdrv_release,
};

static int __init my_init(void)
{
	first = MKDEV(my_major, my_minor);

	if (register_chrdev_region(first, count, MYDEV_NAME) < 0) {
		printk(KERN_ERR "failed to register character device region\n");
		return -1;
	}
#if 0
	if (size > (1024 * PAGE_SIZE)) {
		printk(KERN_INFO " size=%d is too large; you can't have more than 1024 pages!\n",
			size);
	}

	if (!(my_cache = kmem_cache_create("mycache", size, 0,
					SLAB_HWCACHE_ALIGN, NULL))) {
		printk(KERN_ERR "kmem_cache_create failed\n");
		return -ENOMEM;
	}
	printk(KERN_INFO "allocated memory cache correctly\n");
#endif


	if (!(my_cdev = cdev_alloc())) {
		printk(KERN_ERR "cdev_alloc() failed\n");
		unregister_chrdev_region(first, count);
		return -1;
	}

	cdev_init(my_cdev, &mycdrv_fops);

	if (cdev_add(my_cdev, first, count) < 0) {
		printk(KERN_ERR "cdev_add() failed\n");
		cdev_del(my_cdev);
		unregister_chrdev_region(first, count);
		return -1;
	}

	printk(KERN_INFO "\nSucceeded in registering character device %s\n",
		MYDEV_NAME);

	return 0;
}

static void __exit my_exit(void)
{
	if (my_cdev)
		cdev_del(my_cdev);

	unregister_chrdev_region(first, count);
	printk(KERN_INFO "\ndevice unregistered %s\n", MYDEV_NAME);
}

module_init(my_init);
module_exit(my_exit);

MODULE_LICENSE("GPL");
