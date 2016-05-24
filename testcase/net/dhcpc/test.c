#include <stdio.h>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/socket.h>

#include <string.h>		// memset
#include <linux/in6.h>		// sockaddr_in6
#include <linux/net.h>		// SOCK_DGRAM
#include <linux/socket.h>	// PF_INET6
#include <linux/in.h>		// IPPROTO_UDP

#define DHCP6_CLIENT_PORT	546
#define DHCP6_SERVER_PORT	547

main()
{
	struct sockaddr_in6	sa;
	int			fd;
	int			n;
	ssize_t 		bytes;
	struct msghdr 		msg;

	memset(&sa, 0, sizeof(sa));
	sa.sin6_family = AF_INET6;
	sa.sin6_port = htons(DHCP6_CLIENT_PORT);

	if ((fd = socket(PF_INET6, SOCK_DGRAM, IPPROTO_UDP)) == -1) {
		printf("socket() failed\n");
		exit(1);
	}

	printf("fd is %d\n", fd);

	n=1;
	if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR,
	    &n, sizeof(n)) == -1) {
		printf("SO_REUSEADDR failed\n");
		exit(1);
	}

	n = 1;
	if (setsockopt(fd, SOL_SOCKET, SO_BROADCAST,
	    &n, sizeof(n)) == -1) {
		printf("SO_BROADCAST failed\n");
		exit(1);
	}

	if (bind(fd, (struct sockaddr *)&sa, sizeof(sa)) == -1) {
		printf("bind() failed\n");
		exit(1);
	}

	n = 1;
	if (setsockopt(fd, IPPROTO_IPV6, IPV6_PKTINFO,
	    &n, sizeof(n)) == -1){
		printf("IPPROTO_IPV6 failed\n");
		exit(1);
	}

	bytes = recvmsg(fd, &msg, 0);
	if (bytes == -1) {
		printf("recvmsg() failed\n");
		exit(1);
	}


}
