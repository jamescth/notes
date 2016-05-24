#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/socket.h>
#include <linux/socket.h>
#include <linux/in.h>
#include <linux/inet.h>

#define REQUEST	400
#define REPLY	400

#define UDP_SERV_PORT	7777
#define TCP_SERV_PORT	8888
#define TTCP_SERV_PORT	9999

#define SA	struct sockaddr *


