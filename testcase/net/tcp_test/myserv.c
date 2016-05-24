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

main()
{
	struct sockaddr_in	serv, cli;
	char			request[REQUEST], reply[REPLY];
	int			listenfd, sockfd, n;
	socklen_t		clilen;

	// socket
	if ((listenfd = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
		printf("socket error\n");
		exit(1);
	}

	memset(&serv, 0, sizeof(serv));
	serv.sin_family = AF_INET;
	serv.sin_addr.s_addr = htonl(INADDR_ANY);
	serv.sin_port = htons(TCP_SERV_PORT);

	if (bind(listenfd, (SA) &serv, sizeof(serv)) < 0) {
		printf("bind error\n");
		exit(2);
	}

	if (listen(listenfd, SOMAXCONN) < 0) {
		printf("listen error\n");
		exit(3);
	}

	printf("pid is %d\n", getpid());

	while(1) {
		clilen = sizeof(cli);
		if ((sockfd = accept(listenfd, (SA) &cli, &clilen)) < 0) {
			printf("accept error\n");
			exit(4);
		}

		if ((n = read_stream(sockfd, request, REQUEST)) < 0) {
			printf("read error %d\n", n);
			exit(5);
		}

		// process n bytes of request

		if (send(sockfd, reply, REPLY, MSG_FIN) != REPLY) {
			printf("send error\n");
			exit(6);
		}

		close(sockfd);
	}
}
