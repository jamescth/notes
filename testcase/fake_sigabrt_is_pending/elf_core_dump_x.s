0xffffffff802b1ade <elf_core_dump>:	push   %r15
0xffffffff802b1ae0 <elf_core_dump+2>:	push   %r14
0xffffffff802b1ae2 <elf_core_dump+4>:	push   %r13
0xffffffff802b1ae4 <elf_core_dump+6>:	mov    %rsi,%r13
0xffffffff802b1ae7 <elf_core_dump+9>:	push   %r12
0xffffffff802b1ae9 <elf_core_dump+11>:	push   %rbp
0xffffffff802b1aea <elf_core_dump+12>:	push   %rbx
0xffffffff802b1aeb <elf_core_dump+13>:	sub    $0x128,%rsp
0xffffffff802b1af2 <elf_core_dump+20>:	mov    %gs:0x0,%rax
0xffffffff802b1afb <elf_core_dump+29>:	lea    0xf0(%rsp),%r14
0xffffffff802b1b03 <elf_core_dump+37>:	mov    0x688(%rax),%rax
0xffffffff802b1b0a <elf_core_dump+44>:	mov    %rdi,0x78(%rsp)
0xffffffff802b1b0f <elf_core_dump+49>:	mov    0x1c8(%rax),%rax
0xffffffff802b1b16 <elf_core_dump+56>:	mov    %rdx,0x68(%rsp)
0xffffffff802b1b1b <elf_core_dump+61>:	mov    %rax,0x80(%rsp)
0xffffffff802b1b23 <elf_core_dump+69>:	mov    %ecx,0xa4(%rsp)
0xffffffff802b1b2a <elf_core_dump+76>:	xor    %eax,%eax
0xffffffff802b1b2c <elf_core_dump+78>:	mov    %r14,0xf0(%rsp)
0xffffffff802b1b34 <elf_core_dump+86>:	mov    %r14,0xf8(%rsp)
0xffffffff802b1b3c <elf_core_dump+94>:	callq  0xffffffff802b19ef <sigabrt_is_pending>
0xffffffff802b1b41 <elf_core_dump+99>:	test   %eax,%eax
0xffffffff802b1b43 <elf_core_dump+101>:	jne    0xffffffff802b284a <elf_core_dump+3436>
0xffffffff802b1b49 <elf_core_dump+107>:	mov    %gs:0x0,%rax
0xffffffff802b1b52 <elf_core_dump+116>:	mov    $0xffffffff80563610,%rdi
0xffffffff802b1b59 <elf_core_dump+123>:	mov    0x1d8(%rax),%esi
0xffffffff802b1b5f <elf_core_dump+129>:	xor    %eax,%eax
0xffffffff802b1b61 <elf_core_dump+131>:	callq  0xffffffff80233178 <printk>
0xffffffff802b1b66 <elf_core_dump+136>:	mov    $0xd0,%esi
0xffffffff802b1b6b <elf_core_dump+141>:	mov    3318526(%rip),%rdi        # 0xffffffff805dbe70 <malloc_sizes+32>
0xffffffff802b1b72 <elf_core_dump+148>:	callq  0xffffffff8027ce2f <kmem_cache_alloc>
0xffffffff802b1b77 <elf_core_dump+153>:	mov    %rax,%rbp
0xffffffff802b1b7a <elf_core_dump+156>:	test   %rax,%rax
0xffffffff802b1b7d <elf_core_dump+159>:	je     0xffffffff802b2888 <elf_core_dump+3498>
0xffffffff802b1b83 <elf_core_dump+165>:	mov    $0xd0,%esi
0xffffffff802b1b88 <elf_core_dump+170>:	mov    3318593(%rip),%rdi        # 0xffffffff805dbed0 <malloc_sizes+128>
0xffffffff802b1b8f <elf_core_dump+177>:	callq  0xffffffff8027ce2f <kmem_cache_alloc>
0xffffffff802b1b94 <elf_core_dump+182>:	mov    %rax,%rbx
0xffffffff802b1b97 <elf_core_dump+185>:	test   %rax,%rax
0xffffffff802b1b9a <elf_core_dump+188>:	je     0xffffffff802b289b <elf_core_dump+3517>
0xffffffff802b1ba0 <elf_core_dump+194>:	mov    $0xd0,%esi
0xffffffff802b1ba5 <elf_core_dump+199>:	mov    3318516(%rip),%rdi        # 0xffffffff805dbea0 <malloc_sizes+80>
0xffffffff802b1bac <elf_core_dump+206>:	callq  0xffffffff8027ce2f <kmem_cache_alloc>
0xffffffff802b1bb1 <elf_core_dump+211>:	mov    %rax,%r12
0xffffffff802b1bb4 <elf_core_dump+214>:	test   %rax,%rax
0xffffffff802b1bb7 <elf_core_dump+217>:	je     0xffffffff802b28ac <elf_core_dump+3534>
0xffffffff802b1bbd <elf_core_dump+223>:	mov    $0xd0,%esi
0xffffffff802b1bc2 <elf_core_dump+228>:	mov    3318487(%rip),%rdi        # 0xffffffff805dbea0 <malloc_sizes+80>
0xffffffff802b1bc9 <elf_core_dump+235>:	callq  0xffffffff8027ce2f <kmem_cache_alloc>
0xffffffff802b1bce <elf_core_dump+240>:	mov    %rax,%r15
0xffffffff802b1bd1 <elf_core_dump+243>:	test   %rax,%rax
0xffffffff802b1bd4 <elf_core_dump+246>:	je     0xffffffff802b28bd <elf_core_dump+3551>
0xffffffff802b1bda <elf_core_dump+252>:	mov    $0xd0,%esi
0xffffffff802b1bdf <elf_core_dump+257>:	mov    3318506(%rip),%rdi        # 0xffffffff805dbed0 <malloc_sizes+128>
0xffffffff802b1be6 <elf_core_dump+264>:	callq  0xffffffff8027ce2f <kmem_cache_alloc>
0xffffffff802b1beb <elf_core_dump+269>:	mov    %rax,0x70(%rsp)
0xffffffff802b1bf0 <elf_core_dump+274>:	test   %rax,%rax
0xffffffff802b1bf3 <elf_core_dump+277>:	je     0xffffffff802b28cb <elf_core_dump+3565>
0xffffffff802b1bf9 <elf_core_dump+283>:	mov    $0xffffffff805cddf0,%rax
0xffffffff802b1c00 <elf_core_dump+290>:	mov    %r14,%r9
0xffffffff802b1c03 <elf_core_dump+293>:	cmpq   $0x0,0x78(%rsp)
0xffffffff802b1c09 <elf_core_dump+299>:	jne    0xffffffff802b1cbb <elf_core_dump+477>
0xffffffff802b1c0f <elf_core_dump+305>:	movl   $0x0,0x60(%rsp)
0xffffffff802b1c17 <elf_core_dump+313>:	jmpq   0xffffffff802b1e03 <elf_core_dump+805>
0xffffffff802b1c1c <elf_core_dump+318>:	mov    %rdx,%r14
0xffffffff802b1c1f <elf_core_dump+321>:	mov    %gs:0x0,%rax
0xffffffff802b1c28 <elf_core_dump+330>:	mov    0x1a8(%r14),%rcx
0xffffffff802b1c2f <elf_core_dump+337>:	cmp    %rcx,0x1a8(%rax)
0xffffffff802b1c36 <elf_core_dump+344>:	jne    0xffffffff802b1ca1 <elf_core_dump+451>
0xffffffff802b1c38 <elf_core_dump+346>:	cmp    %r14,%rax
0xffffffff802b1c3b <elf_core_dump+349>:	je     0xffffffff802b1ca1 <elf_core_dump+451>
0xffffffff802b1c3d <elf_core_dump+351>:	mov    $0x20,%esi
0xffffffff802b1c42 <elf_core_dump+356>:	mov    %rdx,0x40(%rsp)
0xffffffff802b1c47 <elf_core_dump+361>:	mov    %r9,0x48(%rsp)
0xffffffff802b1c4c <elf_core_dump+366>:	mov    3318421(%rip),%rdi        # 0xffffffff805dbee8 <malloc_sizes+152>
0xffffffff802b1c53 <elf_core_dump+373>:	callq  0xffffffff8027ce2f <kmem_cache_alloc>
0xffffffff802b1c58 <elf_core_dump+378>:	mov    0x40(%rsp),%rdx
0xffffffff802b1c5d <elf_core_dump+383>:	mov    %rax,%rsi
0xffffffff802b1c60 <elf_core_dump+386>:	test   %rax,%rax
0xffffffff802b1c63 <elf_core_dump+389>:	mov    0x48(%rsp),%r9
0xffffffff802b1c68 <elf_core_dump+394>:	je     0xffffffff802b1c76 <elf_core_dump+408>
0xffffffff802b1c6a <elf_core_dump+396>:	mov    %rax,%rdi
0xffffffff802b1c6d <elf_core_dump+399>:	mov    $0xee,%ecx
0xffffffff802b1c72 <elf_core_dump+404>:	xor    %eax,%eax
0xffffffff802b1c74 <elf_core_dump+406>:	repz stos %eax,%es:(%edi)
0xffffffff802b1c76 <elf_core_dump+408>:	test   %rsi,%rsi
0xffffffff802b1c79 <elf_core_dump+411>:	je     0xffffffff802b28cb <elf_core_dump+3565>
0xffffffff802b1c7f <elf_core_dump+417>:	mov    0xf0(%rsp),%rax
0xffffffff802b1c87 <elf_core_dump+425>:	mov    %r14,0x360(%rsi)
0xffffffff802b1c8e <elf_core_dump+432>:	mov    %rsi,0x8(%rax)
0xffffffff802b1c92 <elf_core_dump+436>:	mov    %rax,(%rsi)
0xffffffff802b1c95 <elf_core_dump+439>:	mov    %r9,0x8(%rsi)
0xffffffff802b1c99 <elf_core_dump+443>:	mov    %rsi,0xf0(%rsp)
0xffffffff802b1ca1 <elf_core_dump+451>:	mov    0x260(%r14),%r14
0xffffffff802b1ca8 <elf_core_dump+458>:	sub    $0x260,%r14
0xffffffff802b1caf <elf_core_dump+465>:	cmp    %rdx,%r14
0xffffffff802b1cb2 <elf_core_dump+468>:	jne    0xffffffff802b1c1f <elf_core_dump+321>
0xffffffff802b1cb8 <elf_core_dump+474>:	mov    %r14,%rax
0xffffffff802b1cbb <elf_core_dump+477>:	mov    0x178(%rax),%rdx
0xffffffff802b1cc2 <elf_core_dump+484>:	sub    $0x178,%rdx
0xffffffff802b1cc9 <elf_core_dump+491>:	cmp    $0xffffffff805cddf0,%rdx
0xffffffff802b1cd0 <elf_core_dump+498>:	jne    0xffffffff802b1c1c <elf_core_dump+318>
0xffffffff802b1cd6 <elf_core_dump+504>:	lea    0xf0(%rsp),%rdx
0xffffffff802b1cde <elf_core_dump+512>:	mov    0xf0(%rsp),%r14
0xffffffff802b1ce6 <elf_core_dump+520>:	movl   $0x0,0x60(%rsp)
0xffffffff802b1cee <elf_core_dump+528>:	mov    %rdx,0x28(%rsp)
0xffffffff802b1cf3 <elf_core_dump+533>:	jmpq   0xffffffff802b1df2 <elf_core_dump+788>
0xffffffff802b1cf8 <elf_core_dump+538>:	mov    0x360(%r14),%rcx
0xffffffff802b1cff <elf_core_dump+545>:	mov    0x78(%rsp),%rdx
0xffffffff802b1d04 <elf_core_dump+550>:	mov    %rcx,0x58(%rsp)
0xffffffff802b1d09 <elf_core_dump+555>:	movl   $0x0,0x3b0(%r14)
0xffffffff802b1d14 <elf_core_dump+566>:	lea    0x10(%r14),%rcx
0xffffffff802b1d18 <elf_core_dump+570>:	mov    0x58(%rsp),%rsi
0xffffffff802b1d1d <elf_core_dump+575>:	mov    %rcx,%rdi
0xffffffff802b1d20 <elf_core_dump+578>:	mov    %rcx,0x38(%rsp)
0xffffffff802b1d25 <elf_core_dump+583>:	callq  0xffffffff802b182a <fill_prstatus>
0xffffffff802b1d2a <elf_core_dump+588>:	lea    0x80(%r14),%rsi
0xffffffff802b1d31 <elf_core_dump+595>:	mov    0x58(%rsp),%rdi
0xffffffff802b1d36 <elf_core_dump+600>:	callq  0xffffffff8020ae9f <dump_task_regs>
0xffffffff802b1d3b <elf_core_dump+605>:	movq   $0xffffffff80563639,0x368(%r14)
0xffffffff802b1d46 <elf_core_dump+616>:	movl   $0x1,0x370(%r14)
0xffffffff802b1d51 <elf_core_dump+627>:	movl   $0x150,0x374(%r14)
0xffffffff802b1d5c <elf_core_dump+638>:	lea    0x368(%r14),%rdi
0xffffffff802b1d63 <elf_core_dump+645>:	mov    0x38(%rsp),%rcx
0xffffffff802b1d68 <elf_core_dump+650>:	incl   0x3b0(%r14)
0xffffffff802b1d6f <elf_core_dump+657>:	mov    %rcx,0x378(%r14)
0xffffffff802b1d76 <elf_core_dump+664>:	callq  0xffffffff802b1914 <notesize>
0xffffffff802b1d7b <elf_core_dump+669>:	lea    0x160(%r14),%rdx
0xffffffff802b1d82 <elf_core_dump+676>:	mov    %eax,0x50(%rsp)
0xffffffff802b1d86 <elf_core_dump+680>:	mov    %rdx,%rsi
0xffffffff802b1d89 <elf_core_dump+683>:	mov    %rdx,0x40(%rsp)
0xffffffff802b1d8e <elf_core_dump+688>:	mov    0x58(%rsp),%rdi
0xffffffff802b1d93 <elf_core_dump+693>:	callq  0xffffffff80210e8a <dump_task_fpu>
0xffffffff802b1d98 <elf_core_dump+698>:	mov    %eax,0x158(%r14)
0xffffffff802b1d9f <elf_core_dump+705>:	test   %eax,%eax
0xffffffff802b1da1 <elf_core_dump+707>:	mov    0x40(%rsp),%rdx
0xffffffff802b1da6 <elf_core_dump+712>:	je     0xffffffff802b1de7 <elf_core_dump+777>
0xffffffff802b1da8 <elf_core_dump+714>:	movq   $0xffffffff80563639,0x380(%r14)
0xffffffff802b1db3 <elf_core_dump+725>:	movl   $0x2,0x388(%r14)
0xffffffff802b1dbe <elf_core_dump+736>:	movl   $0x200,0x38c(%r14)
0xffffffff802b1dc9 <elf_core_dump+747>:	mov    %rdx,0x390(%r14)
0xffffffff802b1dd0 <elf_core_dump+754>:	incl   0x3b0(%r14)
0xffffffff802b1dd7 <elf_core_dump+761>:	lea    0x380(%r14),%rdi
0xffffffff802b1dde <elf_core_dump+768>:	callq  0xffffffff802b1914 <notesize>
0xffffffff802b1de3 <elf_core_dump+773>:	add    %eax,0x50(%rsp)
0xffffffff802b1de7 <elf_core_dump+777>:	mov    0x50(%rsp),%eax
0xffffffff802b1deb <elf_core_dump+781>:	mov    (%r14),%r14
0xffffffff802b1dee <elf_core_dump+784>:	add    %eax,0x60(%rsp)
0xffffffff802b1df2 <elf_core_dump+788>:	mov    (%r14),%rax
0xffffffff802b1df5 <elf_core_dump+791>:	prefetcht0 (%rax)
0xffffffff802b1df8 <elf_core_dump+794>:	cmp    0x28(%rsp),%r14
0xffffffff802b1dfd <elf_core_dump+799>:	jne    0xffffffff802b1cf8 <elf_core_dump+538>
0xffffffff802b1e03 <elf_core_dump+805>:	xor    %eax,%eax
0xffffffff802b1e05 <elf_core_dump+807>:	mov    $0x54,%ecx
0xffffffff802b1e0a <elf_core_dump+812>:	mov    %rbx,%rdi
0xffffffff802b1e0d <elf_core_dump+815>:	repz stos %eax,%es:(%edi)
0xffffffff802b1e0f <elf_core_dump+817>:	mov    %rbx,%rdi
0xffffffff802b1e12 <elf_core_dump+820>:	mov    0x78(%rsp),%rdx
0xffffffff802b1e17 <elf_core_dump+825>:	mov    %gs:0x0,%rsi
0xffffffff802b1e20 <elf_core_dump+834>:	callq  0xffffffff802b182a <fill_prstatus>
0xffffffff802b1e25 <elf_core_dump+839>:	mov    0x0(%r13),%rax
0xffffffff802b1e29 <elf_core_dump+843>:	mov    %rax,0x70(%rbx)
0xffffffff802b1e2d <elf_core_dump+847>:	mov    0x8(%r13),%rax
0xffffffff802b1e31 <elf_core_dump+851>:	mov    %rax,0x78(%rbx)
0xffffffff802b1e35 <elf_core_dump+855>:	mov    0x10(%r13),%rax
0xffffffff802b1e39 <elf_core_dump+859>:	mov    %rax,0x80(%rbx)
0xffffffff802b1e40 <elf_core_dump+866>:	mov    0x18(%r13),%rax
0xffffffff802b1e44 <elf_core_dump+870>:	mov    %rax,0x88(%rbx)
0xffffffff802b1e4b <elf_core_dump+877>:	mov    0x20(%r13),%rax
0xffffffff802b1e4f <elf_core_dump+881>:	mov    %rax,0x90(%rbx)
0xffffffff802b1e56 <elf_core_dump+888>:	mov    0x28(%r13),%rax
0xffffffff802b1e5a <elf_core_dump+892>:	mov    %rax,0x98(%rbx)
0xffffffff802b1e61 <elf_core_dump+899>:	mov    0x30(%r13),%rax
0xffffffff802b1e65 <elf_core_dump+903>:	mov    %rax,0xa0(%rbx)
0xffffffff802b1e6c <elf_core_dump+910>:	mov    0x38(%r13),%rax
0xffffffff802b1e70 <elf_core_dump+914>:	mov    %rax,0xa8(%rbx)
0xffffffff802b1e77 <elf_core_dump+921>:	mov    0x40(%r13),%rax
0xffffffff802b1e7b <elf_core_dump+925>:	mov    %rax,0xb0(%rbx)
0xffffffff802b1e82 <elf_core_dump+932>:	mov    0x48(%r13),%rax
0xffffffff802b1e86 <elf_core_dump+936>:	mov    %rax,0xb8(%rbx)
0xffffffff802b1e8d <elf_core_dump+943>:	mov    0x50(%r13),%rax
0xffffffff802b1e91 <elf_core_dump+947>:	mov    %rax,0xc0(%rbx)
0xffffffff802b1e98 <elf_core_dump+954>:	mov    0x58(%r13),%rax
0xffffffff802b1e9c <elf_core_dump+958>:	mov    %rax,0xc8(%rbx)
0xffffffff802b1ea3 <elf_core_dump+965>:	mov    0x60(%r13),%rax
0xffffffff802b1ea7 <elf_core_dump+969>:	mov    %rax,0xd0(%rbx)
0xffffffff802b1eae <elf_core_dump+976>:	mov    0x68(%r13),%rax
0xffffffff802b1eb2 <elf_core_dump+980>:	mov    %rax,0xd8(%rbx)
0xffffffff802b1eb9 <elf_core_dump+987>:	mov    0x70(%r13),%rax
0xffffffff802b1ebd <elf_core_dump+991>:	mov    %rax,0xe0(%rbx)
0xffffffff802b1ec4 <elf_core_dump+998>:	mov    0x78(%r13),%rax
0xffffffff802b1ec8 <elf_core_dump+1002>:	mov    %rax,0xe8(%rbx)
0xffffffff802b1ecf <elf_core_dump+1009>:	mov    0x80(%r13),%rax
0xffffffff802b1ed6 <elf_core_dump+1016>:	mov    %rax,0xf0(%rbx)
0xffffffff802b1edd <elf_core_dump+1023>:	mov    0x88(%r13),%rax
0xffffffff802b1ee4 <elf_core_dump+1030>:	mov    %gs:0x0,%rdi
0xffffffff802b1eed <elf_core_dump+1039>:	mov    %rax,0xf8(%rbx)
0xffffffff802b1ef4 <elf_core_dump+1046>:	mov    0x90(%r13),%rax
0xffffffff802b1efb <elf_core_dump+1053>:	mov    %rax,0x100(%rbx)
0xffffffff802b1f02 <elf_core_dump+1060>:	mov    0x98(%r13),%rax
0xffffffff802b1f09 <elf_core_dump+1067>:	mov    %rax,0x108(%rbx)
0xffffffff802b1f10 <elf_core_dump+1074>:	mov    0xa0(%r13),%rax
0xffffffff802b1f17 <elf_core_dump+1081>:	mov    %rax,0x110(%rbx)
0xffffffff802b1f1e <elf_core_dump+1088>:	mov    0x3c8(%rdi),%rax
0xffffffff802b1f25 <elf_core_dump+1095>:	mov    %rax,0x118(%rbx)
0xffffffff802b1f2c <elf_core_dump+1102>:	mov    0x3d0(%rdi),%rax
0xffffffff802b1f33 <elf_core_dump+1109>:	mov    %rax,0x120(%rbx)
0xffffffff802b1f3a <elf_core_dump+1116>:	mov    %ds,%eax
0xffffffff802b1f3c <elf_core_dump+1118>:	mov    %eax,%eax
0xffffffff802b1f3e <elf_core_dump+1120>:	mov    %rax,0x128(%rbx)
0xffffffff802b1f45 <elf_core_dump+1127>:	mov    %es,%eax
0xffffffff802b1f47 <elf_core_dump+1129>:	mov    %eax,%eax
0xffffffff802b1f49 <elf_core_dump+1131>:	mov    %rax,0x130(%rbx)
0xffffffff802b1f50 <elf_core_dump+1138>:	mov    %fs,%eax
0xffffffff802b1f52 <elf_core_dump+1140>:	mov    %eax,%eax
0xffffffff802b1f54 <elf_core_dump+1142>:	mov    %rax,0x138(%rbx)
0xffffffff802b1f5b <elf_core_dump+1149>:	mov    %gs,%eax
0xffffffff802b1f5d <elf_core_dump+1151>:	mov    %eax,%eax
0xffffffff802b1f5f <elf_core_dump+1153>:	mov    %rax,0x140(%rbx)
0xffffffff802b1f66 <elf_core_dump+1160>:	mov    0x1a8(%rdi),%rax
0xffffffff802b1f6d <elf_core_dump+1167>:	mov    0x58(%rax),%r14d
0xffffffff802b1f71 <elf_core_dump+1171>:	callq  0xffffffff8021fbf2 <get_gate_vma>
0xffffffff802b1f76 <elf_core_dump+1176>:	movb   $0x2,0x4(%rbp)
0xffffffff802b1f7a <elf_core_dump+1180>:	movb   $0x1,0x5(%rbp)
0xffffffff802b1f7e <elf_core_dump+1184>:	movb   $0x1,0x6(%rbp)
0xffffffff802b1f82 <elf_core_dump+1188>:	movb   $0x0,0x7(%rbp)
0xffffffff802b1f86 <elf_core_dump+1192>:	movw   $0x4,0x10(%rbp)
0xffffffff802b1f8c <elf_core_dump+1198>:	movw   $0x3e,0x12(%rbp)
0xffffffff802b1f92 <elf_core_dump+1204>:	movl   $0x1,0x14(%rbp)
0xffffffff802b1f99 <elf_core_dump+1211>:	movq   $0x0,0x18(%rbp)
0xffffffff802b1fa1 <elf_core_dump+1219>:	movq   $0x40,0x20(%rbp)
0xffffffff802b1fa9 <elf_core_dump+1227>:	movq   $0x0,0x28(%rbp)
0xffffffff802b1fb1 <elf_core_dump+1235>:	movl   $0x0,0x30(%rbp)
0xffffffff802b1fb8 <elf_core_dump+1242>:	movw   $0x40,0x34(%rbp)
0xffffffff802b1fbe <elf_core_dump+1248>:	movw   $0x38,0x36(%rbp)
0xffffffff802b1fc4 <elf_core_dump+1254>:	movw   $0x0,0x3a(%rbp)
0xffffffff802b1fca <elf_core_dump+1260>:	movw   $0x0,0x3c(%rbp)
0xffffffff802b1fd0 <elf_core_dump+1266>:	movw   $0x0,0x3e(%rbp)
0xffffffff802b1fd6 <elf_core_dump+1272>:	cmp    $0x1,%rax
0xffffffff802b1fda <elf_core_dump+1276>:	mov    %rax,0x58(%rsp)
0xffffffff802b1fdf <elf_core_dump+1281>:	sbb    $0xffffffffffffffff,%r14d
0xffffffff802b1fe3 <elf_core_dump+1285>:	mov    $0x22,%ecx
0xffffffff802b1fe8 <elf_core_dump+1290>:	inc    %r14d
0xffffffff802b1feb <elf_core_dump+1293>:	mov    %r12,%rdi
0xffffffff802b1fee <elf_core_dump+1296>:	mov    %r14d,0x50(%rsp)
0xffffffff802b1ff3 <elf_core_dump+1301>:	movl   $0x464c457f,0x0(%rbp)
0xffffffff802b1ffa <elf_core_dump+1308>:	movq   $0x0,0x8(%rbp)
0xffffffff802b2002 <elf_core_dump+1316>:	mov    0x50(%rsp),%edx
0xffffffff802b2006 <elf_core_dump+1320>:	mov    %dx,0x38(%rbp)
0xffffffff802b200a <elf_core_dump+1324>:	mov    %gs:0x0,%rax
0xffffffff802b2013 <elf_core_dump+1333>:	orl    $0x200,0x14(%rax)
0xffffffff802b201a <elf_core_dump+1340>:	movq   $0xffffffff80563639,(%r15)
0xffffffff802b2021 <elf_core_dump+1347>:	movl   $0x1,0x8(%r15)
0xffffffff802b2029 <elf_core_dump+1355>:	movl   $0x150,0xc(%r15)
0xffffffff802b2031 <elf_core_dump+1363>:	mov    %rbx,0x10(%r15)
0xffffffff802b2035 <elf_core_dump+1367>:	mov    %gs:0x0,%rax
0xffffffff802b203e <elf_core_dump+1376>:	mov    0x1a8(%rax),%rdx
0xffffffff802b2045 <elf_core_dump+1383>:	mov    0x210(%rax),%r14
0xffffffff802b204c <elf_core_dump+1390>:	xor    %eax,%eax
0xffffffff802b204e <elf_core_dump+1392>:	repz stos %eax,%es:(%edi)
0xffffffff802b2050 <elf_core_dump+1394>:	lea    0x38(%r12),%rdi
0xffffffff802b2055 <elf_core_dump+1399>:	mov    0x140(%rdx),%rsi
0xffffffff802b205c <elf_core_dump+1406>:	mov    0x148(%rdx),%rax
0xffffffff802b2063 <elf_core_dump+1413>:	mov    $0x4f,%cl
0xffffffff802b2065 <elf_core_dump+1415>:	sub    %esi,%eax
0xffffffff802b2067 <elf_core_dump+1417>:	cmp    $0x4f,%eax
0xffffffff802b206a <elf_core_dump+1420>:	cmovbe %eax,%ecx
0xffffffff802b206d <elf_core_dump+1423>:	mov    %ecx,%edx
0xffffffff802b206f <elf_core_dump+1425>:	mov    %ecx,0x38(%rsp)
0xffffffff802b2073 <elf_core_dump+1429>:	callq  0xffffffff803468e0 <copy_from_user>
0xffffffff802b2078 <elf_core_dump+1434>:	mov    0x38(%rsp),%ecx
0xffffffff802b207c <elf_core_dump+1438>:	test   %rax,%rax
0xffffffff802b207f <elf_core_dump+1441>:	jne    0xffffffff802b2161 <elf_core_dump+1667>
0xffffffff802b2085 <elf_core_dump+1447>:	mov    %r12,%rax
0xffffffff802b2088 <elf_core_dump+1450>:	xor    %edx,%edx
0xffffffff802b208a <elf_core_dump+1452>:	jmp    0xffffffff802b209b <elf_core_dump+1469>
0xffffffff802b208c <elf_core_dump+1454>:	cmpb   $0x0,0x38(%rax)
0xffffffff802b2090 <elf_core_dump+1458>:	jne    0xffffffff802b2096 <elf_core_dump+1464>
0xffffffff802b2092 <elf_core_dump+1460>:	movb   $0x20,0x38(%rax)
0xffffffff802b2096 <elf_core_dump+1464>:	inc    %edx
0xffffffff802b2098 <elf_core_dump+1466>:	inc    %rax
0xffffffff802b209b <elf_core_dump+1469>:	cmp    %ecx,%edx
0xffffffff802b209d <elf_core_dump+1471>:	jb     0xffffffff802b208c <elf_core_dump+1454>
0xffffffff802b209f <elf_core_dump+1473>:	mov    %ecx,%ecx
0xffffffff802b20a1 <elf_core_dump+1475>:	movb   $0x0,0x38(%r12,%rcx,1)
0xffffffff802b20a7 <elf_core_dump+1481>:	mov    0x1d8(%r14),%eax
0xffffffff802b20ae <elf_core_dump+1488>:	mov    %eax,0x18(%r12)
0xffffffff802b20b3 <elf_core_dump+1493>:	mov    0x1e8(%r14),%rax
0xffffffff802b20ba <elf_core_dump+1500>:	mov    0x1d8(%rax),%eax
0xffffffff802b20c0 <elf_core_dump+1506>:	mov    %eax,0x1c(%r12)
0xffffffff802b20c5 <elf_core_dump+1511>:	mov    0x688(%r14),%rax
0xffffffff802b20cc <elf_core_dump+1518>:	mov    0xe0(%rax),%eax
0xffffffff802b20d2 <elf_core_dump+1524>:	mov    %eax,0x20(%r12)
0xffffffff802b20d7 <elf_core_dump+1529>:	mov    0x688(%r14),%rax
0xffffffff802b20de <elf_core_dump+1536>:	mov    0xf0(%rax),%eax
0xffffffff802b20e4 <elf_core_dump+1542>:	mov    %eax,0x24(%r12)
0xffffffff802b20e9 <elf_core_dump+1547>:	xor    %eax,%eax
0xffffffff802b20eb <elf_core_dump+1549>:	mov    (%r14),%rdx
0xffffffff802b20ee <elf_core_dump+1552>:	test   %rdx,%rdx
0xffffffff802b20f1 <elf_core_dump+1555>:	je     0xffffffff802b20fc <elf_core_dump+1566>
0xffffffff802b20f3 <elf_core_dump+1557>:	mov    (%r14),%rax
0xffffffff802b20f6 <elf_core_dump+1560>:	bsf    %rax,%rax
0xffffffff802b20fa <elf_core_dump+1564>:	inc    %eax
0xffffffff802b20fc <elf_core_dump+1566>:	mov    %al,(%r12)
0xffffffff802b2100 <elf_core_dump+1570>:	mov    $0x2e,%dl
0xffffffff802b2102 <elf_core_dump+1572>:	cmp    $0x5,%eax
0xffffffff802b2105 <elf_core_dump+1575>:	ja     0xffffffff802b210f <elf_core_dump+1585>
0xffffffff802b2107 <elf_core_dump+1577>:	mov    %eax,%eax
0xffffffff802b2109 <elf_core_dump+1579>:	mov    0xffffffff8056369b(%rax),%dl
0xffffffff802b210f <elf_core_dump+1585>:	cmp    $0x5a,%dl
0xffffffff802b2112 <elf_core_dump+1588>:	mov    %dl,0x1(%r12)
0xffffffff802b2117 <elf_core_dump+1593>:	mov    %r14,%rdi
0xffffffff802b211a <elf_core_dump+1596>:	sete   0x2(%r12)
0xffffffff802b2120 <elf_core_dump+1602>:	callq  0xffffffff8022992f <task_nice>
0xffffffff802b2125 <elf_core_dump+1607>:	lea    0x380(%r14),%rsi
0xffffffff802b212c <elf_core_dump+1614>:	mov    %al,0x3(%r12)
0xffffffff802b2131 <elf_core_dump+1619>:	lea    0x28(%r12),%rdi
0xffffffff802b2136 <elf_core_dump+1624>:	mov    0x14(%r14),%edx
0xffffffff802b213a <elf_core_dump+1628>:	mov    %rdx,0x8(%r12)
0xffffffff802b213f <elf_core_dump+1633>:	mov    $0x10,%edx
0xffffffff802b2144 <elf_core_dump+1638>:	mov    0x338(%r14),%eax
0xffffffff802b214b <elf_core_dump+1645>:	mov    %eax,0x10(%r12)
0xffffffff802b2150 <elf_core_dump+1650>:	mov    0x348(%r14),%eax
0xffffffff802b2157 <elf_core_dump+1657>:	mov    %eax,0x14(%r12)
0xffffffff802b215c <elf_core_dump+1662>:	callq  0xffffffff80344f8b <strncpy>
0xffffffff802b2161 <elf_core_dump+1667>:	lea    0x18(%r15),%rax
0xffffffff802b2165 <elf_core_dump+1671>:	movq   $0xffffffff80563639,0x18(%r15)
0xffffffff802b216d <elf_core_dump+1679>:	movl   $0x3,0x8(%rax)
0xffffffff802b2174 <elf_core_dump+1686>:	movl   $0x88,0xc(%rax)
0xffffffff802b217b <elf_core_dump+1693>:	mov    %r12,0x10(%rax)
0xffffffff802b217f <elf_core_dump+1697>:	mov    %gs:0x0,%rax
0xffffffff802b2188 <elf_core_dump+1706>:	mov    0x1a8(%rax),%rcx
0xffffffff802b218f <elf_core_dump+1713>:	xor    %eax,%eax
0xffffffff802b2191 <elf_core_dump+1715>:	lea    0x160(%rcx),%rsi
0xffffffff802b2198 <elf_core_dump+1722>:	add    $0x2,%eax
0xffffffff802b219b <elf_core_dump+1725>:	movslq %eax,%rdx
0xffffffff802b219e <elf_core_dump+1728>:	cmpq   $0x0,0x150(%rcx,%rdx,8)
0xffffffff802b21a7 <elf_core_dump+1737>:	jne    0xffffffff802b2198 <elf_core_dump+1722>
0xffffffff802b21a9 <elf_core_dump+1739>:	lea    0x30(%r15),%rax
0xffffffff802b21ad <elf_core_dump+1743>:	shl    $0x3,%edx
0xffffffff802b21b0 <elf_core_dump+1746>:	movq   $0xffffffff80563639,0x30(%r15)
0xffffffff802b21b8 <elf_core_dump+1754>:	mov    %rsi,0x10(%rax)
0xffffffff802b21bc <elf_core_dump+1758>:	mov    %gs:0x0,%rdi
0xffffffff802b21c5 <elf_core_dump+1767>:	movl   $0x6,0x8(%rax)
0xffffffff802b21cc <elf_core_dump+1774>:	mov    %edx,0xc(%rax)
0xffffffff802b21cf <elf_core_dump+1777>:	mov    0x70(%rsp),%rsi
0xffffffff802b21d4 <elf_core_dump+1782>:	callq  0xffffffff80210e8a <dump_task_fpu>
0xffffffff802b21d9 <elf_core_dump+1787>:	movl   $0x3,0x8c(%rsp)
0xffffffff802b21e4 <elf_core_dump+1798>:	mov    %eax,0x148(%rbx)
0xffffffff802b21ea <elf_core_dump+1804>:	test   %eax,%eax
0xffffffff802b21ec <elf_core_dump+1806>:	je     0xffffffff802b221c <elf_core_dump+1854>
0xffffffff802b21ee <elf_core_dump+1808>:	lea    0x48(%r15),%rax
0xffffffff802b21f2 <elf_core_dump+1812>:	mov    0x70(%rsp),%rcx
0xffffffff802b21f7 <elf_core_dump+1817>:	movq   $0xffffffff80563639,0x48(%r15)
0xffffffff802b21ff <elf_core_dump+1825>:	movl   $0x2,0x8(%rax)
0xffffffff802b2206 <elf_core_dump+1832>:	movl   $0x200,0xc(%rax)
0xffffffff802b220d <elf_core_dump+1839>:	mov    %rcx,0x10(%rax)
0xffffffff802b2211 <elf_core_dump+1843>:	movl   $0x4,0x8c(%rsp)
0xffffffff802b221c <elf_core_dump+1854>:	mov    %gs:0x10,%rax
0xffffffff802b2225 <elf_core_dump+1863>:	cmpq   $0x3f,0x80(%rsp)
0xffffffff802b222e <elf_core_dump+1872>:	mov    0xffffffffffffe048(%rax),%rdx
0xffffffff802b2235 <elf_core_dump+1879>:	movq   $0xffffffffffffffff,0xffffffffffffe048(%rax)
0xffffffff802b2240 <elf_core_dump+1890>:	mov    %rdx,0xa8(%rsp)
0xffffffff802b2248 <elf_core_dump+1898>:	jbe    0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b224e <elf_core_dump+1904>:	mov    $0x40,%edx
0xffffffff802b2253 <elf_core_dump+1909>:	mov    %rbp,%rsi
0xffffffff802b2256 <elf_core_dump+1912>:	mov    0x68(%rsp),%rdi
0xffffffff802b225b <elf_core_dump+1917>:	callq  0xffffffff802b178a <dump_write>
0xffffffff802b2260 <elf_core_dump+1922>:	test   %eax,%eax
0xffffffff802b2262 <elf_core_dump+1924>:	je     0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b2268 <elf_core_dump+1930>:	movslq 0x50(%rsp),%r14
0xffffffff802b226d <elf_core_dump+1935>:	mov    %r15,0x90(%rsp)
0xffffffff802b2275 <elf_core_dump+1943>:	imul   $0x38,%r14,%r14
0xffffffff802b2279 <elf_core_dump+1947>:	mov    %r15,%rsi
0xffffffff802b227c <elf_core_dump+1950>:	add    $0x40,%r14
0xffffffff802b2280 <elf_core_dump+1954>:	xor    %ecx,%ecx
0xffffffff802b2282 <elf_core_dump+1956>:	mov    %r14,0x118(%rsp)
0xffffffff802b228a <elf_core_dump+1964>:	xor    %edx,%edx
0xffffffff802b228c <elf_core_dump+1966>:	mov    %rsi,%rdi
0xffffffff802b228f <elf_core_dump+1969>:	mov    %edx,0x40(%rsp)
0xffffffff802b2293 <elf_core_dump+1973>:	mov    %ecx,0x38(%rsp)
0xffffffff802b2297 <elf_core_dump+1977>:	mov    %rsi,0x48(%rsp)
0xffffffff802b229c <elf_core_dump+1982>:	callq  0xffffffff802b1914 <notesize>
0xffffffff802b22a1 <elf_core_dump+1987>:	mov    0x38(%rsp),%ecx
0xffffffff802b22a5 <elf_core_dump+1991>:	mov    0x40(%rsp),%edx
0xffffffff802b22a9 <elf_core_dump+1995>:	add    %eax,%ecx
0xffffffff802b22ab <elf_core_dump+1997>:	inc    %edx
0xffffffff802b22ad <elf_core_dump+1999>:	mov    0x48(%rsp),%rsi
0xffffffff802b22b2 <elf_core_dump+2004>:	add    $0x18,%rsi
0xffffffff802b22b6 <elf_core_dump+2008>:	cmp    0x8c(%rsp),%edx
0xffffffff802b22bd <elf_core_dump+2015>:	jl     0xffffffff802b228c <elf_core_dump+1966>
0xffffffff802b22bf <elf_core_dump+2017>:	add    0x60(%rsp),%ecx
0xffffffff802b22c3 <elf_core_dump+2021>:	movl   $0x4,0xb0(%rsp)
0xffffffff802b22ce <elf_core_dump+2032>:	movslq %ecx,%rcx
0xffffffff802b22d1 <elf_core_dump+2035>:	mov    %r14,0xb8(%rsp)
0xffffffff802b22d9 <elf_core_dump+2043>:	movq   $0x0,0xc0(%rsp)
0xffffffff802b22e5 <elf_core_dump+2055>:	movq   $0x0,0xc8(%rsp)
0xffffffff802b22f1 <elf_core_dump+2067>:	mov    %rcx,0xd0(%rsp)
0xffffffff802b22f9 <elf_core_dump+2075>:	movq   $0x0,0xd8(%rsp)
0xffffffff802b2305 <elf_core_dump+2087>:	movl   $0x0,0xb4(%rsp)
0xffffffff802b2310 <elf_core_dump+2098>:	movq   $0x0,0xe0(%rsp)
0xffffffff802b231c <elf_core_dump+2110>:	cmpq   $0x77,0x80(%rsp)
0xffffffff802b2325 <elf_core_dump+2119>:	jbe    0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b232b <elf_core_dump+2125>:	lea    0xb0(%rsp),%r8
0xffffffff802b2333 <elf_core_dump+2133>:	mov    %rcx,0x38(%rsp)
0xffffffff802b2338 <elf_core_dump+2138>:	mov    $0x38,%edx
0xffffffff802b233d <elf_core_dump+2143>:	mov    %r8,%rsi
0xffffffff802b2340 <elf_core_dump+2146>:	mov    0x68(%rsp),%rdi
0xffffffff802b2345 <elf_core_dump+2151>:	mov    %r8,0x48(%rsp)
0xffffffff802b234a <elf_core_dump+2156>:	callq  0xffffffff802b178a <dump_write>
0xffffffff802b234f <elf_core_dump+2161>:	mov    0x38(%rsp),%rcx
0xffffffff802b2354 <elf_core_dump+2166>:	test   %eax,%eax
0xffffffff802b2356 <elf_core_dump+2168>:	je     0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b235c <elf_core_dump+2174>:	lea    0xfff(%r14,%rcx,1),%rax
0xffffffff802b2364 <elf_core_dump+2182>:	movq   $0x78,0x60(%rsp)
0xffffffff802b236d <elf_core_dump+2191>:	mov    $0x1000,%ecx
0xffffffff802b2372 <elf_core_dump+2196>:	cqto   
0xffffffff802b2374 <elf_core_dump+2198>:	idiv   %rcx
0xffffffff802b2377 <elf_core_dump+2201>:	shl    $0xc,%rax
0xffffffff802b237b <elf_core_dump+2205>:	mov    %rax,0x50(%rsp)
0xffffffff802b2380 <elf_core_dump+2210>:	mov    %gs:0x0,%rax
0xffffffff802b2389 <elf_core_dump+2219>:	mov    0x1a8(%rax),%rax
0xffffffff802b2390 <elf_core_dump+2226>:	mov    (%rax),%r14
0xffffffff802b2393 <elf_core_dump+2229>:	mov    0x340(%rax),%rcx
0xffffffff802b239a <elf_core_dump+2236>:	test   %r14,%r14
0xffffffff802b239d <elf_core_dump+2239>:	mov    0x50(%rsp),%rax
0xffffffff802b23a2 <elf_core_dump+2244>:	mov    %rcx,0x98(%rsp)
0xffffffff802b23aa <elf_core_dump+2252>:	cmove  0x58(%rsp),%r14
0xffffffff802b23b0 <elf_core_dump+2258>:	mov    %rax,0x78(%rsp)
0xffffffff802b23b5 <elf_core_dump+2263>:	jmpq   0xffffffff802b24bf <elf_core_dump+2529>
0xffffffff802b23ba <elf_core_dump+2268>:	mov    0x10(%r14),%rdx
0xffffffff802b23be <elf_core_dump+2272>:	mov    0x78(%rsp),%rcx
0xffffffff802b23c3 <elf_core_dump+2277>:	sub    0x8(%r14),%rdx
0xffffffff802b23c7 <elf_core_dump+2281>:	mov    0x98(%rsp),%rsi
0xffffffff802b23cf <elf_core_dump+2289>:	mov    %rcx,0xb8(%rsp)
0xffffffff802b23d7 <elf_core_dump+2297>:	movl   $0x1,0xb0(%rsp)
0xffffffff802b23e2 <elf_core_dump+2308>:	mov    %r14,%rdi
0xffffffff802b23e5 <elf_core_dump+2311>:	mov    0x8(%r14),%rax
0xffffffff802b23e9 <elf_core_dump+2315>:	mov    %rdx,0x40(%rsp)
0xffffffff802b23ee <elf_core_dump+2320>:	mov    %rax,0xc0(%rsp)
0xffffffff802b23f6 <elf_core_dump+2328>:	movq   $0x0,0xc8(%rsp)
0xffffffff802b2402 <elf_core_dump+2340>:	callq  0xffffffff802b171c <maydump>
0xffffffff802b2407 <elf_core_dump+2345>:	mov    0x40(%rsp),%rdx
0xffffffff802b240c <elf_core_dump+2350>:	xor    %ecx,%ecx
0xffffffff802b240e <elf_core_dump+2352>:	mov    %rdx,0xd8(%rsp)
0xffffffff802b2416 <elf_core_dump+2360>:	test   %eax,%eax
0xffffffff802b2418 <elf_core_dump+2362>:	cmovne %rdx,%rcx
0xffffffff802b241c <elf_core_dump+2366>:	mov    %rcx,0xd0(%rsp)
0xffffffff802b2424 <elf_core_dump+2374>:	mov    0x28(%r14),%rdx
0xffffffff802b2428 <elf_core_dump+2378>:	mov    %edx,%eax
0xffffffff802b242a <elf_core_dump+2380>:	and    $0x1,%eax
0xffffffff802b242d <elf_core_dump+2383>:	neg    %eax
0xffffffff802b242f <elf_core_dump+2385>:	and    $0x4,%eax
0xffffffff802b2432 <elf_core_dump+2388>:	test   $0x2,%dl
0xffffffff802b2435 <elf_core_dump+2391>:	mov    %eax,0xb4(%rsp)
0xffffffff802b243c <elf_core_dump+2398>:	je     0xffffffff802b2448 <elf_core_dump+2410>
0xffffffff802b243e <elf_core_dump+2400>:	or     $0x2,%eax
0xffffffff802b2441 <elf_core_dump+2403>:	mov    %eax,0xb4(%rsp)
0xffffffff802b2448 <elf_core_dump+2410>:	and    $0x4,%dl
0xffffffff802b244b <elf_core_dump+2413>:	je     0xffffffff802b2455 <elf_core_dump+2423>
0xffffffff802b244d <elf_core_dump+2415>:	orl    $0x1,0xb4(%rsp)
0xffffffff802b2455 <elf_core_dump+2423>:	addq   $0x38,0x60(%rsp)
0xffffffff802b245b <elf_core_dump+2429>:	mov    0x80(%rsp),%rax
0xffffffff802b2463 <elf_core_dump+2437>:	movq   $0x1000,0xe0(%rsp)
0xffffffff802b246f <elf_core_dump+2449>:	cmp    %rax,0x60(%rsp)
0xffffffff802b2474 <elf_core_dump+2454>:	ja     0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b247a <elf_core_dump+2460>:	mov    %rcx,0x38(%rsp)
0xffffffff802b247f <elf_core_dump+2465>:	mov    $0x38,%edx
0xffffffff802b2484 <elf_core_dump+2470>:	lea    0xb0(%rsp),%rsi
0xffffffff802b248c <elf_core_dump+2478>:	mov    0x68(%rsp),%rdi
0xffffffff802b2491 <elf_core_dump+2483>:	callq  0xffffffff802b178a <dump_write>
0xffffffff802b2496 <elf_core_dump+2488>:	mov    0x38(%rsp),%rcx
0xffffffff802b249b <elf_core_dump+2493>:	test   %eax,%eax
0xffffffff802b249d <elf_core_dump+2495>:	je     0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b24a3 <elf_core_dump+2501>:	mov    0x18(%r14),%rax
0xffffffff802b24a7 <elf_core_dump+2505>:	test   %rax,%rax
0xffffffff802b24aa <elf_core_dump+2508>:	jne    0xffffffff802b24b7 <elf_core_dump+2521>
0xffffffff802b24ac <elf_core_dump+2510>:	cmp    0x58(%rsp),%r14
0xffffffff802b24b1 <elf_core_dump+2515>:	cmovne 0x58(%rsp),%rax
0xffffffff802b24b7 <elf_core_dump+2521>:	add    %rcx,0x78(%rsp)
0xffffffff802b24bc <elf_core_dump+2526>:	mov    %rax,%r14
0xffffffff802b24bf <elf_core_dump+2529>:	test   %r14,%r14
0xffffffff802b24c2 <elf_core_dump+2532>:	jne    0xffffffff802b23ba <elf_core_dump+2268>
0xffffffff802b24c8 <elf_core_dump+2538>:	lea    0x118(%rsp),%rdx
0xffffffff802b24d0 <elf_core_dump+2546>:	mov    0x68(%rsp),%rsi
0xffffffff802b24d5 <elf_core_dump+2551>:	mov    0x90(%rsp),%rdi
0xffffffff802b24dd <elf_core_dump+2559>:	callq  0xffffffff802b1940 <writenote>
0xffffffff802b24e2 <elf_core_dump+2564>:	test   %eax,%eax
0xffffffff802b24e4 <elf_core_dump+2566>:	je     0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b24ea <elf_core_dump+2572>:	inc    %r14d
0xffffffff802b24ed <elf_core_dump+2575>:	addq   $0x18,0x90(%rsp)
0xffffffff802b24f6 <elf_core_dump+2584>:	cmp    0x8c(%rsp),%r14d
0xffffffff802b24fe <elf_core_dump+2592>:	jl     0xffffffff802b24c8 <elf_core_dump+2538>
0xffffffff802b2500 <elf_core_dump+2594>:	lea    0xf0(%rsp),%rdx
0xffffffff802b2508 <elf_core_dump+2602>:	mov    0xf0(%rsp),%r14
0xffffffff802b2510 <elf_core_dump+2610>:	mov    %rdx,0x20(%rsp)
0xffffffff802b2515 <elf_core_dump+2615>:	jmp    0xffffffff802b255a <elf_core_dump+2684>
0xffffffff802b2517 <elf_core_dump+2617>:	xor    %ecx,%ecx
0xffffffff802b2519 <elf_core_dump+2619>:	jmp    0xffffffff802b254e <elf_core_dump+2672>
0xffffffff802b251b <elf_core_dump+2621>:	movslq %ecx,%rax
0xffffffff802b251e <elf_core_dump+2624>:	mov    %ecx,0x38(%rsp)
0xffffffff802b2522 <elf_core_dump+2628>:	imul   $0x18,%rax,%rax
0xffffffff802b2526 <elf_core_dump+2632>:	lea    0x118(%rsp),%rdx
0xffffffff802b252e <elf_core_dump+2640>:	lea    0x368(%r14,%rax,1),%rdi
0xffffffff802b2536 <elf_core_dump+2648>:	mov    0x68(%rsp),%rsi
0xffffffff802b253b <elf_core_dump+2653>:	callq  0xffffffff802b1940 <writenote>
0xffffffff802b2540 <elf_core_dump+2658>:	mov    0x38(%rsp),%ecx
0xffffffff802b2544 <elf_core_dump+2662>:	test   %eax,%eax
0xffffffff802b2546 <elf_core_dump+2664>:	je     0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b254c <elf_core_dump+2670>:	inc    %ecx
0xffffffff802b254e <elf_core_dump+2672>:	cmp    0x3b0(%r14),%ecx
0xffffffff802b2555 <elf_core_dump+2679>:	jl     0xffffffff802b251b <elf_core_dump+2621>
0xffffffff802b2557 <elf_core_dump+2681>:	mov    (%r14),%r14
0xffffffff802b255a <elf_core_dump+2684>:	mov    (%r14),%rax
0xffffffff802b255d <elf_core_dump+2687>:	prefetcht0 (%rax)
0xffffffff802b2560 <elf_core_dump+2690>:	cmp    0x20(%rsp),%r14
0xffffffff802b2565 <elf_core_dump+2695>:	jne    0xffffffff802b2517 <elf_core_dump+2617>
0xffffffff802b2567 <elf_core_dump+2697>:	mov    0x50(%rsp),%rsi
0xffffffff802b256c <elf_core_dump+2702>:	mov    0x68(%rsp),%rdi
0xffffffff802b2571 <elf_core_dump+2707>:	sub    0x118(%rsp),%rsi
0xffffffff802b2579 <elf_core_dump+2715>:	callq  0xffffffff802b1a4b <dump_seek>
0xffffffff802b257e <elf_core_dump+2720>:	test   %eax,%eax
0xffffffff802b2580 <elf_core_dump+2722>:	je     0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b2586 <elf_core_dump+2728>:	cmpl   $0x0,0xa4(%rsp)
0xffffffff802b258e <elf_core_dump+2736>:	je     0xffffffff802b2688 <elf_core_dump+2986>
0xffffffff802b2594 <elf_core_dump+2742>:	mov    %gs:0x0,%rax
0xffffffff802b259d <elf_core_dump+2751>:	mov    0x20(%r13),%rsi
0xffffffff802b25a1 <elf_core_dump+2755>:	mov    0x1a8(%rax),%rdi
0xffffffff802b25a8 <elf_core_dump+2762>:	mov    $0x6400000,%r14d
0xffffffff802b25ae <elf_core_dump+2768>:	callq  0xffffffff8026bc79 <find_vma>
0xffffffff802b25b3 <elf_core_dump+2773>:	mov    $0xd0,%esi
0xffffffff802b25b8 <elf_core_dump+2778>:	mov    0x10(%rax),%rax
0xffffffff802b25bc <elf_core_dump+2782>:	sub    0x20(%r13),%rax
0xffffffff802b25c0 <elf_core_dump+2786>:	cmp    $0x6400000,%rax
0xffffffff802b25c6 <elf_core_dump+2792>:	cmovbe %rax,%r14
0xffffffff802b25ca <elf_core_dump+2796>:	mov    %r14,%rdi
0xffffffff802b25cd <elf_core_dump+2799>:	callq  0xffffffff8027cd43 <__kmalloc>
0xffffffff802b25d2 <elf_core_dump+2804>:	test   %rax,%rax
0xffffffff802b25d5 <elf_core_dump+2807>:	je     0xffffffff802b2688 <elf_core_dump+2986>
0xffffffff802b25db <elf_core_dump+2813>:	mov    0x98(%r13),%rsi
0xffffffff802b25e2 <elf_core_dump+2820>:	mov    %r14d,%edx
0xffffffff802b25e5 <elf_core_dump+2823>:	mov    %rax,%rdi
0xffffffff802b25e8 <elf_core_dump+2826>:	mov    %rax,0x38(%rsp)
0xffffffff802b25ed <elf_core_dump+2831>:	callq  0xffffffff803468d0 <__copy_from_user_inatomic>
0xffffffff802b25f2 <elf_core_dump+2836>:	mov    0x38(%rsp),%rcx
0xffffffff802b25f7 <elf_core_dump+2841>:	test   %rax,%rax
0xffffffff802b25fa <elf_core_dump+2844>:	jne    0xffffffff802b2688 <elf_core_dump+2986>
0xffffffff802b2600 <elf_core_dump+2850>:	lea    (%rcx,%r14,8),%r14
0xffffffff802b2604 <elf_core_dump+2854>:	mov    %r14,0x50(%rsp)
0xffffffff802b2609 <elf_core_dump+2859>:	mov    %rcx,%r14
0xffffffff802b260c <elf_core_dump+2862>:	jmp    0xffffffff802b2646 <elf_core_dump+2920>
0xffffffff802b260e <elf_core_dump+2864>:	mov    (%r14),%rsi
0xffffffff802b2611 <elf_core_dump+2867>:	test   %rsi,%rsi
0xffffffff802b2614 <elf_core_dump+2870>:	je     0xffffffff802b2642 <elf_core_dump+2916>
0xffffffff802b2616 <elf_core_dump+2872>:	mov    %gs:0x0,%rax
0xffffffff802b261f <elf_core_dump+2881>:	mov    0x1a8(%rax),%rdi
0xffffffff802b2626 <elf_core_dump+2888>:	mov    %rcx,0x38(%rsp)
0xffffffff802b262b <elf_core_dump+2893>:	callq  0xffffffff8026bc79 <find_vma>
0xffffffff802b2630 <elf_core_dump+2898>:	mov    0x38(%rsp),%rcx
0xffffffff802b2635 <elf_core_dump+2903>:	test   %rax,%rax
0xffffffff802b2638 <elf_core_dump+2906>:	je     0xffffffff802b2642 <elf_core_dump+2916>
0xffffffff802b263a <elf_core_dump+2908>:	orq    $0x8000000,0x28(%rax)
0xffffffff802b2642 <elf_core_dump+2916>:	add    $0x8,%r14
0xffffffff802b2646 <elf_core_dump+2920>:	cmp    0x50(%rsp),%r14
0xffffffff802b264b <elf_core_dump+2925>:	jb     0xffffffff802b260e <elf_core_dump+2864>
0xffffffff802b264d <elf_core_dump+2927>:	mov    %rcx,%rdi
0xffffffff802b2650 <elf_core_dump+2930>:	xor    %r14d,%r14d
0xffffffff802b2653 <elf_core_dump+2933>:	callq  0xffffffff8027d678 <kfree>
0xffffffff802b2658 <elf_core_dump+2938>:	mov    %gs:0x0,%rax
0xffffffff802b2661 <elf_core_dump+2947>:	mov    0x0(%r13,%r14,8),%rsi
0xffffffff802b2666 <elf_core_dump+2952>:	mov    0x1a8(%rax),%rdi
0xffffffff802b266d <elf_core_dump+2959>:	callq  0xffffffff8026bc79 <find_vma>
0xffffffff802b2672 <elf_core_dump+2964>:	test   %rax,%rax
0xffffffff802b2675 <elf_core_dump+2967>:	je     0xffffffff802b267f <elf_core_dump+2977>
0xffffffff802b2677 <elf_core_dump+2969>:	orq    $0x8000000,0x28(%rax)
0xffffffff802b267f <elf_core_dump+2977>:	inc    %r14
0xffffffff802b2682 <elf_core_dump+2980>:	cmp    $0x15,%r14
0xffffffff802b2686 <elf_core_dump+2984>:	jne    0xffffffff802b2658 <elf_core_dump+2938>
0xffffffff802b2688 <elf_core_dump+2986>:	mov    %gs:0x0,%rax
0xffffffff802b2691 <elf_core_dump+2995>:	mov    0x1a8(%rax),%rax
0xffffffff802b2698 <elf_core_dump+3002>:	mov    (%rax),%r13
0xffffffff802b269b <elf_core_dump+3005>:	test   %r13,%r13
0xffffffff802b269e <elf_core_dump+3008>:	jne    0xffffffff802b26aa <elf_core_dump+3020>
0xffffffff802b26a0 <elf_core_dump+3010>:	mov    0x58(%rsp),%r13
0xffffffff802b26a5 <elf_core_dump+3015>:	jmpq   0xffffffff802b2836 <elf_core_dump+3416>
0xffffffff802b26aa <elf_core_dump+3020>:	mov    0x98(%rsp),%rsi
0xffffffff802b26b2 <elf_core_dump+3028>:	mov    %r13,%rdi
0xffffffff802b26b5 <elf_core_dump+3031>:	callq  0xffffffff802b171c <maydump>
0xffffffff802b26ba <elf_core_dump+3036>:	test   %eax,%eax
0xffffffff802b26bc <elf_core_dump+3038>:	je     0xffffffff802b281f <elf_core_dump+3393>
0xffffffff802b26c2 <elf_core_dump+3044>:	cmpl   $0x0,0xa4(%rsp)
0xffffffff802b26ca <elf_core_dump+3052>:	je     0xffffffff802b26f2 <elf_core_dump+3092>
0xffffffff802b26cc <elf_core_dump+3054>:	testb  $0x8,0x2b(%r13)
0xffffffff802b26d1 <elf_core_dump+3059>:	jne    0xffffffff802b26f2 <elf_core_dump+3092>
0xffffffff802b26d3 <elf_core_dump+3061>:	mov    0x10(%r13),%rsi
0xffffffff802b26d7 <elf_core_dump+3065>:	mov    0x68(%rsp),%rdi
0xffffffff802b26dc <elf_core_dump+3070>:	sub    0x8(%r13),%rsi
0xffffffff802b26e0 <elf_core_dump+3074>:	callq  0xffffffff802b1a4b <dump_seek>
0xffffffff802b26e5 <elf_core_dump+3079>:	test   %eax,%eax
0xffffffff802b26e7 <elf_core_dump+3081>:	je     0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b26ed <elf_core_dump+3087>:	jmpq   0xffffffff802b281f <elf_core_dump+3393>
0xffffffff802b26f2 <elf_core_dump+3092>:	mov    0x8(%r13),%r14
0xffffffff802b26f6 <elf_core_dump+3096>:	jmpq   0xffffffff802b2815 <elf_core_dump+3383>
0xffffffff802b26fb <elf_core_dump+3101>:	xor    %eax,%eax
0xffffffff802b26fd <elf_core_dump+3103>:	callq  0xffffffff802b19ef <sigabrt_is_pending>
0xffffffff802b2702 <elf_core_dump+3108>:	test   %eax,%eax
0xffffffff802b2704 <elf_core_dump+3110>:	jne    0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b270a <elf_core_dump+3116>:	mov    %gs:0x0,%rdi
0xffffffff802b2713 <elf_core_dump+3125>:	lea    0x108(%rsp),%rcx
0xffffffff802b271b <elf_core_dump+3133>:	mov    0x1a8(%rdi),%rsi
0xffffffff802b2722 <elf_core_dump+3140>:	lea    0x110(%rsp),%rax
0xffffffff802b272a <elf_core_dump+3148>:	mov    %rcx,0x8(%rsp)
0xffffffff802b272f <elf_core_dump+3153>:	xor    %r8d,%r8d
0xffffffff802b2732 <elf_core_dump+3156>:	mov    %rax,(%rsp)
0xffffffff802b2736 <elf_core_dump+3160>:	mov    $0x1,%r9d
0xffffffff802b273c <elf_core_dump+3166>:	mov    $0x1,%ecx
0xffffffff802b2741 <elf_core_dump+3171>:	mov    %r14,%rdx
0xffffffff802b2744 <elf_core_dump+3174>:	callq  0xffffffff80269921 <get_user_pages>
0xffffffff802b2749 <elf_core_dump+3179>:	test   %eax,%eax
0xffffffff802b274b <elf_core_dump+3181>:	jg     0xffffffff802b2769 <elf_core_dump+3211>
0xffffffff802b274d <elf_core_dump+3183>:	mov    $0x1000,%esi
0xffffffff802b2752 <elf_core_dump+3188>:	mov    0x68(%rsp),%rdi
0xffffffff802b2757 <elf_core_dump+3193>:	callq  0xffffffff802b1a4b <dump_seek>
0xffffffff802b275c <elf_core_dump+3198>:	test   %eax,%eax
0xffffffff802b275e <elf_core_dump+3200>:	jne    0xffffffff802b280e <elf_core_dump+3376>
0xffffffff802b2764 <elf_core_dump+3206>:	jmpq   0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b2769 <elf_core_dump+3211>:	mov    0x110(%rsp),%rdx
0xffffffff802b2771 <elf_core_dump+3219>:	mov    $0xffffffff808d8000,%rdi
0xffffffff802b2778 <elf_core_dump+3226>:	mov    %rdx,0x50(%rsp)
0xffffffff802b277d <elf_core_dump+3231>:	callq  0xffffffff80220270 <__phys_addr>
0xffffffff802b2782 <elf_core_dump+3236>:	shr    $0xc,%rax
0xffffffff802b2786 <elf_core_dump+3240>:	mov    %rax,%rdi
0xffffffff802b2789 <elf_core_dump+3243>:	callq  0xffffffff8025e001 <pfn_to_page>
0xffffffff802b278e <elf_core_dump+3248>:	cmp    %rax,0x50(%rsp)
0xffffffff802b2793 <elf_core_dump+3253>:	jne    0xffffffff802b27a6 <elf_core_dump+3272>
0xffffffff802b2795 <elf_core_dump+3255>:	mov    $0x1000,%esi
0xffffffff802b279a <elf_core_dump+3260>:	mov    0x68(%rsp),%rdi
0xffffffff802b279f <elf_core_dump+3265>:	callq  0xffffffff802b1a4b <dump_seek>
0xffffffff802b27a4 <elf_core_dump+3270>:	jmp    0xffffffff802b27ee <elf_core_dump+3344>
0xffffffff802b27a6 <elf_core_dump+3272>:	mov    0x110(%rsp),%rdi
0xffffffff802b27ae <elf_core_dump+3280>:	callq  0xffffffff8025e03a <page_to_pfn>
0xffffffff802b27b3 <elf_core_dump+3285>:	addq   $0x1000,0x60(%rsp)
0xffffffff802b27bc <elf_core_dump+3294>:	mov    0x80(%rsp),%rcx
0xffffffff802b27c4 <elf_core_dump+3302>:	cmp    %rcx,0x60(%rsp)
0xffffffff802b27c9 <elf_core_dump+3307>:	ja     0xffffffff802b27f2 <elf_core_dump+3348>
0xffffffff802b27cb <elf_core_dump+3309>:	mov    %rax,%rsi
0xffffffff802b27ce <elf_core_dump+3312>:	mov    $0x1000,%edx
0xffffffff802b27d3 <elf_core_dump+3317>:	shl    $0xc,%rsi
0xffffffff802b27d7 <elf_core_dump+3321>:	mov    $0xffff810000000000,%rax
0xffffffff802b27e1 <elf_core_dump+3331>:	mov    0x68(%rsp),%rdi
0xffffffff802b27e6 <elf_core_dump+3336>:	add    %rax,%rsi
0xffffffff802b27e9 <elf_core_dump+3339>:	callq  0xffffffff802b178a <dump_write>
0xffffffff802b27ee <elf_core_dump+3344>:	test   %eax,%eax
0xffffffff802b27f0 <elf_core_dump+3346>:	jne    0xffffffff802b2801 <elf_core_dump+3363>
0xffffffff802b27f2 <elf_core_dump+3348>:	mov    0x110(%rsp),%rdi
0xffffffff802b27fa <elf_core_dump+3356>:	callq  0xffffffff80261def <put_page>
0xffffffff802b27ff <elf_core_dump+3361>:	jmp    0xffffffff802b2865 <elf_core_dump+3463>
0xffffffff802b2801 <elf_core_dump+3363>:	mov    0x110(%rsp),%rdi
0xffffffff802b2809 <elf_core_dump+3371>:	callq  0xffffffff80261def <put_page>
0xffffffff802b280e <elf_core_dump+3376>:	add    $0x1000,%r14
0xffffffff802b2815 <elf_core_dump+3383>:	cmp    0x10(%r13),%r14
0xffffffff802b2819 <elf_core_dump+3387>:	jb     0xffffffff802b26fb <elf_core_dump+3101>
0xffffffff802b281f <elf_core_dump+3393>:	mov    0x18(%r13),%rax
0xffffffff802b2823 <elf_core_dump+3397>:	test   %rax,%rax
0xffffffff802b2826 <elf_core_dump+3400>:	jne    0xffffffff802b2833 <elf_core_dump+3413>
0xffffffff802b2828 <elf_core_dump+3402>:	cmp    0x58(%rsp),%r13
0xffffffff802b282d <elf_core_dump+3407>:	cmovne 0x58(%rsp),%rax
0xffffffff802b2833 <elf_core_dump+3413>:	mov    %rax,%r13
0xffffffff802b2836 <elf_core_dump+3416>:	test   %r13,%r13
0xffffffff802b2839 <elf_core_dump+3419>:	jne    0xffffffff802b26aa <elf_core_dump+3020>
0xffffffff802b283f <elf_core_dump+3425>:	mov    $0x1,%r14d
0xffffffff802b2845 <elf_core_dump+3431>:	mov    $0x1,%r13b
0xffffffff802b2848 <elf_core_dump+3434>:	jmp    0xffffffff802b286e <elf_core_dump+3472>
0xffffffff802b284a <elf_core_dump+3436>:	xor    %r14d,%r14d
0xffffffff802b284d <elf_core_dump+3439>:	movq   $0x0,0x70(%rsp)
0xffffffff802b2856 <elf_core_dump+3448>:	xor    %r12d,%r12d
0xffffffff802b2859 <elf_core_dump+3451>:	xor    %ebx,%ebx
0xffffffff802b285b <elf_core_dump+3453>:	xor    %r15d,%r15d
0xffffffff802b285e <elf_core_dump+3456>:	xor    %ebp,%ebp
0xffffffff802b2860 <elf_core_dump+3458>:	xor    %r13d,%r13d
0xffffffff802b2863 <elf_core_dump+3461>:	jmp    0xffffffff802b286e <elf_core_dump+3472>
0xffffffff802b2865 <elf_core_dump+3463>:	xor    %r14d,%r14d
0xffffffff802b2868 <elf_core_dump+3466>:	mov    $0x1,%r13d
0xffffffff802b286e <elf_core_dump+3472>:	mov    %gs:0x10,%rax
0xffffffff802b2877 <elf_core_dump+3481>:	mov    0xa8(%rsp),%rdx
0xffffffff802b287f <elf_core_dump+3489>:	mov    %rdx,0xffffffffffffe048(%rax)
0xffffffff802b2886 <elf_core_dump+3496>:	jmp    0xffffffff802b28f7 <elf_core_dump+3609>
0xffffffff802b2888 <elf_core_dump+3498>:	xor    %r14d,%r14d
0xffffffff802b288b <elf_core_dump+3501>:	movq   $0x0,0x70(%rsp)
0xffffffff802b2894 <elf_core_dump+3510>:	xor    %r12d,%r12d
0xffffffff802b2897 <elf_core_dump+3513>:	xor    %ebx,%ebx
0xffffffff802b2899 <elf_core_dump+3515>:	jmp    0xffffffff802b28b8 <elf_core_dump+3546>
0xffffffff802b289b <elf_core_dump+3517>:	xor    %r14d,%r14d
0xffffffff802b289e <elf_core_dump+3520>:	movq   $0x0,0x70(%rsp)
0xffffffff802b28a7 <elf_core_dump+3529>:	xor    %r12d,%r12d
0xffffffff802b28aa <elf_core_dump+3532>:	jmp    0xffffffff802b28b8 <elf_core_dump+3546>
0xffffffff802b28ac <elf_core_dump+3534>:	xor    %r14d,%r14d
0xffffffff802b28af <elf_core_dump+3537>:	movq   $0x0,0x70(%rsp)
0xffffffff802b28b8 <elf_core_dump+3546>:	xor    %r15d,%r15d
0xffffffff802b28bb <elf_core_dump+3549>:	jmp    0xffffffff802b28ce <elf_core_dump+3568>
0xffffffff802b28bd <elf_core_dump+3551>:	xor    %r14d,%r14d
0xffffffff802b28c0 <elf_core_dump+3554>:	movq   $0x0,0x70(%rsp)
0xffffffff802b28c9 <elf_core_dump+3563>:	jmp    0xffffffff802b28ce <elf_core_dump+3568>
0xffffffff802b28cb <elf_core_dump+3565>:	xor    %r14d,%r14d
0xffffffff802b28ce <elf_core_dump+3568>:	xor    %r13d,%r13d
0xffffffff802b28d1 <elf_core_dump+3571>:	jmp    0xffffffff802b28f7 <elf_core_dump+3609>
0xffffffff802b28d3 <elf_core_dump+3573>:	mov    (%rdi),%rdx
0xffffffff802b28d6 <elf_core_dump+3576>:	mov    0x8(%rdi),%rax
0xffffffff802b28da <elf_core_dump+3580>:	mov    %rax,0x8(%rdx)
0xffffffff802b28de <elf_core_dump+3584>:	mov    %rdx,(%rax)
0xffffffff802b28e1 <elf_core_dump+3587>:	movq   $0x100100,(%rdi)
0xffffffff802b28e8 <elf_core_dump+3594>:	movq   $0x200200,0x8(%rdi)
0xffffffff802b28f0 <elf_core_dump+3602>:	callq  0xffffffff8027d678 <kfree>
0xffffffff802b28f5 <elf_core_dump+3607>:	jmp    0xffffffff802b2904 <elf_core_dump+3622>
0xffffffff802b28f7 <elf_core_dump+3609>:	lea    0xf0(%rsp),%rcx
0xffffffff802b28ff <elf_core_dump+3617>:	mov    %rcx,0x18(%rsp)
0xffffffff802b2904 <elf_core_dump+3622>:	mov    0xf0(%rsp),%rdi
0xffffffff802b290c <elf_core_dump+3630>:	cmp    0x18(%rsp),%rdi
0xffffffff802b2911 <elf_core_dump+3635>:	jne    0xffffffff802b28d3 <elf_core_dump+3573>
0xffffffff802b2913 <elf_core_dump+3637>:	mov    %rbp,%rdi
0xffffffff802b2916 <elf_core_dump+3640>:	callq  0xffffffff8027d678 <kfree>
0xffffffff802b291b <elf_core_dump+3645>:	mov    %rbx,%rdi
0xffffffff802b291e <elf_core_dump+3648>:	callq  0xffffffff8027d678 <kfree>
0xffffffff802b2923 <elf_core_dump+3653>:	mov    %r12,%rdi
0xffffffff802b2926 <elf_core_dump+3656>:	callq  0xffffffff8027d678 <kfree>
0xffffffff802b292b <elf_core_dump+3661>:	mov    %r15,%rdi
0xffffffff802b292e <elf_core_dump+3664>:	callq  0xffffffff8027d678 <kfree>
0xffffffff802b2933 <elf_core_dump+3669>:	mov    0x70(%rsp),%rdi
0xffffffff802b2938 <elf_core_dump+3674>:	callq  0xffffffff8027d678 <kfree>
0xffffffff802b293d <elf_core_dump+3679>:	test   %r14d,%r14d
0xffffffff802b2940 <elf_core_dump+3682>:	jne    0xffffffff802b295a <elf_core_dump+3708>
0xffffffff802b2942 <elf_core_dump+3684>:	mov    %gs:0x0,%rax
0xffffffff802b294b <elf_core_dump+3693>:	mov    $0xffffffff80563644,%rdi
0xffffffff802b2952 <elf_core_dump+3700>:	mov    0x1d8(%rax),%esi
0xffffffff802b2958 <elf_core_dump+3706>:	jmp    0xffffffff802b2970 <elf_core_dump+3730>
0xffffffff802b295a <elf_core_dump+3708>:	mov    %gs:0x0,%rax
0xffffffff802b2963 <elf_core_dump+3717>:	mov    $0xffffffff80563670,%rdi
0xffffffff802b296a <elf_core_dump+3724>:	mov    0x1d8(%rax),%esi
0xffffffff802b2970 <elf_core_dump+3730>:	xor    %eax,%eax
0xffffffff802b2972 <elf_core_dump+3732>:	callq  0xffffffff80233178 <printk>
0xffffffff802b2977 <elf_core_dump+3737>:	add    $0x128,%rsp
0xffffffff802b297e <elf_core_dump+3744>:	mov    %r13d,%eax
0xffffffff802b2981 <elf_core_dump+3747>:	pop    %rbx
0xffffffff802b2982 <elf_core_dump+3748>:	pop    %rbp
0xffffffff802b2983 <elf_core_dump+3749>:	pop    %r12
0xffffffff802b2985 <elf_core_dump+3751>:	pop    %r13
0xffffffff802b2987 <elf_core_dump+3753>:	pop    %r14
0xffffffff802b2989 <elf_core_dump+3755>:	pop    %r15
0xffffffff802b298b <elf_core_dump+3757>:	retq   
