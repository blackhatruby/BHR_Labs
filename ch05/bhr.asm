; ========================================================= #
; This file is a part of { Black Hat Ruby } book lab files. #
; ========================================================= #
;
; Author:
;   Sabri | @KINGSABRI
; Description:
;   Simple assembly file
; Requirements:
; 	apt install nasm
; 	nasm -f elf -o bhr.o bhr.asm
; 	ld -m elf_i386 -s bhr.o -o bhr
;

section .text
	global _start
_start:
	mov eax,4																	; system call ID sys_write
	mov ebx,1																	; file descriptor for standard output
	mov ecx,string														; string address
	mov edx,length														; string length
	int 80h																		; system call
	mov eax,1																	; system call ID: sys_exit
	mov ebx,0																	; exit code 0: no error
	int 80h																		; system call
section .data
string: db 'Welcome to Black Hat Ruby!', 0Ah ; output string
length: equ $ - string											; length of string
