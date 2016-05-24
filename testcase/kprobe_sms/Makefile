#KDIR = /auto/builds/main/415499/os/linux-2.6.23
#KDIR = /auto/builds/5.4.0B/404909/os/linux-2.6.23
KDIR = /auto/builds/5.5/442324/os/linux-2.6.23

EXTRA_CFLAGS += $(CFLAGS_EXTRA)
obj-m += dd_kptest.o
dd_kptest-objs += dd_kp_sms.o 

all:
	make -C $(KDIR) M=$(PWD) modules
clean:
	make -C $(KDIR) M=$(PWD) clean
