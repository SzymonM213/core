global core

section .text
core:
        pop r8
        xor eax, eax
        mov al, byte [rsi]
        cmp al, '+'
        je .add
        cmp al, '-'
        je .sub
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
        sub al, '0' ;*p is a digit
        push rax
        jmp .end
.add:
        pop rax
        pop rdx
        add rax, rdx
        push rax
        jmp .end
.sub:
        pop rax
        pop rdx
        sub rax, rdx
        push rax
        jmp .end
.mul:
        pop rax
        pop rdx
        mul rax, rdx
        push rax
        jmp .end
.n:
        mov rax, rsi
        push rax
        jmp .end
.B:
        pop rdx
        pop rax
        test rax, rax
        jnz
        ; TODO
.C:
        pop
        mov rax, [rsp]
        jmp .end
.D:
        pop rax
        push rax
        push rax
        jmp .end
.end:
        push r8
        ret