http://confluence.datrium.com/display/KeyHOME/Debugging

bug_30536

(gdb) disassemble VisorFSGetFileAttributes
...
   0x000041801f686699 <+93>:    add    $0x1,%rbp
   0x000041801f68669d <+97>:    movl   $0x200,0x8(%rbx)
   0x000041801f6866a4 <+104>:   movl   $0x1000,0xc(%rbx)
   0x000041801f6866ab <+111>:   mov    %eax,0x24(%rbx)
   0x000041801f6866ae <+114>:   mov    (%rbx),%rax
   0x000041801f6866b1 <+117>:   mov    %rbp,0x5a(%rbx)
...

Offset 5a is where the inode number is stored in the FS_FileAttributes (descNum):
...
(gdb) ptype FS_FileAttributes
type = struct FS_FileAttributes {
    uint64 length;
    uint32 diskBlockSize;
    uint32 fsBlockSize;
    uint64 numBlocks;
    FS_FileType type;
    FS_DescriptorFlags flags;
    uint32 generation;
    int32 descNum32;
    uint32 mtime;
    uint32 ctime;
    uint32 atime;
    uint32 uid;
    uint32 gid;
    uint32 mode;
    uint8 major;
    uint8 minor;
    uint32 reserved0;
    uint32 reserved1;
    uint64 rawHandleID;
    uint32 extraFlags;
    uint32 nlink;
    uint64 descNum;
}
(gdb) p &((FS_FileAttributes *)0)->descNum
$63 = (uint64 *) 0x5a
...

So we can see that the log message does give the correct directory name:
...
(gdb) p VisorFSObjs[105353].name
$65 = 0x43150a289860 "bin"
...

The ObjDescriptorInt for this file is referenced at address 0x4303d99d1240:
...
(gdb) p (ObjDescriptorInt *)0x4303d99d1240
(gdb) x/xg $66.oid.oid.data
0x4303d99d1294: 0x37b645ef00019b89
(gdb) p/x VisorFSObjs[105353].self
$70 = 0x37b645ef00019b89
(gdb) p/x 105353
$71 = 0x19b89
...

Through disassembly of functions and following pointer references in the core I found the following:
...
0x4392fc49be70[0] -> 0x4311780330d0[656] -> 0x439e1827a6c8[15] -> 0x439e19354f40 -> [0] = 0x4303d99d1240 <-- (ObjDescriptorInt)

bug 31953
e$dagdb UpgradeMgr UpgradeMgr-core.000

(gdb) t a a bt
(gdb) thread 1 
[Switching to thread 1 (LWP 35985)]
#0  0x000000000099f419 in TimeSheet_DecGroupAndGetNew (ts=0x29a4830 <schedInt+1072>) at Include/TimeSheet.h:181
181	   DA_ASSERT(oldGroup != 0); // No underflow.

(gdb) set pagination off

(gdb) info variables
All defined variables:

File ./Modules/_codecsmodule.c:
static PyMethodDef _codecs_functions[42];
static char decode__doc__[420];
static char encode__doc__[434];
static char lookup__doc__[115];
static char lookup_error__doc__[158];
...

(gdb) info locals
_regs = {rdi = 43665480, rsi = 3314, rdx = 15882910, rcx = 0, r8 = 0, r9 = 4397761289248, r10 = 1, r11 = 514, rax = 0, rbx = 47, rbp = 4397761289312, r12 = 3730256083, 
  r13 = 0, r14 = 0, r15 = 0, rip = 10089496}
oldGroup = 0
newGroup = 65535
__PRETTY_FUNCTION__ = "TimeSheet_DecGroupAndGetNew"

(gdb) print *(TimeSheet *)0x29a4830
$2 = {state = {word128 = 1141114465254572032, atomic = {val = 1141114465254572032}, fields = {group = 0, startTsc = 17412024921487, unused = 0}}, schema = {base = 2, 
    scale = 1 '\001', baseMSZBits = 62 '>', type = HISTOGRAM_TYPE_TIME_DEFAULT_CYC, scaleScheme = HISTOGRAM_SCALE_SCHEME_POW2}, zeroGroupTime = {val = 39114267}, 
  weightedTimeInGroups = {{val = 9574815}, {val = 0}, {val = 0}, {val = 0}, {val = 0}, {val = 0}, {val = 4683786450}}, lastSampleTime = 17411979143695}

(gdb) p &oldGroup
$3 = (uint16 *) 0x3ffeeffdc5c


*************************************************************************************
dagdb
31978

$dagdb -i 
Misc/
  04 Oct 2017 08:34:28.576       13MB                   DaggerWorker-zdump.000 [19]                      
  04 Oct 2017 08:34:29.903       24MB                   DaggerWorker-zdump.001 [18]                      
  04 Oct 2017 08:34:30.032        5MB                     ESXPlatMgr-zdump.000 [17]                      
  04 Oct 2017 08:34:30.165        6MB                     ESXPlatMgr-zdump.001 [16]                      
  04 Oct 2017 08:35:02.026       56MB                             FE-zdump.000 [15]                      
  04 Oct 2017 08:35:03.140       60MB                             FE-zdump.001 [14]                      
  04 Oct 2017 08:35:03.268        5MB                       FEMountd-zdump.000 [13]                      
  04 Oct 2017 08:35:03.366        5MB                       FEMountd-zdump.001 [12]                      
  04 Oct 2017 08:35:03.475        4MB         NetworkHeartbeatServer-zdump.000 [11]                      
  04 Oct 2017 08:35:03.567        5MB         NetworkHeartbeatServer-zdump.001 [10]                      
  04 Oct 2017 08:35:03.716        5MB                     UpgradeMgr-zdump.000 [ 9]                      
  04 Oct 2017 08:35:03.824        5MB                     UpgradeMgr-zdump.001 [ 8]
Enter your choice <1.. or q. ? for help>: 9

(gdb) source /da/main/Scripts/gdbpython.py
(gdb) thread-list
26     SVC_INIT_ASYNC:9901517                                           : READY    Gen 1       COOPERATIVE 
27     SVC_INIT_ASYNC:9901517                                           : READY    Gen 1       COOPERATIVE 
28     UPGRADE_AGENT:10763192                                           : READY    Gen 1       COOPERATIVE 
31     OSWATCHDOG:10614324                                              : RUNNING  Gen 5       PREEMPTIVE  
33     LOCK_STATS_DUMP:10234635                                         : READY    Gen 24      COOPERATIVE 
34     ANONYMOUS:10507220                                               : BLOCKED  Gen 2       PREEMPTIVE  NO TIMEOUT
37     COMM_SEND_WORK_Q:4397557827848                                   : READY    Gen 3       COOPERATIVE 
38     COMM_RECV_WORK_Q:4397557827848                                   : READY    Gen 3       COOPERATIVE 
39     REGISTRY_ZOO_LOG_DRAIN:8605837                                   : BLOCKED  Gen 1       PREEMPTIVE  18446741638s
40     ANONYMOUS:10507220                                               : RUNNING  Gen 3       PREEMPTIVE  
43     CRON_MASTER:43667040                                             : READY    Gen 131     COOPERATIVE 
50     COOPDISPATCHER:0                                                 : READY    Gen 1       PREEMPTIVE  
65535  BOOTSTRAP:10507101                                               : BLOCKED  Gen 0       PREEMPTIVE  NO TIMEOUT
(gdb) thread-switch 28
Interpreting '28' as a thread token
Switched to READY COOPERATIVE thread.
(gdb) bt
#0  0x00000000009aa1f7 in ThreadSwitch (old=0x3ffe264e000, new=0x3ffe288e000) at Common/Thread/ThreadSched.c:1909
#1  0x00000000009aedc7 in ThreadSched_Sched (target=0x3ffe288e000) at Common/Thread/ThreadSched.c:2644
#2  0x0000000000a00fef in ThreadYieldTo (target=0x0, resultForTarget=0) at Common/Thread/Thread.c:1237
#3  0x0000000000a01131 in Thread_Yield () at Common/Thread/Thread.c:1264
#4  0x00000000009ae292 in ThreadSched_DispatcherExternalBlockDone () at Common/Thread/ThreadSched.c:2563
#5  0x0000000000a0a538 in Thread_ExternalBlockDone () at Common/Thread/Thread.c:2740
#6  0x0000000000733976 in OS_RunCmd (panicTimeoutSecs=46, format=0xdf3be1 "/bin/timeout -s %u -t %u %s") at Common/OS/Posix/OSStdlib.c:69
#7  0x000000000057bd94 in DaEsxUtils_RunCmdWithTimeout (timeoutSec=30, command=0x16f33e8 "/opt/datrium/python2/bin/python ++group=host/vim/vimuser/datrium %sprocmgr_cli.py --client UpgradeMgr.%d switchmode 3") at Common/Da/DaEsxUtils.c:45
#8  0x0000000000a4ae4d in HostAgent_PostRunningVersionMatch () at Platform/UpgradeMgr/AgentSvr/HostAgent.c:247
#9  0x0000000000a475a8 in CompareVersions (arg=0x0, handle=4294967581) at Platform/UpgradeMgr/AgentSvr/AgentSvr.c:689
#10 0x00000000009b9d0f in CronRunJob (arg=0x3ffe2ab31d8) at Common/Thread/Cron.c:552
#11 0x00000000009f10da in RunnerThreadRoutine (arg=0x3ffe2ab32d8) at Common/Thread/AsyncJobRunner.c:438
#12 0x00000000009fd9a5 in ThreadFuncCall (thread=0x3ffe264e000, label=..., versionString=0x29a7680 <versionPidNameBuf> "PROCESS: UpgradeMgr BUILD: 3.1.1.0-27661_79a976c_g, PID: 56927") at Common/Thread/Thread.c:549
#13 0x00000000009fe263 in CoopStart (fromRegs=0x3ffe266e040) at Common/Thread/Thread.c:673
#14 0x0000000000000000 in ?? ()

(gdb) p confThread.dispatchThreads
$1 = {type = CONF_TYPE_INT, u = {bVal = true, iVal = 1, e = {toEnum = 0x1, toString = 0x0, val = 0}, dVal = 4.9406564584124654e-324, sVal = "\001", '\000' <repeats 598 times>}}

(gdb) p abortMsg
$1 = "\n--- 2017-10-04T13:50:58.585391+0000 PROCESS: UpgradeMgr BUILD: 3.1.1.0-27668_1f03ec4_g, PID: 3008 ------ Platform/UpgradeMgr/MasterSvr/UpgradeTaskImpl.c:524 DA_ASSERT_ON_ERR(err); in GetAgentCurrentS"...

(gdb) p tscCore
$1 = 5051330699361448
(gdb) p (tscCore - thread.tscLastBlock) / cyclesPerMillisec / 1000
No symbol "thread" in current context.

(gdb) p forkTsc
$1 = 5051330666491951
(gdb) p tscCore
$2 = 5051330699361448

(gdb) p (5051330699361448-5051330666491951)/cyclesPerMillisec
$3 = 16

(gdb) bt
#0  0x0000000000b48aff in TimerAbortWithMsg (msg=0xef9ae7 "Timeout in OS command") at Common/Thread/Timer.c:479
#1  0x0000000000b2df84 in ThreadFuncCall (thread=0x3ffe6f1e000, label=..., versionString=0x22254a0 <versionPidNameBuf> "PROCESS: UpgradeMgr BUILD: 3.0.0.2-27532_93d635d, PID: 36363") at Common/Thread/Thread.c:548
#2  0x0000000000b3dce2 in PreemptiveStart (fromRegs=<optimized out>) at Common/Thread/Thread.c:596
#3  0x0000000000000000 in ?? ()

(gdb) f 1
#1  0x0000000000b2df84 in ThreadFuncCall (thread=0x3ffe6f1e000, label=..., 
    versionString=0x22254a0 <versionPidNameBuf> "PROCESS: UpgradeMgr BUILD: 3.0.0.2-27532_93d635d, PID: 36363") at Common/Thread/Thread.c:548
548	{

(gdb) info local
arg = 0xef9ae7
tscThreadStart = 6756803109639008

(gdb) p forkTsc
$1 = 6756683502636612

(gdb) p (6756803109639008-6756683502636612)/cyclesPerMillisec
$2 = 46002

(gdb) thread-list
28     SVC_INIT_ASYNC:11137998                                          : READY    Gen 1       COOPERATIVE Ready for 45s
29     CMA_REFRESH:5074377                                              : READY    Gen 2       COOPERATIVE Ready for 45s
30     UPGRADE_AGENT:12039774                                           : READY    Gen 1       COOPERATIVE Ready for 45s
33     OSWATCHDOG:11837775                                              : RUNNING  Gen 4       PREEMPTIVE  
35     ANONYMOUS:11674478                                               : RUNNING  Gen 2       PREEMPTIVE  
39     COMM_RECV_WORK_Q:4397633440248                                   : READY    Gen 3       COOPERATIVE Ready for 16s
43     CRON_MASTER:35794656                                             : READY    Gen 45      COOPERATIVE Ready for 45s
50     COOPDISPATCHER:0                                                 : READY    Gen 1       PREEMPTIVE  Ready for 45s

(gdb) bt 30
Interpreting '30' as a thread token
Printing backtrace of thread 30 UPGRADE_AGENT:12039774 : READY Gen 1 COOPERATIVE
#0  ThreadSwitch (old=0x3ffe6ebe000, new=0x3ffe70de000) at Common/Thread/ThreadSched.c:1472
#1  0x0000000000ad834d in ThreadSched_Sched (target=0x3ffe70de000) at Common/Thread/ThreadSched.c:2220
#2  0x0000000000b3a89f in ThreadYieldTo (target=0x0, resultForTarget=0) at Common/Thread/Thread.c:1236
#3  0x0000000000b3be61 in Thread_Yield () at Common/Thread/Thread.c:1263
#4  0x0000000000ad7d95 in ThreadSched_DispatcherExternalBlockDone () at Common/Thread/ThreadSched.c:2147
#5  0x0000000000b291ad in Thread_ExternalBlockDone () at Common/Thread/Thread.c:2739
#6  0x000000000079e9ca in OS_RunCmd (panicTimeoutSecs=<optimized out>, format=<optimized out>) at Common/OS/Posix/OSStdlib.c:69
#7  0x000000000058a920 in DaEsxUtils_RunCmdWithTimeout (timeoutSec=30, command=<optimized out>) at Common/Da/DaEsxUtils.c:45
#8  0x0000000000b8ef6b in HostAgent_PostRunningVersionMatch () at Platform/UpgradeMgr/AgentSvr/HostAgent.c:247
#9  0x0000000000b87a84 in CompareVersions (arg=<optimized out>, handle=<optimized out>) at Platform/UpgradeMgr/AgentSvr/AgentSvr.c:689
#10 0x0000000000aea626 in CronRunJob (arg=0x3ffe72dffa8) at Common/Thread/Cron.c:552
#11 0x0000000000b16e54 in RunnerThreadRoutine (arg=0x3ffe72e00a8) at Common/Thread/AsyncJobRunner.c:438
#12 0x0000000000b2df84 in ThreadFuncCall (thread=0x3ffe6ebe000, label=..., versionString=0x22254a0 <versionPidNameBuf> "PROCESS: UpgradeMgr BUILD: 3.0.0.2-27532_93d635d, PID: 36363") at Common/Thread/Thread.c:548
#13 0x0000000000b3eb2a in CoopStart (fromRegs=<optimized out>) at Common/Thread/Thread.c:672
#14 0x0000000000000000 in ?? ()

(gdb) thread-err-last
Error DA_ERROR_NOT_FOUND: Rename: File /var/log/datrium/traces/default/upgrade_mgr.5sec.histo not found, created at Common/OS/Posix/OSFile.c:486, backtrace:
In Backtrace_FillToSpecifiedDepth at Common/DaErr/DaErr.c:168
In OSFile_Rename at Common/OS/Posix/OSFile.c:486
In SetupOutputFile at Common/Profile/ProfileTraceWriter.c:1030
In RotateFileIfNeeded at Common/Profile/ProfileTraceWriter.c:1107
In DumpHifiHistograms at Common/Profile/ProfileTraceWriter.c:1752
In HistoDumperCronJob at Common/Profile/ProfileTraceWriter.c:1857
In CronJobCheckAndClearKicked at Common/Thread/Cron.c:304
In RunnerThreadRoutine at Common/Thread/AsyncJobRunner.c:425
In ThreadFuncCall at Common/Thread/Thread.c:558
In CoopStart at Common/Thread/Thread.c:688


(gdb) thread <tab> <tab>
thread                               thread-from-id                       thread-set-current-as-coop-switcher
thread-err-last                      thread-list                          thread-state-messed-up
thread-errno                         thread-restore                       thread-switch
thread-find-frame                    thread-run-cmd                       thread-use-pre-signal-regs
thread-frame-sizes                   thread-select-and-run-cmd            
(gdb) ht-  <tab> <tab>
ht-print         ht-print-bucket  ht-print-record  ht-records       

Or /da/main/Scripts/pygdb

(gdb) thread-select-and-run-cmd bt
23 TIMER_ABORT:12347496 : RUNNING Gen 35294 PREEMPTIVE
#0  0x0000000000bc532c in TimerAbortWithMsg (msg=0x10b41ee "Bootstrap_Init timed out!") at Common/Thread/Timer.c:478
#1  0x0000000000ba73fc in ThreadFuncCall (thread=0x3ffe728e000, labelGroup=LABEL_THREAD_TIMER_ABORT, labelId=12347496, threadToken=23, versionString=0x244b1e0 <versionPidNameBuf> "PROCESS: UpgradeMgr BUILD: 4.0.1.0-29330_9b8f012, PID: 4838263") at Common/Thread/Thread.c:557
#2  0x0000000000bb9c26 in PreemptiveStart (fromRegs=<optimized out>) at Common/Thread/Thread.c:608
#3  0x0000000000000000 in ?? ()



26 SVC_INIT_ASYNC:11596902 : RUNNING -> EXITED Gen 2 COOPERATIVE
#0  ThreadSwitch (old=0x3ffe72ee000, new=0x3ffe750e000) at Common/Thread/ThreadSched.c:2018
#1  0x0000000000b4c14d in ThreadSched_Sched (target=0x3ffe750e000) at Common/Thread/ThreadSched.c:2752
#2  0x0000000000bb819f in Thread_Exit () at Common/Thread/Thread.c:1395
#3  0x0000000000bbb20c in CoopStart (fromRegs=<optimized out>) at Common/Thread/Thread.c:688
#4  0x0000000000000000 in ?? ()



29 ANONYMOUS:12166446 : RUNNING Gen 1 PREEMPTIVE
#0  0x00000000007c0626 in OS_ParkSelf () at Common/OS/Posix/OSProcess.c:140
#1  0x000000001533acac in pthread_cond_wait@@GLIBC_2.3.2 () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libpthread.so.0
#2  0x0000000000cd4541 in do_completion (v=0x3ffe81f6030) at src/mt_adaptor.c:463
---Type <return> to continue, or q <return> to quit---
#3  0x0000000015336ddc in start_thread () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libpthread.so.0
#4  0x000000001527519d in clone () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libc.so.6
#5  0x0000000000000000 in ?? ()



40 REGISTRY_ZOO_LOG_DRAIN:9275538 : BLOCKED Gen 1 PREEMPTIVE
#0  OS_ParkSelf () at Common/OS/Posix/OSProcess.c:140
#1  0x000000001526c5a3 in poll () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libc.so.6
#2  0x0000000000838c29 in OS_DrainZooLog (readFd=10, sleepTime=1000000000) at Common/OS/Posix/OSLog.c:1750
#3  0x00000000008c3767 in ZooLogDrain (arg=0x24310c0 <regConn>) at Cluster/Registry/Client/C/Registry.c:1788
#4  0x0000000000ba73fc in ThreadFuncCall (thread=0x3ffe74ae000, labelGroup=LABEL_THREAD_REGISTRY_ZOO_LOG_DRAIN, labelId=9275538, threadToken=40, versionString=0x244b1e0 <versionPidNameBuf> "PROCESS: UpgradeMgr BUILD: 4.0.1.0-29330_9b8f012, PID: 4838263") at Common/Thread/Thread.c:557
#5  0x0000000000bb9c26 in PreemptiveStart (fromRegs=<optimized out>) at Common/Thread/Thread.c:608
#6  0x0000000000000000 in ?? ()



43 CRON_MASTER:38046368 : READY Gen 600850 COOPERATIVE
#0  ThreadSwitch (old=0x3ffe750e000, new=0x3ffe75ee000) at Common/Thread/ThreadSched.c:2018
#1  0x0000000000b4c14d in ThreadSched_Sched (target=0x3ffe75ee000) at Common/Thread/ThreadSched.c:2752
#2  0x0000000000badc60 in Thread_TimedBlock (absTime=<optimized out>) at Common/Thread/Thread.c:2935
---Type <return> to continue, or q <return> to quit---
#3  0x0000000000b83349 in DoWait () at Common/Thread/TaskletCount.c:203
#4  0x0000000000b850fb in TaskletCount_TimedWaitUntilAtMostNRemain (waitUntilNS=<optimized out>, N=<optimized out>, interruptible=<optimized out>) at Common/Thread/TaskletCount.c:240
#5  0x0000000000b7c58a in TaskletCount_WaitUntilAtMostNRemain (N=0, taskletCount=0x3ffe750dd08) at Include/TaskletCount.h:49
#6  TaskletCount_WaitForAll (taskletCount=0x3ffe750dd08) at Include/TaskletCount.h:62
#7  Delegate_WaitUntilFunctionDone (function=0x3ffe750dcd0) at Include/Delegate.h:288
#8  ThreadWorkerWork (arg=0x2448aa0 <cronDispatcherInt+608>, recycle=true) at Common/Thread/ThreadWorker.c:303
#9  0x0000000000b795c4 in ThreadWorkerStartFunction (arg=0x2448aa0 <cronDispatcherInt+608>) at Common/Thread/ThreadWorker.c:81
#10 0x0000000000ba73fc in ThreadFuncCall (thread=0x3ffe750e000, labelGroup=LABEL_THREAD_CRON_MASTER, labelId=38046368, threadToken=43, versionString=0x244b1e0 <versionPidNameBuf> "PROCESS: UpgradeMgr BUILD: 4.0.1.0-29330_9b8f012, PID: 4838263") at Common/Thread/Thread.c:557
#11 0x0000000000bbb207 in CoopStart (fromRegs=<optimized out>) at Common/Thread/Thread.c:687
#12 0x0000000000000000 in ?? ()



65535 BOOTSTRAP:12166349 : BLOCKED Gen 0 PREEMPTIVE
#0  0x00000000007c0626 in OS_ParkSelf () at Common/OS/Posix/OSProcess.c:140
#1  0x000000001533acac in pthread_cond_wait@@GLIBC_2.3.2 () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libpthread.so.0
#2  0x00000000007ec273 in OSSemWaitWork (blocking=true, timeout=9223372036854775807) at Common/OS/Posix/OSSem.c:187
#3  0x00000000007edaeb in OSSem_Wait (sem=0x244b0c0 <bootstrapThreadOSSemStructSpace>) at Common/OS/Posix/OSSem.c:243
#4  0x0000000000ba5edc in ThreadWaitOnSem (sem=0x244b0c0 <bootstrapThreadOSSemStructSpace>, thread=0x2449040 <threadForBootstrap>) at Common/Thread/Thread.c:112
---Type <return> to continue, or q <return> to quit---
#5  ThreadFinishBlock (thread=0x2449040 <threadForBootstrap>, sem=0x244b0c0 <bootstrapThreadOSSemStructSpace>) at Common/Thread/Thread.c:3070
#6  0x0000000000badc99 in Thread_TimedBlock (absTime=<optimized out>) at Common/Thread/Thread.c:2945
#7  0x0000000000bb1481 in Thread_Block () at Include/Thread.h:603
#8  ThreadJoinWork (thread=0x3ffe72ee000) at Common/Thread/Thread.c:1161
#9  0x0000000000bb26eb in Thread_Join (tid=<optimized out>) at Common/Thread/Thread.c:1202
#10 0x0000000000b0f4e1 in RunSvcFunctionAsyncWait (svcIdx=3) at Common/SvcInit/SvcInit.c:229
#11 0x0000000000b0f657 in JoinAllRunningThreads () at Common/SvcInit/SvcInit.c:389
#12 0x0000000000b1373e in SvcInit_StartCommensalisticSvc () at Common/SvcInit/SvcInit.c:530
#13 0x00000000004e65d4 in Bootstrap_Init (argc=3, argv=0x3ffe5ce1e40, pe=0x144c960 <upgradeMgrProcEntry>) at Common/Bootstrap/Bootstrap.c:1277
#14 0x00000000004e696f in Bootstrap_Main (argc=3) at Common/Bootstrap/Bootstrap.c:1391
#15 0x00000000004cbeed in main (argc=3, argv=0x3ffe5ce1e40) at Platform/UpgradeMgr/Main/UpgradeMgrMain.c:80


(gdb) thread-switch 65535
Interpreting '65535' as a thread token
Switched to BLOCKED PREEMPTIVE thread.
(gdb) bt
#0  0x00000000007c0626 in OS_ParkSelf () at Common/OS/Posix/OSProcess.c:140
#1  0x000000001533acac in pthread_cond_wait@@GLIBC_2.3.2 () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libpthread.so.0
#2  0x00000000007ec273 in OSSemWaitWork (blocking=true, timeout=9223372036854775807) at Common/OS/Posix/OSSem.c:187
#3  0x00000000007edaeb in OSSem_Wait (sem=0x244b0c0 <bootstrapThreadOSSemStructSpace>) at Common/OS/Posix/OSSem.c:243
#4  0x0000000000ba5edc in ThreadWaitOnSem (sem=0x244b0c0 <bootstrapThreadOSSemStructSpace>, thread=0x2449040 <threadForBootstrap>) at Common/Thread/Thread.c:112
#5  ThreadFinishBlock (thread=0x2449040 <threadForBootstrap>, sem=0x244b0c0 <bootstrapThreadOSSemStructSpace>) at Common/Thread/Thread.c:3070
#6  0x0000000000badc99 in Thread_TimedBlock (absTime=<optimized out>) at Common/Thread/Thread.c:2945
#7  0x0000000000bb1481 in Thread_Block () at Include/Thread.h:603
#8  ThreadJoinWork (thread=0x3ffe72ee000) at Common/Thread/Thread.c:1161
#9  0x0000000000bb26eb in Thread_Join (tid=<optimized out>) at Common/Thread/Thread.c:1202
#10 0x0000000000b0f4e1 in RunSvcFunctionAsyncWait (svcIdx=3) at Common/SvcInit/SvcInit.c:229
#11 0x0000000000b0f657 in JoinAllRunningThreads () at Common/SvcInit/SvcInit.c:389
#12 0x0000000000b1373e in SvcInit_StartCommensalisticSvc () at Common/SvcInit/SvcInit.c:530
#13 0x00000000004e65d4 in Bootstrap_Init (argc=3, argv=0x3ffe5ce1e40, pe=0x144c960 <upgradeMgrProcEntry>) at Common/Bootstrap/Bootstrap.c:1277
#14 0x00000000004e696f in Bootstrap_Main (argc=3) at Common/Bootstrap/Bootstrap.c:1391
#15 0x00000000004cbeed in main (argc=3, argv=0x3ffe5ce1e40) at Platform/UpgradeMgr/Main/UpgradeMgrMain.c:80

(gdb) thread-switch 0x3ffe72ee000
Interpreting '0x3ffe72ee000' as a (Thread *)
Switched to RUNNING COOPERATIVE thread.
(gdb) bt
#0  ThreadSwitch (old=0x3ffe72ee000, new=0x3ffe750e000) at Common/Thread/ThreadSched.c:2018
#1  0x0000000000b4c14d in ThreadSched_Sched (target=0x3ffe750e000) at Common/Thread/ThreadSched.c:2752
#2  0x0000000000bb819f in Thread_Exit () at Common/Thread/Thread.c:1395
#3  0x0000000000bbb20c in CoopStart (fromRegs=<optimized out>) at Common/Thread/Thread.c:688
#4  0x0000000000000000 in ?? ()


**************************************************
(gdb) thread-select-and-run-cmd bt
29 ANONYMOUS:10625069 : RUNNING Gen 1 PREEMPTIVE
#0  OS_ParkSelf () at Common/OS/Posix/OSProcess.c:140
#1  0x000000002427bcac in pthread_cond_wait@@GLIBC_2.3.2 () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libpthread.so.0
#2  0x0000000000aa8d61 in do_completion (v=0x3ffd86018b0) at src/mt_adaptor.c:463
#3  0x0000000024277ddc in start_thread () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libpthread.so.0
#4  0x00000000241b618d in clone () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libc.so.6

30 ANONYMOUS:10625069 : RUNNING Gen 3 PREEMPTIVE
#0  OS_ParkSelf () at Common/OS/Posix/OSProcess.c:140
#1  0x00000000241ad593 in poll () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libc.so.6
#2  0x0000000000aa8bae in do_io (v=0x3ffd86018b0) at src/mt_adaptor.c:387
#3  0x0000000024277ddc in start_thread () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libpthread.so.0
#4  0x00000000241b618d in clone () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libc.so.6

39 REGISTRY_ZOO_LOG_DRAIN:8655344 : BLOCKED Gen 1 PREEMPTIVE
#0  OS_ParkSelf () at Common/OS/Posix/OSProcess.c:140
#1  0x00000000241afaa3 in select () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libc.so.6
#2  0x0000000000798a95 in OS_DrainZooLog (readFd=10, sleepTime=1000000000) at Common/OS/Posix/OSLog.c:1747
#3  0x0000000000840ca3 in ZooLogDrain (arg=0x2adeb40 <regConn>) at Cluster/Registry/Client/C/Registry.c:1788
#4  0x0000000000a1a4aa in ThreadFuncCall (thread=0x3ffd7bae000, labelGroup=LABEL_THREAD_REGISTRY_ZOO_LOG_DRAIN, labelId=8655344, threadToken=39, versionString=0x2af8cc0 <versionPidNameBuf> "PROCESS: UpgradeMgr BUILD: 3.1.101.0-28286_63dba5c_g, PID: 47574") at Common/Thread/Thread.c:557
#5  0x0000000000a1a814 in PreemptiveStart (fromRegs=0x243cdc80) at Common/Thread/Thread.c:608
#6  0x0000000000000000 in ?? ()

65535 BOOTSTRAP:10624950 : RUNNING Gen 0 PREEMPTIVE
#0  0x000000002427dfc0 in sem_wait () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-2068190/lib64/libpthread.so.0
#1  0x000000000076b0ef in OSSemRaw_Wait (sem=0x2a69fe0 <shutdownSem>) at Include/OS/Posix/OSSemRawImpl.h:50
#2  0x00000000004d71a5 in WaitForTerm () at Common/Bootstrap/Bootstrap.c:1073
#3  0x00000000004d88cd in Bootstrap_Main (argc=3) at Common/Bootstrap/Bootstrap.c:1404
#4  0x00000000004c3f11 in main (argc=3, argv=0x3ffd62b5e40) at Platform/UpgradeMgr/Main/UpgradeMgrMain.c:80

(gdb) set print pretty on
(gdb) print *(struct Semaphore *)0x2a69fe0
$5 = {
  rank = {
    base = RANK_NULL_ID, 
    rank = RANK_NULL_ID, 
    aux = RANK_NULL_ID
  }, 
  allocator = {
    delegate = {
      state = {
        word64 = 1, 
        atomic = {
          val = 1
        }, 
        fields = {
          lock = 1, 
          incoming = 0, 
          pending = 0, 
          blocked = 0, 
          unused = 0
        }
      }, 
      updatedState = {
        word64 = 0, 
        atomic = {
          val = 0
        }, 
        fields = {
          lock = 0, 
          incoming = 0, 
          pending = 0, 
          blocked = 0, 
          unused = 0
        }
      }, 
      tid = ThreadID 0x0 invalid, 
      incoming = {
        head = {
          word64 = {
            val = 5072824
          }, 
          next = 0x4d67b8 <Bootstrap_FailoverExit>
        }
      }, 
      queuedFunctions = {
        magic = 2762571891, 
        attrs = {
          word32 = 2266, 
          fields = {
            extra_debug_checks = 0, 
            typeEnum = 109, 
            unused = 1
          }
        }, 
        head = {
          prev = 0x0, 
          next = 0x0, 
          list = 0x0
        }, 
        tail = {
          prev = 0x0, 
          next = 0x0, 
          list = 0x0
        }, 
        count = 0, 
        lock = {
          val = 0
        }
      }, 
      blockedFunctions = {
        magic = 0, 
        attrs = {
          word32 = 0, 
          fields = {
            extra_debug_checks = 0, 
            typeEnum = 0, 
            unused = 0
          }
        }, 
        head = {
          prev = 0x0, 
          next = 0x0, 
          list = 0x0
        }, 
        tail = {
          prev = 0x0, 
          next = 0x0, 
          list = 0x0
        }, 
        count = 0, 
        lock = {
          val = 0
        }
      }, 
      rank = {
        base = RANK_NULL_ID, 
        rank = RANK_NULL_ID, 
        aux = RANK_NULL_ID
      }, 
      loopCount = 0, 
      maxLoops = 0, 
      incomingCount = {
        val = 0
      }, 
      countIncoming = 0 '\000', 
      rankCheckEnum = 0 '\000', 
      defaultFunction = 0x0, 
      runningLink = 0x0, 
      raceDetector = {
        val = 0
      }, 
      spinDetector = {
        maxSpinsPerSec = 0, 
        spins = {
          val = 0
        }, 
        lastCheckTsc = {
          val = 0
        }, 
        minCyclesToReachMax = {
          val = 0
        }, 
        file = 0x0, 
        line = 0, 
        logMin = false, 
        callback = 0x0, 
        arg = 0x0
      }
    }, 
    max = 0, 
    throttleThreshold = 0, 
    thresholdBasisPoints = 0, 
    forUpdatingMax = {
      val = 0
    }, 
    rank = {
      base = RANK_NULL_ID, 
      rank = RANK_NULL_ID, 
      aux = RANK_NULL_ID
    }, 
    enforceMax = false, 
    isRanked = false, 
    hasWaiters = false, 
    maxAdjusted = false, 
    reservationTimeout = 0, 
    traceWaits = false, 
    lockStatsHandle = 0, 
    beacon = 0x320004a0, 
    blockingHistogram = 0x100000000
  }, 
  label = {
    magic = 0, 
    group = LABEL_MEMCTXT_UNINITIALIZED, 
    id = 0
  }
}
(gdb) 


(gdb) err-print err
Error DA_ERROR_INVALID_ARGUMENT: Command handle_mount.py failed with retval 256, created at Protocols/Nfs/NfsProxy/Mount/MountProxyServer.c:194, backtrace:
In Backtrace_FillToSpecifiedDepth at Common/DaErr/DaErr.c:168
In CallHandleMount at Protocols/Nfs/NfsProxy/Mount/MountProxyServer.c:194
In ConnectToRealServer at Protocols/Nfs/NfsProxy/Mount/MountProxyServer.c:276
In ConnectToRealServerCron at Protocols/Nfs/NfsProxy/Mount/MountProxyServer.c:400
In CronRunJob at Common/Thread/Cron.c:561
In RunnerThreadRoutine at Common/Thread/AsyncJobRunner.c:439
In ThreadFuncCall at Common/Thread/Thread.c:558
In CoopStart at Common/Thread/Thread.c:688

******************************************************************************************
vmkernel coredump
******************************************************************************************
vsish
set /reliability/crashMe/Panic

******************************************************************************************
live core
******************************************************************************************
# procmgr_cli.py show

Mode/Changing: 3/False

Name                   Stat  PID      Auto  Enable Modes        Vmsize    RSS  Uptime
---------------------------------------------------------------------------------
DaggerWorker           R     19737331 1     1      3                 0      0   1d 0h
ESXPlatMgr             R     41450257 1     1      3                 0      0   6d 5h
FE                     R     41417488 1     1      3                 0      0   6d 5h
eventproducer          R     41450258 1     1      3                 0      0   6d 5h
NetworkHeartbeat       R     41450090 1     1      2,3               0      0   6d 5h
UpgradeMgr             R     41450089 1     1      2,3               0      0   6d 5h
FEMountd               R     41449753 1     1      1,2,3             0      0   6d 5h
esx_platmgr            R     41449752 1     1      1,2,3             0      0   6d 5h
---------------------------------------------------------------------------------
Total                                                                0      0        
[root@n1631-a07n2:~] vsish
/world/41449752/> cd /userworld/
/userworld/> ls
info
destroy
global/
groups/
groupPathStringToID
groupPathNameToID
mem/
stats/
cartel/
/userworld/> cd /
/> cd /usre
/userworld/> cd /userworld/cartel/
/userworld/cartel/> cd ..
/userworld/> ls
info
destroy
global/
groups/
groupPathStringToID
groupPathNameToID
mem/
stats/
cartel/
/userworld/> cd cartel
/userworld/cartel/> ls
46560327/
47412077/
47444832/
...

/userworld/cartel/> cd 41449752
/userworld/cartel/41449752/> ls
loglevels/
stats/
resetStats
debug/
net/
mem/
fss/
fd/
signal/
thread/
child/
parent
netstack
vmmLeader
leader
arch
cmdline
/userworld/cartel/41449752/> cd debug
/userworld/cartel/41449752/debug/> ls
livecore
coreDumpEnabled
/userworld/cartel/41449752/debug/> set /userworld/cartel/41449752/debug/livecore 1
/userworld/cartel/41449752/debug/> quit
[root@n1631-a07n2:~] cd /var/core
[root@n1631-a07n2:/vmfs/volumes/595308a3-3658244b-3dd7-0cc47a907816/core] ls
FE-1-flat.vswp    python-zdump.000
[root@n1631-a07n2:/vmfs/volumes/595308a3-3658244b-3dd7-0cc47a907816/core] ls -al
total 8689672
drwxr-xr-x    1 root     root           560 Dec  5 23:57 .
drwxr-xr-t    1 root     root          1540 Jun 28 01:38 ..
-rw-------    1 root     root     8884584448 Nov 29 18:36 FE-1-flat.vswp
-r--------    1 root     root      11870208 Dec  5 23:57 python-zdump.000

**********************************************
where is python
**********************************************
/da/ToolsAndLibs/LinuxX64ToEsxX64/python2-2.7.12/bin
cp ~/colo01/da/ToolsAndLibs/LinuxX64ToEsxX64/Python-2.7.12.da1/bin/python .

/da/ToolsAndLibs/LinuxX64ToLinuxX64/gdb-7.10.da1/bin/gdb -q -iex "set sysroot /tmp/esx-sysroot" ./python python-core.00
set solib-search-path /da/ToolsAndLibs/LinuxX64ToEsxX64/Python-2.7.12/lib/python2.7/lib-dynload

source /da/ToolsAndLibs/LinuxX64ToLinuxX64/Python-2.7.12/python-gdb.py

/auto/home/jeremy$cat .gdbinit
set print pretty on
set pagination off
set print demangle
set print asm-demangle
set solib-search-path /da/pydbg/lib/python2.7/lib-dynload
source /da/pydbg/python-gdb.py
source /da/main/Scripts/gdbpython.py

(gdb) source /da/ToolsAndLibs/LinuxX64ToLinuxX64/Python-2.7.12/python-gdb.py
(gdb) py-bt
Traceback (most recent call first):
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 359, in wait
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 614, in wait
  File "/opt/datrium/PythonRoot/datrium/platform/esx/esx_kvstore.py", line 789, in _disk_io_thread_run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 754, in run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 801, in __bootstrap_inner
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 774, in __bootstrap

(gdb) info threads
  Id   Target Id         Frame 
  9    LWP 48408002      0x000000000f6579a3 in select () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-5050593/lib64/libc.so.6
  8    LWP 48408001      0x000000000f6579a3 in select () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-5050593/lib64/libc.so.6
  7    LWP 48440768      0x000000000f6579a3 in select () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-5050593/lib64/libc.so.6
  6    LWP 48440767      0x000000000f6579a3 in select () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-5050593/lib64/libc.so.6
  5    LWP 48407982      0x000000000ecf3fc0 in sem_wait () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-5050593/lib64/libpthread.so.0
  4    LWP 79766745      0x000000000ecf3fc0 in sem_wait () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-5050593/lib64/libpthread.so.0
  3    LWP 48440727      0x000000000f6579a3 in select () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-5050593/lib64/libc.so.6
  2    LWP 48440694      0x000000000ecf4d8d in read () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-5050593/lib64/libpthread.so.0
* 1    LWP 48440726      0x000000000f6579a3 in select () from /da/ToolsAndLibs/LinuxX64ToEsxX64/esx_sysroot/build-5050593/lib64/libc.so.6

(gdb) t a a py-bt

Thread 9 (LWP 41449865):
Traceback (most recent call first):
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 359, in wait
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 614, in wait
  File "/opt/datrium/PythonRoot/datrium/platform/esx/esx_hostd.py", line 97, in _keep_hostd_connection_alive
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 754, in run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 801, in __bootstrap_inner
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 774, in __bootstrap

Thread 8 (LWP 41449864):
Traceback (most recent call first):
  File "/opt/datrium/PythonRoot/datrium/platform/common/event_loop.py", line 213, in run
  File "/opt/datrium/PythonRoot/datrium/platform/raid_mgr/raid_mgr.py", line 120, in run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 801, in __bootstrap_inner
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 774, in __bootstrap

Thread 7 (LWP 41449863):
Traceback (most recent call first):
  File "/opt/datrium/PythonRoot/datrium/platform/common/event_loop.py", line 213, in run
  File "/opt/datrium/PythonRoot/datrium/platform/ssd_mgr/ssd_mgr.py", line 821, in run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 801, in __bootstrap_inner
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 774, in __bootstrap

Thread 6 (LWP 41449862):
Traceback (most recent call first):
  File "/opt/datrium/PythonRoot/datrium/platform/esx/esx_config.py", line 288, in wait_for_change
  File "/opt/datrium/PythonRoot/datrium/platform/esx/advcfg_listener.py", line 464, in listen_for_updates
  File "/opt/datrium/PythonRoot/datrium/platform/esx/advcfg_listener.py", line 78, in run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 754, in run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 801, in __bootstrap_inner
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 774, in __bootstrap

Thread 5 (LWP 41449845):
Traceback (most recent call first):
  Waiting for the GIL
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 340, in wait
  File "/opt/datrium/bin/esx_platmgr.py", line 105, in run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 801, in __bootstrap_inner
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 774, in __bootstrap

Thread 4 (LWP 45943497):
Traceback (most recent call first):
  Waiting for the GIL
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 340, in wait
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 614, in wait
  File "/opt/datrium/PythonRoot/datrium/logging/directio.py", line 144, in _flusher_thread_run
---Type <return> to continue, or q <return> to quit---
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 754, in run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 801, in __bootstrap_inner
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 774, in __bootstrap

Thread 3 (LWP 41449816):
Traceback (most recent call first):
  File "/opt/datrium/PythonRoot/datrium/platform/esx/esx_kvstore.py", line 739, in _symlink_to_paths_or_wait
  File "/opt/datrium/PythonRoot/datrium/platform/esx/esx_kvstore.py", line 770, in _disk_io_thread_run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 754, in run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 801, in __bootstrap_inner
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 774, in __bootstrap

Thread 2 (LWP 41449752):
Traceback (most recent call first):
  File "/opt/datrium/python2/lib/python2.7/subprocess.py", line 476, in _eintr_retry_call
  File "/opt/datrium/python2/lib/python2.7/subprocess.py", line 1319, in _execute_child
  File "/opt/datrium/python2/lib/python2.7/subprocess.py", line 711, in __init__
  File "/opt/datrium/PythonRoot/datrium/utils/vsi.py", line 40, in _check_output
  File "/opt/datrium/PythonRoot/datrium/utils/vsi.py", line 66, in get
  File "/opt/datrium/PythonRoot/datrium/platform/esx/esx_net.py", line 243, in monitor_network
  File "/opt/datrium/PythonRoot/datrium/platform/common/event_loop.py", line 222, in run
  File "/opt/datrium/bin/esx_platmgr.py", line 1365, in platmgr_main
  File "/opt/datrium/bin/esx_platmgr.py", line 1472, in main
  File "/opt/datrium/bin/esx_platmgr.py", line 1489, in <module>

Thread 1 (LWP 41449815):
Traceback (most recent call first):
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 359, in wait
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 614, in wait
  File "/opt/datrium/PythonRoot/datrium/platform/esx/esx_kvstore.py", line 789, in _disk_io_thread_run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 754, in run
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 801, in __bootstrap_inner
  File "/opt/datrium/python2/lib/python2.7/threading.py", line 774, in __bootstrap


**********************************************
Mem Leak
**********************************************
(gdb) thread-list
65535  BOOTSTRAP:12552874                                               : RUNNING  Gen 0       PREEMPTIVE  
(gdb) bt
#0  0x00000000007ece08 in AtomicFreeList_DeinitWithCount (expectedTobeAllocated=<optimized out>, fl=<optimized out>) at Include/AtomicFreeList.h:390
#1  AtomicFreeList_Deinit (fl=<optimized out>) at Include/AtomicFreeList.h:412
#2  MemMalloc_ModuleDeinit () at Common/Mem/MemMalloc.c:208
#3  0x00000000004e3583 in Deinit (pe=<optimized out>) at Common/Bootstrap/Bootstrap.c:903
#4  0x00000000004e382a in Bootstrap_Deinit (pe=0x14593e0 <upgradeMgrProcEntry>) at Common/Bootstrap/Bootstrap.c:1345
#5  0x00000000004e9d88 in _finalCleanup (exitMode=<optimized out>) at Common/Bootstrap/Bootstrap.c:1431
#6  Bootstrap_Main (argc=65535) at Common/Bootstrap/Bootstrap.c:1386
#7  0x00000000004cd154 in main (argc=3, argv=0x7fffffffecc8) at Platform/UpgradeMgr/Main/UpgradeMgrMain.c:80

(gdb) memctxt-list
POINTER                          MEMCTXT NAME                
(MemCtxt*)0x24c9d20              GLOBAL

(gdb) memctxt-list-mobs (MemCtxt*)0x24c9d20 
The Mobs allocated on MemCtxt <GLOBAL> are:
(Mob)0xea1000ef94
(Mob)0x2d1000ef9e
(Mob)0x2a85000efab
(Mob)0x1063000f0d6
(Mob)0x33f3000f0d7
(Mob)0x306b000f0f4
(Mob)0x2d03000f109
(Mob)0x3a99000f10f
(Mob)0x7000f16d
(Mob)0x7000f16e
(Mob)0x7000f178
(Mob)0x8c9000f17d
(Mob)0x85f000f18b
(Mob)0x6f11000f1a9
(Mob)0x38f000f1c9
(Mob)0x595000f1cd
(Mob)0x3ef000f1ce
(Mob)0x281f000f1d8
(Mob)0x102b000f1d9
(Mob)0x8d7000f1f0
(Mob)0x6a57000f251
(Mob)0x164b000f25b
(Mob)0x1613000f2dc
(Mob)0x17d7000f326
(Mob)0x1201000f419
(Mob)0x48bf000f41f
(Mob)0x335f000f445
(Mob)0x2d3f000f453
(Mob)0x34b1000f45d
(Mob)0x30b3000f4f1
(Mob)0x3087000f549
(Mob)0x37a5000f55c
(Mob)0xfb1000f580
(Mob)0x25fd000f5fd
(Mob)0x5b9f000f705

(gdb) mob-print-details (Mob)0xea1000ef94
MOB            : 0xea1000ef94
TYPE           : Mob
HEAP TYPE      : 2 '\002'
Ref Idx        : 61331
OBJDESC        : 0x276ce20
BEGIN          : 8
SIZE           : 37 (at MOB_OBJEND)
OBJ SIZE       : 45
OBJ REFCNT     : 1
MEMCTXT        : GLOBAL
ALLOCLOC       : Common/Da/DaString.c:38
PTR            : (uint8 *)0x7ffff3049748 (addressable size = 37 bytes)
                 (Mob covers only part of the object)
(gdb) mob-print-details (Mob)0xea1000ef94
MOB            : 0xea1000ef94
TYPE           : Mob
HEAP TYPE      : 2 '\002'
Ref Idx        : 61331
OBJDESC        : 0x276ce20
BEGIN          : 8
SIZE           : 37 (at MOB_OBJEND)
OBJ SIZE       : 45
OBJ REFCNT     : 1
MEMCTXT        : GLOBAL
ALLOCLOC       : Common/Da/DaString.c:38
PTR            : (uint8 *)0x7ffff3049748 (addressable size = 37 bytes)
                 (Mob covers only part of the object)
(gdb) mob-print-details (Mob)0x2d1000ef9e
MOB            : 0x2d1000ef9e
TYPE           : Mob
HEAP TYPE      : 2 '\002'
Ref Idx        : 61341
OBJDESC        : 0x276c988
BEGIN          : 8
SIZE           : 11 (at MOB_OBJEND)
OBJ SIZE       : 19
OBJ REFCNT     : 1
MEMCTXT        : GLOBAL
ALLOCLOC       : Common/Da/DaString.c:38
PTR            : (uint8 *)0x7ffff49db4b8 (addressable size = 11 bytes)
                 (Mob covers only part of the object)
(gdb) mob-print-details (Mob)0x2a85000efab
MOB            : 0x2a85000efab
TYPE           : Mob
HEAP TYPE      : 2 '\002'
Ref Idx        : 61354
OBJDESC        : 0x276d4b0
BEGIN          : 8
SIZE           : 18 (at MOB_OBJEND)
OBJ SIZE       : 26
OBJ REFCNT     : 1
MEMCTXT        : GLOBAL
ALLOCLOC       : Common/Da/DaString.c:38
PTR            : (uint8 *)0x7ffff304a928 (addressable size = 18 bytes)
                 (Mob covers only part of the object)
(gdb) mob-print-details (Mob)0x1063000f0d6
MOB            : 0x1063000f0d6
TYPE           : Mob
HEAP TYPE      : 2 '\002'
Ref Idx        : 61653
OBJDESC        : 0x276e02c
BEGIN          : 8
SIZE           : 18 (at MOB_OBJEND)
OBJ SIZE       : 26
OBJ REFCNT     : 1
MEMCTXT        : GLOBAL
ALLOCLOC       : Common/Da/DaString.c:38
PTR            : (uint8 *)0x7ffff49d7f28 (addressable size = 18 bytes)
                 (Mob covers only part of the object)
(gdb) mob-print-details (Mob)0x7000f178
MOB            : 0x7000f178
TYPE           : Mob
HEAP TYPE      : 2 '\002'
Ref Idx        : 61815
OBJDESC        : 0x276deb2
BEGIN          : 0
SIZE           : 72 (at MOB_OBJEND)
OBJ SIZE       : 72
OBJ REFCNT     : 1
MEMCTXT        : GLOBAL
ALLOCLOC       : Platform/UpgradeMgr/MasterSvr/UpgradeTaskImpl.c:1452
PTR            : (uint8 *)0x7ffff32ce340 (addressable size = 72 bytes)
                 (Mob covers entire object)


**********************************************
thread stuck: 34330
**********************************************
The problem here is, too many outstanding rpc requests.

Too many, because
(gdb) thread-find-frame NAME == AssignSFH
#8 AssignSFH in thread 1823 NfsProxy3WriteSvc::6:435718736:440214846:0 : BLOCKED Gen 3608 COOPERATIVE
#8 AssignSFH in thread 1857 ONC_RPC:900887356296 : BLOCKED Gen 3264 COOPERATIVE
#8 AssignSFH in thread 1858 ONC_RPC:900887356296 : BLOCKED Gen 3384 COOPERATIVE
#8 AssignSFH in thread 1864 ONC_RPC:900887356296 : BLOCKED Gen 3250 COOPERATIVE
#8 AssignSFH in thread 1865 ONC_RPC:900887356296 : BLOCKED Gen 3393 COOPERATIVE
#8 AssignSFH in thread 1884 ONC_RPC:900887356296 : BLOCKED Gen 3246 COOPERATIVE
#8 AssignSFH in thread 1894 ONC_RPC:900887356296 : BLOCKED Gen 3232 COOPERATIVE
#8 AssignSFH in thread 1913 ONC_RPC:900887356296 : BLOCKED Gen 3279 COOPERATIVE
#8 AssignSFH in thread 1923 ONC_RPC:900887356296 : BLOCKED Gen 2986 COOPERATIVE
#8 AssignSFH in thread 1925 ONC_RPC:900887356296 : BLOCKED Gen 3263 COOPERATIVE
#8 AssignSFH in thread 1980 ONC_RPC:900887356296 : BLOCKED Gen 3180 COOPERATIVE
#8 AssignSFH in thread 1996 NfsProxy3WriteSvc::6:435658145:440196020:0 : BLOCKED Gen 3294 COOPERATIVE
#8 AssignSFH in thread 1998 ONC_RPC:900887356296 : BLOCKED Gen 3248 COOPERATIVE
#8 AssignSFH in thread 2021 ONC_RPC:900887356296 : BLOCKED Gen 3150 COOPERATIVE
#8 AssignSFH in thread 2022 ONC_RPC:900887356296 : BLOCKED Gen 3294 COOPERATIVE
#8 AssignSFH in thread 2037 ONC_RPC:900887356296 : BLOCKED Gen 3266 COOPERATIVE
