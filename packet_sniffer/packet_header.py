import ctypes

"""
from_buffer_copy() is new in python 2.6
"""
class PY_ETH(ctypes.Structure):
	"""
	# define ETH_ALEN	6		/* Octets in one ethernet addr	 */
	struct ethhdr {
		unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
		unsigned char	h_source[ETH_ALEN];	/* source ether addr	*/
		__be16		h_proto;		/* packet type ID field	*/
	} __attribute__((packed));
	"""
	_fields_ = [
	#('eth_dest',	ctypes.c_char * 6),
	#('eth_src',	ctypes.c_char * 6),
	('eth_dest',	ctypes.c_ubyte * 6),
	('eth_src',	ctypes.c_ubyte * 6),
	('eth_proto',	ctypes.c_ushort)
	]

	def __new__(self, socket_buffer):
		return self.from_buffer_copy(socket_buffer)

	def __init__(self, socket_buffer):
		pass

class PY_IP(ctypes.Structure):
	"""
	struct ipheader {
		/* this means that each member is 4 bits */
		 unsigned char ip_hl:4, ip_v:4;
		 unsigned char ip_tos;
		 unsigned short int ip_len;
		 unsigned short int ip_id;
		 unsigned short int ip_off;
		 unsigned char ip_ttl;
		 unsigned char ip_p;
		 unsigned short int ip_sum;
		 unsigned int ip_src;
		 unsigned int ip_dst;
	"""
	_fields_ = [
	('ip_hl',	ctypes.c_ubyte),
	('ip_tos',	ctypes.c_ubyte),
	('ip_len',	ctypes.c_ushort),
	('ip_id',	ctypes.c_ushort),
	('ip_off',	ctypes.c_ushort),
	('ip_ttl',	ctypes.c_ubyte),
	('ip_proto',	ctypes.c_ubyte),
	('ip_sum',	ctypes.c_ushort),
	#('ip_src',	ctypes.c_uint),
	('ip_src',	ctypes.c_ubyte * 4),
	#('ip_dst',	ctypes.c_uint)
	('ip_dst',	ctypes.c_ubyte * 4)
	]

	def __new__(self, socket_buffer):
		return self.from_buffer_copy(socket_buffer)

	def __init__(self, socket_buffer):
		pass

class PY_ICMP(ctypes.Structure):
	"""
	struct icmp
	{
	  u_int8_t  icmp_type;	/* type of message, see below */
	  u_int8_t  icmp_code;	/* type sub code */
	  u_int16_t icmp_cksum;	/* ones complement checksum of struct */
	  union
	  {
	    u_char ih_pptr;		/* ICMP_PARAMPROB */
	    struct in_addr ih_gwaddr;	/* gateway address */
	    struct ih_idseq		/* echo datagram */
	    {
	"""

	_fields_ = [
	('type',	ctypes.c_ubyte),
	('code',	ctypes.c_ubyte),
	('checksum',	ctypes.c_ushort),
	('unused',	ctypes.c_ushort),
	('next_hop_mtu',ctypes.c_ushort)
	]

	def __new__(self, socket_buffer):
		return self.from_buffer_copy(socket_buffer)

	def __init__(self, socket_buffer):
		pass

class PY_TCP(ctypes.Structure):
	"""
	struct tcphdr
	  {
	     __extension__ union
	     {
	       struct
	       {
	 	u_int16_t th_sport;		/* source port */
	 	u_int16_t th_dport;		/* destination port */
	 	tcp_seq th_seq;			/* sequence number 32bit */
	 	tcp_seq th_ack;			/* acknowledgement number 32bit*/
	 # if __BYTE_ORDER == __LITTLE_ENDIAN
	 	u_int8_t th_x2:4;		/* (unused) */
	 	u_int8_t th_off:4;		/* data offset */
	 # endif
	 # if __BYTE_ORDER == __BIG_ENDIAN
	 	u_int8_t th_off:4;		/* data offset */
	 	u_int8_t th_x2:4;		/* (unused) */
	 # endif
	 	u_int8_t th_flags;
	 # define TH_FIN	0x01
	 # define TH_SYN	0x02
	 # define TH_RST	0x04
	 # define TH_PUSH	0x08
	 # define TH_ACK	0x10
	 # define TH_URG	0x20
		u_int16_t th_win;		/* window */
	 	u_int16_t th_sum;		/* checksum */
	 	u_int16_t th_urp;		/* urgent pointer */
	       };
	"""
	_fields_ = [
	('tcp_sport',	ctypes.c_ushort),
	('tcp_dport',	ctypes.c_ushort),
	('tcp_seq',	ctypes.c_uint),
	('tcp_ack',	ctypes.c_uint),
	('tcp_off',	ctypes.c_ubyte),
	('tcp_flags',	ctypes.c_ubyte),
	('tcp_win',	ctypes.c_ushort),
	('tcp_wum',	ctypes.c_ushort),
	('tcp_urp',	ctypes.c_ushort)
	]

	def __new__(self, socket_buffer):
		return self.from_buffer_copy(socket_buffer)

	def __init__(self, socket_buffer):
		pass

class PY_UDP(ctypes.Structure):
	"""
	struct udphdr
	{
	   __extension__ union
	   {
	     struct
	     {
	       u_int16_t uh_sport;		/* source port */
	       u_int16_t uh_dport;		/* destination port */
	       u_int16_t uh_ulen;		/* udp length */
	       u_int16_t uh_sum;		/* udp checksum */
	     };
	"""
	_fields_ = [
	('udp_sport',	ctypes.c_ushort),
	('udp_dport',	ctypes.c_ushort),
	('udp_ulen',	ctypes.c_ushort),
	('udp_sum',	ctypes.c_ushort)
	]

	def __new__(self, socket_buffer):
		return self.from_buffer_copy(socket_buffer)

	def __init__(self, socket_buffer):
		pass

