#!/bin/sh
# create Test_Suites/JSON/TestSystemConfig/james.json
# go test -v -run=TestBasicMemaslap -TestConfig="james" -BypassJobSch=false -Recipients=James.Ho@omnitier.com
# go test -v -run=TestBasicMemaslap -TestConfig="james" -BypassJobSch=false -Recipients=James.Ho@omnitier.com -Mock=true
go test -v -run=TestSteadyPerfMutilateSweepMulti -InstanceConfigPath="ES_mutilate_K31_V233_128G_ManyTests_Proxy"  -TestConfig="james1" -BypassJobSch=false -Recipients=James.Ho@omnitier.com -Mock=true
