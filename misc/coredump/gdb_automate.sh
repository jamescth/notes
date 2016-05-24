#!/bin/sh
gdb app_dump_test app_dump_test.core.16256.1340650389 <<GDB_INPUT
pwd
bt
quit
GDB_INPUT


OR

# cat gdb_test.sh
pwd
bt
quit

gdb -x gdb_test.sh ./app_dump_test ./app_dump_test.core.16256.1340650389

# for crash
crash -i gdb_test.sh
