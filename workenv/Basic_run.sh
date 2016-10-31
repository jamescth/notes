#!/bin/sh
# create Test_Suites/JSON/TestSystemConfig/james.json
# go test -v -run=TestBasicMemaslap -TestConfig="james" -BypassJobSch=false -Recipients=James.Ho@omnitier.com
go test -v -run=TestBasicMemaslap -TestConfig="james" -BypassJobSch=false -Recipients=James.Ho@omnitier.com -Mock=true
