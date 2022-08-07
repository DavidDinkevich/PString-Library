# 584698174 David Dinkevich

.section    .rodata

enter_num_string:               .string     " %d"
enter_str_string:               .string     " %s"

.text
.extern run_func

.globl  run_main
    .type   run_main, @function
run_main:
    movq    %rsp,    %rbp

    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %r12                        # %r12 will store addr of first string
    pushq   %r13                        # %r13 will store addr of second string
     
    # FIRST STRING 
     
    subq    $272, %rsp                  # Allocate memory for first string (256+16) - the 16 for len input
    leaq    4(%rsp), %r12               # %r12 stores address of first string
    
    movq    $enter_num_string, %rdi     # Input format string
    leaq    4(%rsp), %rsi               # Store size of first string in 4(%rsp)
    xorq    %rax, %rax                  # Zero rax before function call
    call    scanf
        
    movq    $enter_str_string, %rdi
    leaq    5(%rsp), %rsi               # Store characters of first string starting from 5(%rsp)
    xorq    %rax, %rax                  # Zero rax before function call
    call    scanf

    movzbq  4(%rsp), %rax               # Move size of string into %rax
    movb    $0, 5(%rsp, %rax)           # Set 1 + addr(str) + len(str) to '\0' - terminating char
    
    # SECOND STRING
    
    subq    $272, %rsp                  # Allocate memory for second string (256+16) - the 16 for len input
    leaq    4(%rsp), %r13               # %r13 stores address of second string

    movq    $enter_num_string, %rdi     # Input format string
    leaq    4(%rsp), %rsi               # Store size of second string in 4(%rsp)
    xorq    %rax, %rax                  # Zero rax before function call
    call    scanf
        
    movq    $enter_str_string, %rdi     # Input format string
    leaq    5(%rsp), %rsi               # Store characters of second string starting from 5(%rsp)
    xorq    %rax, %rax                  # Zero rax before function call
    call    scanf

    movzbq  4(%rsp), %rax               # Move size of string into %rax
    movb    $0, 5(%rsp, %rax)           # Set 1 + addr(str) + len(str) to '\0' - terminating char
        
    # GET FUNCTION NUMBER
    
    subq    $16, %rsp                   # Allocate more memory for function number input
    
    movq    $enter_num_string, %rdi     # Input format string
    leaq    4(%rsp), %rsi               # Store input in 4(%rsp)
    xorq    %rax, %rax                  # Zero rax before function call
    call    scanf
        
    # CALL run_func
    
    xorq    %rdi, %rdi                  # Clean register
    movl    4(%rsp), %edi               # Move func number in 4(%rsp) to %rdi
    
    movq    %r12, %rsi                  # Move addr of first string to %rsi
    movq    %r13, %rdx                  # Move addr of second string to %rdx
    call    run_func
    
    
    popq    %r13                        # Restore callee-save register
    popq    %r12                        # Restore callee-save register
    xorq    %rax, %rax                  # Return value is 0
    movq    %rbp, %rsp
    popq    %rbp
    ret


