#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>
#include <errno.h>
#include <ctype.h>		// isspace()
#include <strings.h>
#include <string.h>		// memset()

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "mypart.h"

//#define JAMES

#ifdef JAMES
#define james	printf
#else
#define james
#endif

/*Change this value if the kernel page size changes*/
#define PAGE_SIZE 4096

#define LINEBUF_SIZE    1024

/* asm-x86_64/page.h */
#define PAGE_OFFSET		0xffff810000000000UL

/*
 * The list of all devices; a device is arbitrarily
 * assigned to either the mirror list of primary list
 */
DumpDevice  *dump_primary[MAX_DUMPUNITS];
DumpDevice  *dump_mirror[MAX_DUMPUNITS];
DumpDevice  *device_list[MAX_DUMPUNITS];

/*
 * For the purposes of backward compatibility, if we can't
 * get the list of head unit disks, just use a-o as a default
 */
void
set_default_disklist(char *linebuf, int len, char *devname[])
{
    char    *buf;
    int      i, ch, devlen;

    for (i=0; i<NUM_DUMPDEVS; i++) {
        devname[i] = NULL;
    }

    buf = linebuf;
    ch = 'a';
    for (i=0; i<NUM_DUMPDEVS; i++) {
        devlen = sprintf(buf, "/dev/sd%c2", ch++);
        devname[i] = buf;

        buf += (devlen + 1);        /* inc null */
    }
}

/*
 * Get the list of head unit disks to use
 */
int
get_disklist(char *linebuf, int len, char *devname[])
{
    FILE    *fp;
    char    *cp, *dev;
    int      i;

    for (i=0; i<NUM_DUMPDEVS; i++) {
        devname[i] = NULL;
    }

    /*
     * Single line output from script. The line consists of
     * device names like '/dev/sda2 /dev/sdb2 /dev/sdc2' etc
     */
    fp = popen("/usr/sbin/config_savecore", "r");
    if (fp == NULL) {
        return ENOENT;
    }

    bzero(linebuf, len);
    cp = fgets(linebuf, len, fp);
    //james
    james("linebuf %s\n", linebuf);

    (void)pclose(fp);

    if (cp == NULL) {
        return EINVAL;
    }

    linebuf[len - 1] = '\0';

    i = 0;
    while (*cp) {
        while (isspace(*cp) && *cp != '\0') {
            cp++;
        }
        if (*cp == '\0') {
            break;
        }

        dev = cp;
        while ((*cp == '/' || isalnum(*cp)) && *cp != '\0') {
            cp++;
        }
        *cp++ = '\0';
        devname[i++] = dev;

        if (i >= NUM_DUMPDEVS) {
            break;
        }
    }

    return 0;
}

static DumpDevice *create_new_device(const char *device_name)
{
	DumpDevice *device;

	device = malloc(sizeof(DumpDevice));
        if (device == NULL) {
            goto out;
        }
	memset(device, 0, sizeof(DumpDevice));

	device->device_name = strdup(device_name);

	device->device_fd = -1;
	device->appdump_lastbmap_idx = -1; 
			/* set to -1 so do_appdump starts off with idx 0 */

	/* Lame default. should be read from kernel */
	device->page_offset = PAGE_OFFSET;

out:
	return device;
}

static int open_device_file(DumpDevice *device, long mode)
{
	int fd;

	if ((fd = open(device->device_name, mode)) < 0) {
		return FAILED;
	}
	device->device_fd = fd;
	return SUCCEEDED;
}

/*
 * Build the list of available crash devices.
 */
int
build_devices(void)
{
        char            *devname[NUM_DUMPDEVS];
        char            linebuf[LINEBUF_SIZE];
	int		i = 0, error = 0;

        for (i=0; i<MAX_DUMPUNITS; i++) {
        	dump_primary[i] = NULL;
        	dump_mirror[i] = NULL;
		device_list[i] = NULL;
        }

        if (get_disklist(linebuf, LINEBUF_SIZE, devname)) {
                Err("Can not get savecore disks, using defaults \n");
                set_default_disklist(linebuf, LINEBUF_SIZE, devname);
        }

        for (i=0; i<NUM_DUMPDEVS; i++) {
	        if (devname[i] == NULL) {
                    continue;
                }

                /*
                 * The stack variable devbuf is strdup'ed in create_new_device
		 * so that it isn't reused.
                 */
                device_list[i] = create_new_device(devname[i]);
                if (device_list[i] == NULL) {
                    Err("unable to create a device.\n");
	            error = DUMP_SETUP_ERROR;
	            break;
	        }
		if (open_device_file(device_list[i], O_RDWR) < 0) {
                        free(device_list[i]);
			device_list[i] = NULL;
			continue;
		}
	}
	return error;
}

static 
print_devices()
{
	int i;

        for (i=0; i<NUM_DUMPDEVS; i++) {
		if (device_list[i] == NULL)
			break;
		printf("devname %s ", device_list[i]->device_name);
		printf("devfd %d ", device_list[i]->device_fd);
		printf("\n");
	}
}

static
p2_write()
{
	/*
	 * We want to write to 1G offset in P2.
	 */
}

main()
{
  	int     error = NO_PANIC_DUMP_HEADER;
	int	i, found = 0, retval = NO_PANIC_DUMP_HEADER;
	int	ret;

	/* build devices */
	ret = build_devices();
	assert(ret == 0);

	print_devices();

	p2_write();
}
