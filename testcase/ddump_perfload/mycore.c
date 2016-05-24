/*
 * This function follows 
 * os/tools/savecore/elf.c/generate_appdump_elf_header() to read core file's
 * elf header & notes.
 */

#include <stdio.h>
#include <stdlib.h>		// exit()
//#include <string.h>		// bzero()
#include <errno.h>
#include <unistd.h>
//#include <ctype.h>		// isspace()

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "mycore.h"

extern int errno;

static void print_elf(Elf64_Ehdr *);
static void print_notes(Elf64_Phdr *);

//#define DEBUG
#ifdef DEBUG
#define my_printf	printf
#else
#define my_printf	
#endif

#define roundup(x, y) ((((x) + ((y) - 1)) / (y)) * (y))

static void
print_elf(Elf64_Ehdr *myelf)
{
	printf("e_ident     %s\n",  myelf->e_ident);

	switch (myelf->e_type) {
	case 0:	printf("e_type      ET_NONE\n");	break;
	case 1:	printf("e_type      ET_REL\n");		break;
	case 2:	printf("e_type      ET_EXEC\n");	break;
	case 3:	printf("e_type      ET_DYN\n");		break;
	case 4:	printf("e_type      ET_CORE\n");	break;
	default:
		printf("e_type      %d\n",  myelf->e_type);
		break;
	}

	switch (myelf->e_machine) {
	case 62: printf("e_machine   EM_X86_64\n");	break;
	default:
		printf("e_machine   %d\n",  myelf->e_machine);
		break;
	}

	printf("e_version   %d\n",  myelf->e_version);
	printf("e_entry     0x%lx\n", myelf->e_entry);
	printf("e_phoff     %ld\n", myelf->e_phoff);
	printf("e_shoff     %ld\n", myelf->e_shoff);
	printf("e_flags     0x%x\n",  myelf->e_flags);
	printf("e_ehsize    %d\n",  myelf->e_ehsize);
	printf("e_phentsize %d\n",  myelf->e_phentsize);
	printf("e_phnum     %d\n",  myelf->e_phnum);
	printf("e_shentsize %d\n",  myelf->e_shentsize);
	printf("e_shnum     %d\n",  myelf->e_shnum);
	printf("e_shstrndx  %d\n",  myelf->e_shstrndx);
}

static void
print_notes_title()
{
	printf("p_type      p_offset             p_vaddr");
	printf(" p_paddr p_filesz          p_memsz    p_flags      P-align\n");
}

static void
print_notes(Elf64_Phdr *myelf)
{
	switch (myelf->p_type) {
	case 0:	printf("PT_NULL   ");	break;
	case 1:	printf("PT_LOAD   ");	break;
	case 2:	printf("PT_DYNAMIC");	break;
	case 3:	printf("PT_INTERP ");	break;
	case 4:	printf("PT_NOTE   ");	break;
	case 5:	printf("PT_SHLIB  ");	break;
	case 6:	printf("PT_PHDR   ");	break;
	case 7:	printf("PT_TLS    ");	break;
	case 8:	printf("PT_NUM    ");	break;
	default:
		printf("p_type   0x%x", myelf->p_type);
		break;
	}

	printf("%10ld  0x%16lx  0x%x  %10d  0x%16lx  0x%x  %10d\n",  
		myelf->p_offset, myelf->p_vaddr, myelf->p_paddr, myelf->p_filesz,
		myelf->p_memsz, myelf->p_flags, myelf->p_align);
	#if 0
	printf("0x%x\n", myelf->p_vaddr);
	printf("0x%x\n", myelf->p_paddr);
	printf("%d\n",   myelf->p_filesz);
	printf("%d\n",   myelf->p_memsz);
	printf("0x%x\n", myelf->p_flags);
	printf("%d\n",   myelf->p_align);
	#endif
}

main(int argc, char *argv[])
{
	char *elf_note;
	char *buf;
	int fd, counter, ret;
	size_t num_bytes, fd_size, notes_size;
	Elf64_Ehdr *myelf_hdr;
	Elf64_Phdr *myelf_phdr, *mapped_seg;
	Elf64_Nhdr *myelf_note;
	struct stat	fdstat;

	if (argc != 2) {
		printf("wrong arg\n");
		exit(1);
	}

	fd = open(argv[1], O_RDONLY);
	if (fd == -1) {
		printf("open() failed\n");
		exit(7);
	}

	ret = fstat(fd, &fdstat);
	if (ret < 0) {
		fprintf(stderr, "%s fstat() failed\n", argv[1]);
		exit(8);
	}
	fd_size = roundup(fdstat.st_size, sysconf(_SC_PAGE_SIZE));

	buf = malloc(fd_size);
	if (buf == NULL) {
		fprintf(stderr, "%s malloc() failed\n", argv[1]);
		exit(8);
	}

	num_bytes = read(fd, buf, fd_size);
	my_printf("fd_size %d, st_size %d, page size %d, num_bytes %d\n",
		fd_size, fdstat.st_size, sysconf(_SC_PAGE_SIZE), num_bytes);

	// read elf64_hdr
	if (num_bytes == -1) {
		printf("read() failed\n");
		free(buf);
		exit(10);
	}

	myelf_hdr = (Elf64_Ehdr *)buf;
	print_elf(myelf_hdr);

	myelf_phdr = (Elf64_Phdr *)(buf + sizeof(Elf64_Ehdr));
	print_notes_title();
	print_notes(myelf_phdr);

	printf("\nprint map\n");
	mapped_seg = (Elf64_Phdr *)(buf + sizeof(Elf64_Ehdr) + sizeof(Elf64_Phdr));
	for ( counter = 0 ; counter < (myelf_hdr->e_phnum - 1) ; counter++) {
		print_notes(mapped_seg);
		mapped_seg++;
		//my_printf("0x%lx\n", myelf_phdr);
	}

	notes_size = myelf_phdr->p_filesz;
	myelf_note = (Elf64_Nhdr *) mapped_seg;
	counter = 0;
	my_printf("%d  %d  %d  %ld\n", counter, myelf_note->n_namesz,
		myelf_note->n_descsz, notes_size);

	printf("\nprint notes\n");
	// notes
	while (notes_size > 0) {
		char * note_name, *note_data;
		size_t l_size = 0;

		note_name = (char *)((unsigned long)myelf_note + sizeof(Elf64_Nhdr));
		note_data = (char *)((unsigned long)myelf_note +
					sizeof(Elf64_Nhdr) + myelf_note->n_namesz);

		l_size = sizeof(Elf64_Nhdr) + roundup(myelf_note->n_namesz, 4) +
				roundup(myelf_note->n_descsz, 4);

		printf("%d  %d %d  %d  %ld %s\n", 
			counter++,  myelf_note->n_type, myelf_note->n_namesz,
			myelf_note->n_descsz, l_size, note_name);

		myelf_note = (Elf64_Nhdr *)((unsigned long)myelf_note + l_size);
		notes_size -= l_size;
	}
#if 0
	// note
	elf_note = malloc(sizeof(struct elf64_note));
	if (elf_note == NULL) {
		printf("elf_note malloc() failed\n");
		exit(20);
	}

	num_bytes = read(fd, elf_note, sizeof(struct elf64_note));
	if (num_bytes == -1) {
		printf("elf_note read() failed\n");
		free(elf_hdr);
		free(elf_phdr);
		exit(10);
	}

	myelf_note = (struct elf64_note *) elf_note;
#endif
	close(fd);
}
