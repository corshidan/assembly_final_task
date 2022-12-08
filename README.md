[WORK IN PROGRESS]

It seems that it does not write into the output file

---

To compile:

`nasm -f elf64 task.asm -o task.o`

To link:

`ld task.o -o task`

Then run:

`./task`

FLOW for checking the bytes, a bit basic but it works.

<img src="./flow.svg">
