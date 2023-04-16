default rel
extern get_value
extern put_value
;extern N
global core

section .bss
        values: resq N

section .data
        sync: times N dq N


section .text
core:
        push r12
        mov r12, rsp
        dec rsi
.loop:
        inc rsi
        xor eax, eax
        mov al, [rsi]
        test al, al
        jz .end
        cmp al, '+'
        je .add
        cmp al, '-'
        je .neg
        cmp al, '*'
        je .mul
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
        push rax
        jmp .loop
.add:
        pop rax
        pop rdx
        add rax, rdx
        push rax
        jmp .loop
.neg:
        neg qword [rsp]
        jmp .loop
.mul:
        pop rax
        pop rdx
        mul rdx
        push rax
        jmp .loop
.n:
        push rdi
        jmp .loop
.B:
        pop rdx
        mov rax, [rsp]
        test rax, rax
        jz .loop
        add rsi, rdx
        jmp .loop
.C:
        pop rax
        mov rax, [rsp]
        jmp .loop
.D:
        pop rax
        push rax
        push rax
        jmp .loop
.E:
        pop rdx
        pop rax
        push rdx
        push rax
        jmp .loop
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
        push rax
        jmp .loop
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
        jmp .loop
.S:
        pop rax ; komu
        pop rdx ; co
        lea r8, [values]
        lea r9, [sync]
        mov [r8 + 8*rdi], rdx
        mov [r9 + 8*rdi], rax
.spinlock:
        cmp rdi, [r9 + 8*rax]
        jne .spinlock
        push qword [r8 + 8*rax]
        mov qword [r9 + 8*rdi], N
        mov rcx, N
.spinlock2:
        cmp rcx, [r9 + 8*rax]
        jne .spinlock2
        jmp .loop
.end:
        pop rax
        mov rsp, r12
        pop r12
        ret
