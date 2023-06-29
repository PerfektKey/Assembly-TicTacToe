all:main.o funcs.o
	ld -m elf_i386 *.o -o main
	rm *.o

%.o:%.asm
	nasm -f elf $<