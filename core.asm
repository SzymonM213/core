default rel
extern get_value
extern put_value
global core

section .bss
        values: resq N                    ; values[n] = value of the n-th thread's top element of the stack (array to exchange the values between threads)

section .data
        sync: times N dq N                ; sync[n] = n (array to synchronize the threads)

section .text
; core arguments: 
; rdi - thread id (n), 
; rsi - pointer to the code (*p)
core:
        push    r12                       ; Save r12
        mov     r12, rsp                  ; Save rsp
.loop:                                    ; Loop over the *p string
        xor     eax, eax                  ; Clear eax
        mov     al, [rsi]                 ; Read the next character and compare it with all possible options
        test    al, al
        jz      .end
        cmp     al, '+'
        je      .add
        cmp     al, '*'
        je      .mul
        cmp     al, '-'
        je      .neg
        cmp     al, 'n'
        je      .n
        cmp     al, 'B'
        je      .B
        cmp     al, 'C'
        je      .C
        cmp     al, 'D'
        je      .D
        cmp     al, 'E'
        je      .E
        cmp     al, 'G'
        je      .G
        cmp     al, 'P'
        je      .P
        cmp     al, 'S'
        je      .S
        sub     al, '0'                   ;*p is a digit (last possible option left)
.endloopandpush:                          ; Push the result to the stack
        push    rax
.endloop:                                 ; End one iteration of the loop
        inc     rsi
        jmp     .loop
.end:                                     ; End of the program
        pop     rax                       ; Pop the result from the stack
        mov     rsp, r12                  ; Restore the stack
        pop     r12                       ; Restore r12
        ret
.add:                                     ; Add the top two elements of the stack
        pop     rax                       ; rax = top element
        pop     rdx                       ; rdx = second element
        add     rax, rdx                  ; rax = rax + rdx
        jmp     .endloopandpush           ; Push the result to the stack
.mul:                                     ; Multiply the top two elements of the stack
        pop     rax                       ; rax = top element
        pop     rdx                       ; rdx = second element
        mul     rdx                       ; rax = rax * rdx
        jmp     .endloopandpush           ; Push the result to the stack
.neg:                                     ; Negate the top element of the stack
        neg     qword [rsp]               ; [rsp] points to the top element
        jmp     .endloop                  ; End the iteration (nothing to push)
.n:                                       ; Push the thread id to the stack
        push    rdi
        jmp     .endloop
.B:                                       ; Pop the top element of the stack and if the current top element is 0, jump to move the pointer *p by the value of the popped element
        pop     rdx
        mov     rax, [rsp]                ; rax = top element
        test    rax, rax                  ; If rax equals 0, continue and do nothing
        jz      .endloop                  ; End the iteration (nothing to push)
        add     rsi, rdx                  ; Else, move the pointer *p by the value of the popped element
        jmp     .endloop                  ; End the iteration (nothing to push)
.C:                                       ; Pop the top element of the stack and forget it
        pop     rax
        jmp     .endloop                  ; End the iteration (nothing to push)
.D:                                       ; Duplicate the top element of the stack
        pop     rax
        push    rax                       ; Push the top element to the stack
        jmp     .endloopandpush           ; Push the top element to the stack again
.E:                                       ; Exchange the top two elements of the stack
        pop     rdx                       ; rdx = top element
        pop     rax                       ; rax = second element
        push    rdx                       ; Push the top element to the stack
        jmp     .endloopandpush           ; Push the second element to the stack
.G:                                       ; Push the result of get_value() to the stack
        push    rdi                       ; Save rdi
        push    rsi                       ; Save rsi
        push    r13                       ; Save r13
        mov     r13, rsp                  ; Save rsp
        and     rsp, ~15                  ; Align the stack
        call    get_value                 ; Call get_value() (result is in rax)
        mov     rsp, r13                  ; Restore rsp
        pop     r13                       ; Restore r13
        pop     rsi                       ; Restore rsi
        pop     rdi                       ; Restore rdi
        jmp     .endloopandpush           ; Push the result to the stack 
.P:                                       ; Pop the top element of the stack and use it as an argument for put_value()
        xchg    rsi, [rsp]                ; rsi = top element (to call a function with the top of the stack as an argument), [rsp] = rsi (to save rsi)
        push    rdi                       ; Save rdi
        push    r13                       ; Save r13
        mov     r13, rsp                  ; Save rsp
        and     rsp, ~15                  ; Align the stack
        call    put_value                 ; Call put_value(n, <top_element>)
        mov     rsp, r13                  ; Restore rsp
        pop     r13                       ; Restore r13
        pop     rdi                       ; Restore rdi
        pop     rsi                       ; Restore rsi
        jmp     .endloop                  ; End the iteration (nothing to push)
.S:                                       ; Pop the top element m, wait for the S operation from m-th thread with popped n (my thread id) and exchange the top elements of the stacks
        lea     r8, [values]              ; r8 = &values
        lea     r9, [sync]                ; r9 = &sync
        pop     rax                       ; rax = m
        pop     qword [r8 + 8*rdi]        ; values[n] = my top element
        mov     [r9 + 8*rdi], rax         ; sync[n] = m (thread of index n waits for thread of index m)
.spinlock:                                ; Spinlock to wait for the thread of index m
        cmp     rdi, [r9 + 8*rax]         ; If sync[m] != n, mth thread is not waiting for me
        jne     .spinlock                 ; Continue waiting
        push    qword [r8 + 8*rax]        ; Push the top element of the mth thread to the stack
        mov     qword [r9 + 8*rax], rax   ; sync[m] = m to inform the mth thread that I have received the value
.spinlock2:                               ; Spinlock to wait for the mth thread to receive the value
        cmp     rdi, [r9 + 8*rdi]         ; If sync[n] != n, mth thread has not received the value
        jne     .spinlock2
        jmp     .endloop                  ; Both threads have exchanged the top elements of the stacks, end the iteration (nothing to push)
