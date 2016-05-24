# shell script
# input: int
# output: hex

#!/bin/bash

declare -r HEX_DIGITS="0123456789abcdef"

dec_value=$1
hex_value=""

until [ $dec_value == 0 ]; do

	rem_value=$((dec_value % 16))
	dec_value=$((dec_value / 16))

	hex_digit=${HEX_DIGITS:$rem_value:1}

	hex_value="${hex_digit}${hex_value}"
done
echo -e "${hex_value}"


# or use: printf "%x\n" ${my_val}
#         printf "%d\n", 0x$my_val
