KDIR = /auto/builds/main/415499/os/linux-2.6.23

EXTRA_CFLAGS += $(CFLAGS_EXTRA)
obj-m += dd_kperf.o
dd_kperf-objs += dd_kprobe.o dd_init.o

all:
	make -C $(KDIR) M=$(PWD) modules
clean:
	make -C $(KDIR) M=$(PWD) clean
