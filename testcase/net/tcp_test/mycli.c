#include "cliserv.h"

int
read_stream(int fd, char *ptr, int maxbytes)
{
	int	nleft, nread;

	nleft = maxbytes;
	while (nleft > 0) {
		if ((nread = read(fd, ptr, nleft)) < 0) {
			// error
			return (nread);
		} else if (nread == 0) {
			// EOF
			break;
		}

		nleft -= nread;
		ptr += nread;
	}

	// return >= 0
	return (maxbytes - nleft);
}

main(int argc, char *argv[])
{
	struct sockaddr_in	serv;
	char			request[REQUEST], reply[REPLY];
	int			sockfd, n;

	if (argc != 2) {
		printf("usage: mycli <IP address>\n");
		exit(1);
	}

	if ((sockfd = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
		printf("socket error\n");
		exit(2);
	}

	memset(&serv, 0, sizeof(serv));
	serv.sin_family = AF_INET;
	serv.sin_addr.s_addr = inet_addr(argv[1]);
	serv.sin_port = htons(TCP_SERV_PORT);

	// form request

	printf("pid is %d\n", getpid());
	sleep(10);

	if (sendto(sockfd, request, REQUEST, MSG_FIN,
			(SA) &serv, sizeof(serv)) != REQUEST) {
		printf("sendto error\n");
		exit(3);
	}

	if ((n = read_stream(sockfd, reply, REPLY)) < 0) {
		printf("read error\n");
		exit(4);
	}

	// process n bytes

	
	close(0);
}
