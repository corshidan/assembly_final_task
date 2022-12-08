section .data
    input_filename db "input.bin",0
    output_filename db "output.bin",0
    error_message_end_file db "End of file",0xa
    error_message_end_file_len equ $-error_message_end_file
    error_message_write_error db "Error: Write error",0xa
    error_message_write_error_len equ $-error_message_write_error
section .bss
    fd_input resd 1
    fd_output resd 1
    buffer resb 1
    skip_flag resb 1

section .text
    global _start

_start:
    jmp _open_files

_open_files:
    mov byte [skip_flag], 0
    ;open input file
    mov rax, 2
    mov rdi, input_filename
    mov rsi, 0
    syscall
    ;store pointer to input file
    mov [fd_input], rax
    ;open output file
    mov rax, 2
    mov rdi, output_filename
    mov rsi, 1089 ;0102o 
    mov rdx, 0664o
    syscall
    ;store pointer to output file
    mov [fd_output], rax
;read from input file and write to output file
_reading_file_loop:
;read from input file
    mov rax, 0
    mov rdi, [fd_input]
    mov rsi, buffer
    mov rdx, 1
    syscall
    ;check if 1 byte was read
    cmp rax, 1
    jne _not_read_byte

    jmp _check_byte_0x1f

_reading_file_loop_continue:
    cmp byte[skip_flag], 1
    je _reading_file_loop
    ;write to output file
    mov rax, 1
    mov rdi, [fd_output]
    mov rsi, buffer
    mov rdx, 1
    syscall
    ;check if 1 byte was written
    cmp rax, 1
    ;if equal, jump to _reading_file_loop
    je _reading_file_loop
    ;if not equal, print error message and exit
    mov rax, 1
    mov rdi, 2
    mov rsi, error_message_write_error
    mov rdx, error_message_write_error_len
    syscall

    jmp _close_files_and_exit

_close_files_and_exit:
    mov rax, 3
    mov rdi, [fd_input]
    syscall
    mov rdi, [fd_output]
    syscall
    mov rax, 60
    mov rdi, 0
    syscall

_check_byte_0x1f:
    cmp byte [buffer], 0x1f
    je _reading_file_loop
    jmp _check_byte_0x02
_check_byte_0xff:
    cmp byte [buffer], 0xff
    je _action_if_byte_0xff
    jmp _reading_file_loop_continue
_check_byte_0x00:
    cmp byte [buffer], 0x00
    je _action_if_byte_0x00
    jmp _check_byte_0xff
_check_byte_0x02:
    cmp byte [buffer], 0x02
    je _reading_file_loop
    jmp _check_byte_0x00
_action_if_byte_0xff:
    cmp byte [skip_flag], 1
    je _action_byte_0xff_and_skip_flag_1
    jmp _reading_file_loop
_action_if_byte_0x00:
    mov byte [skip_flag], 1
    jmp _reading_file_loop
_action_byte_0xff_and_skip_flag_1:
    mov byte [skip_flag], 0
    jmp _reading_file_loop
_not_read_byte:
    ;if not equal, print error message and exit
    mov rax, 1
    mov rdi, 2
    mov rsi, error_message_end_file
    mov rdx, error_message_end_file_len
    syscall
    ;exit
    jmp _close_files_and_exit