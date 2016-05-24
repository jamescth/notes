#ifndef _MYTEST_H
#define _MYTEST_H

#include <stdint.h>

typedef uint16_t Elf64_Half;
typedef uint32_t Elf64_Word;
typedef	int32_t  Elf64_Sword;
typedef uint64_t Elf64_Xword;
typedef	int64_t  Elf64_Sxword;
typedef uint64_t Elf64_Addr;
typedef uint64_t Elf64_Off;
typedef uint16_t Elf64_Section;
typedef uint64_t Elf64_Size;

typedef struct {
  unsigned char	e_ident[16];	/* Magic number and other info */
  Elf64_Half	e_type;			/* Object file type */
  Elf64_Half	e_machine;		/* Architecture */
  Elf64_Word	e_version;		/* Object file version */
  Elf64_Addr	e_entry;		/* Entry point virtual address */
  Elf64_Off	e_phoff;		/* Program header table file offset */
  Elf64_Off	e_shoff;		/* Section header table file offset */
  Elf64_Word	e_flags;		/* Processor-specific flags */
  Elf64_Half	e_ehsize;		/* ELF header size in bytes */
  Elf64_Half	e_phentsize;		/* Program header table entry size */
  Elf64_Half	e_phnum;		/* Program header table entry count */
  Elf64_Half	e_shentsize;		/* Section header table entry size */
  Elf64_Half	e_shnum;		/* Section header table entry count */
  Elf64_Half	e_shstrndx;		/* Section header string table index */
} Elf64_Ehdr;

typedef struct {
	Elf64_Word	p_type;		/* Entry type. */
	Elf64_Word	p_flags;	/* Access permission flags. */
	Elf64_Off	p_offset;	/* File offset of contents. */
	Elf64_Addr	p_vaddr;	/* Virtual address (not used). */
	Elf64_Addr	p_paddr;	/* Physical address. */
	Elf64_Size	p_filesz;	/* Size of contents in file. */
	Elf64_Size	p_memsz;	/* Size of contents in memory. */
	Elf64_Size	p_align;	/* Alignment in memory and file. */
} Elf64_Phdr;

/* Note header in a PT_NOTE section */
typedef struct elf64_note {
  Elf64_Word n_namesz;	/* Name size */
  Elf64_Word n_descsz;	/* Content size */
  Elf64_Word n_type;	/* Content type */
} Elf64_Nhdr;

typedef unsigned long elf_greg_t;

struct user_regs_struct {
	unsigned long r15,r14,r13,r12,rbp,rbx,r11,r10;
	unsigned long r9,r8,rax,rcx,rdx,rsi,rdi,orig_rax;
	unsigned long rip,cs,eflags;
	unsigned long rsp,ss;
  	unsigned long fs_base, gs_base;
	unsigned long ds,es,fs,gs; 
}; 

#define ELF_NGREG (sizeof (struct user_regs_struct) / sizeof(elf_greg_t))
typedef elf_greg_t elf_gregset_t[ELF_NGREG];

struct elf_siginfo
{
	int	si_signo;			/* signal number */
	int	si_code;			/* extra code */
	int	si_errno;			/* errno */
};

/*
 * Definitions to generate Intel SVR4-like core files.
 * These mostly have the same names as the SVR4 types with "elf_"
 * tacked on the front to prevent clashes with linux definitions,
 * and the typedef forms have been avoided.  This is mostly like
 * the SVR4 structure, but more Linuxy, with things that Linux does
 * not support and which gdb doesn't really use excluded.
 * Fields present but not used are marked with "XXX".
 */
struct elf_prstatus
{
#if 0
	long	pr_flags;	/* XXX Process flags */
	short	pr_why;		/* XXX Reason for process halt */
	short	pr_what;	/* XXX More detailed reason */
#endif
	struct elf_siginfo pr_info;	/* Info associated with signal */
	short	pr_cursig;		/* Current signal */
	unsigned long pr_sigpend;	/* Set of pending signals */
	unsigned long pr_sighold;	/* Set of held signals */
#if 0
	struct sigaltstack pr_altstack;	/* Alternate stack info */
	struct sigaction pr_action;	/* Signal action for current sig */
#endif
	pid_t	pr_pid;
	pid_t	pr_ppid;
	pid_t	pr_pgrp;
	pid_t	pr_sid;
	struct timeval pr_utime;	/* User time */
	struct timeval pr_stime;	/* System time */
	struct timeval pr_cutime;	/* Cumulative user time */
	struct timeval pr_cstime;	/* Cumulative system time */
#if 0
	long	pr_instr;		/* Current instruction */
#endif
	elf_gregset_t pr_reg;	/* GP registers */
#ifdef CONFIG_BINFMT_ELF_FDPIC
	/* When using FDPIC, the loadmap addresses need to be communicated
	 * to GDB in order for GDB to do the necessary relocations.  The
	 * fields (below) used to communicate this information are placed
	 * immediately after ``pr_reg'', so that the loadmap addresses may
	 * be viewed as part of the register set if so desired.
	 */
	unsigned long pr_exec_fdpic_loadmap;
	unsigned long pr_interp_fdpic_loadmap;
#endif
	int pr_fpvalid;		/* True if math co-processor being used.  */
};

#endif /* _MYTEST_H */
