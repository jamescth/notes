#include <stdio.h>
#include <signal.h>
#include <stdlib.h>	// exit()
#include <string.h>	// memset()
#include <assert.h>

// stat()
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

static int verbose = 0;

#define CMD  "debug_daemon"

#define Err(x, ...)	do { \
                             if (verbose) \
                                fprintf(stderr, "%s: " x, CMD, ## __VA_ARGS__); \
		             syslog(3, x, ## __VA_ARGS__); \
                        } while (0)

#define Syserr(x, ...)	do { \
                             if (verbose) \
                                fprintf(stderr, "%s: unable to " x ": %s\n",\
                                        CMD, ## __VA_ARGS__, strerror(errno));\
                             syslog(3, "unable to %s", x); \
                        } while (0)

#define Info(x, ...)	do { \
                             if (verbose) \
                                 fprintf(stderr, x); \
                             syslog(5, x, ## __VA_ARGS__); \
                        } while (0)

#define DDFS_BINARY	"/ddr/bin/ddfs"
#define LOOP_BINARY	"/ddr/var/home/sysadmin/loop"

// these DEFINEs are also in diskdump_driver.c
// Linux uses 33 as SIGRTMIN, but, libc uses 34
#define DD_SIGRTMIN	34
#define DD_SIGCRASH	DD_SIGRTMIN
#define DD_SIGMINI	(DD_SIGCRASH+1)
#define DD_SIGGDB	(DD_SIGMINI+1)

#define DD_SIGMAX	DD_SIGGDB

// SIGRTMIN si_codes
#define DD_MINI_DDFS	1
#define DD_MINI_LOOP	2

#define CMD_SIZE	128

enum {DDFS = 1,
      LOOP};

void
sigcrash(void)
{
	char	*command[CMD_SIZE];
	pid_t	pid;
//	int	status;

	memset(command, '\0', sizeof(command));
	command[0] = strdup("/root/crash_daemon");

	if ((pid = fork()) < 0) {
		Err("livedump fork failed\n");
		return ;
	} else if (pid == 0) {
		execvp(command[0], command);
		Err("livedump execv failed\n");
		return;
	}

	//sleep(10);
	//printf("livedump wait for status\n");
	//wait(&status);	
	Info("livedump finished\n");

	return;
}

void sigmini(siginfo_t *info)
{
	char	*command[CMD_SIZE];
	pid_t	pid;
	int	status;
	char		buf[128];

	struct stat 	sts;
	FILE		*fd;
	int		ret;
	char		ch;
	int		i;

	memset(command, '\0', sizeof(command));
	command[0] = strdup("/root/gdb_daemon");
	command[1] = strdup("/ddr/bin/ddfs");
	sprintf(buf, "%d\0", info->si_pid);
	command[2] = strdup(buf);
	command[3] = NULL;
	// printf("%s %s %s\n", command[0], command[1], command[2]);

	if ((pid = fork()) < 0) {
		Err("minidump fork failed\n");
		// send SIGCONT to debugee
		kill(info->si_pid, SIGCONT);

		return ;
	} else if (pid == 0) {
		execvp(command[0], command);
		Err("execv failed\n");
		// send SIGCONT to debugee
		kill(info->si_pid, SIGCONT);
		return;
	}

	sleep(10);

	memset(buf, '\0', sizeof(buf));

	// check stat
	sprintf(buf, "/proc/%d/stat", pid);

	if (stat(buf, &sts)) {
		Err("stat() %s failed\n", buf);
		// send sigcont
		kill(info->si_pid, SIGCONT);
		return;
	}

	if ((fd = fopen(buf, "r")) == NULL) {
		Err("fopen %s failed\n", buf);
		// send sigcont
		kill(info->si_pid, SIGCONT);
		return;
	}

	for ( i = 0 ; i < 10 ; i++ ) {
		memset(buf, '\0', sizeof(buf));
		ret = fscanf(fd, "%d %s %c", &pid, buf, &ch);

		Info("ret %d pid %d name %s status %c\n",
			ret, pid, buf, ch);

		// if gdb is sleeping, GREAT.
		if (ch == 'Z') {
			break;
		}
		sleep(2);
		fseek(fd, 0, SEEK_SET);
	}

	if ( i < 10)
		printf("gdb started\n");
	else
		printf("gdb failed\n");

	fclose(fd);
	// send SIGCONT to debugee
	kill(info->si_pid, SIGCONT);
	wait(&status);
	return;
}

static int
ddfs_verification(siginfo_t *info)
{
	if (info->si_code != DD_MINI_DDFS) {
		Err("%d is not a ddfs thread\n", info->si_pid);
		return 0;
	}

	return 1;
}

void
sig_handler(int sig, siginfo_t *info, void *context)
{
	char	*command[CMD_SIZE];
	pid_t	pid;
	int	status;

	Info("debug daemon %d received sig %d by %d\n",
		getpid(), sig, info->si_pid);

	memset(command, '\0', sizeof(command));


	if (sig == DD_SIGCRASH) {
		sigcrash();
	} else if (sig == DD_SIGMINI) {
		if (!ddfs_verification(info)) {
			return;
		}
		sigmini(info);
	} else if (sig == DD_SIGGDB) {
		if (!ddfs_verification(info)) {
			return;
		}
		Info("nothing to do\n");
	} else {
		Err("Unsupport sig %d\n", sig);
	}

	return;

}

int 
check_running_debug_daemon(void)
{
	FILE 	*fp;
	int	n_instances  = 0;

	if (!(fp = popen("ps -C debug_daemon | grep debug_daemon | wc -l", "r"))) {
		perror("popen() failed!\n");
		return 0;
	}
	fscanf(fp, "%d", &n_instances);

	pclose(fp);

	if (n_instances > 1) {
		return 1;
	} else {
		return 0;
	}
	return 0;
}

main()
{
	struct sigaction 	act, oldact;
	sigset_t		mask;
	int			i;

	// assert SIGRTMIN is 34
	assert(SIGRTMAX >= DD_SIGMAX);

	if (check_running_debug_daemon()) {
		Err("dup'ed daemon! %d terminated.\n", getpid());
		exit(1);
	}

	Info("%d running\n", getpid());

	// block a bunch of signals
	sigaddset(&mask, SIGHUP);
	//sigaddset(&mask, SIGINT);
	sigaddset(&mask, SIGQUIT);
	sigaddset(&mask, SIGABRT);
	sigaddset(&mask, SIGPIPE);
	sigaddset(&mask, SIGALRM);
	sigaddset(&mask, SIGUSR1);
	sigaddset(&mask, SIGUSR2);

	// set up sig hdlr
	memset(&act, '\0', sizeof(act));
	act.sa_sigaction = &sig_handler;
	act.sa_flags = SA_SIGINFO;

	for ( i = SIGRTMIN ; i < SIGRTMAX ; i++) {
		if (i == DD_SIGCRASH || i == DD_SIGMINI || i == DD_SIGGDB) {
			if (sigaction(i, &act, NULL) < 0) {
				Err("sig %d sigaction failed\n", i);
				exit(1);
			}
			continue;
		}
		sigaddset(&mask, i);
	}

	sigprocmask(SIG_BLOCK, &mask, NULL);

	while(1) {
		pause();
	}
}
