default rel
extern get_value
extern put_value
global core

section .bss
        values: resq N

section .data
        sync: times N dq N

section .text
core:
        push r12
        mov r12, rsp
.loop:
        xor eax, eax
        mov al, [rsi]
        test al, al
        jz .end
        cmp al, '+'
        je .add
        cmp al, '*'
        je .mul
        cmp al, '-'
        je .neg
        cmp al, 'n'
        je .n
        cmp al, 'B'
        je .B
        cmp al, 'C'
        je .C
        cmp al, 'D'
        je .D
        cmp al, 'E'
        je .E
        cmp al, 'G'
        je .G
        cmp al, 'P'
        je .P
        cmp al, 'S'
        je .S
        sub al, '0' ;*p is a digit
.endloopandpush:
        push rax
.endloop:
        inc rsi
        jmp .loop
.add:
        pop rax
        pop rdx
        add rax, rdx
        jmp .endloopandpush
.mul:
        pop rax
        pop rdx
        mul rdx
        jmp .endloopandpush
.neg:
        neg qword [rsp]
        jmp .endloop
.n:
        push rdi
        jmp .endloop
.B:
        pop rdx
        mov rax, [rsp]
        test rax, rax
        jz .endloop
        add rsi, rdx
        jmp .endloop
.C:
        pop rax
        jmp .endloop
.D:
        pop rax
        push rax
        jmp .endloopandpush
.E:
        pop rdx
        pop rax
        push rdx
        jmp .endloopandpush
.G:
        push rdi
        push rsi
        push r13
        mov r13, rsp
        and rsp, ~15
        call get_value
        mov rsp, r13
        pop r13
        pop rsi
        pop rdi
        jmp .endloopandpush
.P:
        xchg rsi, [rsp]
        push rdi
        push r13
        mov r13, rsp
        and rsp, ~15
        call put_value
        mov rsp, r13
        pop r13
        pop rdi
        pop rsi
        jmp .endloop
.S:
        lea r8, [values]
        lea r9, [sync]
        pop rax
        pop qword [r8 + 8*rdi]
        mov [r9 + 8*rdi], rax
.spinlock:
        cmp rdi, [r9 + 8*rax]
        jne .spinlock
        push qword [r8 + 8*rax]
        mov qword [r9 + 8*rax], rax
.spinlock2:
        cmp rdi, [r9 + 8*rdi]
        jne .spinlock2
        jmp .endloop
.end:
        pop rax
        mov rsp, r12
        pop r12
        ret
