#!/usr/bin/env python
"""
http://stackoverflow.com/questions/6329583/how-to-reliably-generate-ethernet-frame-errors-in-software

Ethernet Frame:
   [ Destination address, 6 bytes ]
   [ Source address, 6 bytes      ]
   [ Ethertype, 2 bytes           ]
   [ Payload, 40 to 1500 bytes    ]
   [ 32 bit CRC chcksum, 4 bytes  ]
"""

from socket import *

sk = socket(AF_PACKET, SOCK_RAW)
sk.bin(("eth1", 0))
src_addr = "\x01\x02\x03\x04\x05\x06"
dst_addr = "\x01\x02\x03\x04\x05\x06"
payload = ("["*30)+"PAYLOAD"+("]"*30)
checksum = "\x00\x00\x00\x00"
ethertype = "\x08\x01"
s.send(dst_addr+src_addr+ethertype+payload+checksum)

