#KDIR = /auto/builds/main/415499/os/linux-2.6.23
#KDIR = /auto/builds/5.4.0B/404909/os/linux-2.6.23
KDIR = /auto/builds/5.5/443084/os/linux-2.6.23

EXTRA_CFLAGS += $(CFLAGS_EXTRA)
obj-m += dd_knet.o
dd_knet-objs += dd_kprobe.o 

all:
	make -C $(KDIR) M=$(PWD) modules
clean:
	make -C $(KDIR) M=$(PWD) clean
