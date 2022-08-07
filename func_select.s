# 584698174 David Dinkevich

.section       .rodata
invalid_inp_msg:                .string     "invalid option!"

pstrlen_output_string:          .string     "first pstring length: %d, second pstring length: %d\n"

replace_char_dialog_outp_str:   .string     "old char: %c, new char: %c, first string: %s, second string: %s\n"
replace_char_dialog_inp_str:    .string     " %c %c"

pstrij_dialog_inp_str:          .string     " %d%d"
pstrij_dialog_outp_str:         .string     "length: %d, string: %s\n"

pstrijcmp_dialog_outp_str:      .string     "compare result: %d\n"


# =======================
#       JUMP TABLE
# =======================

    .align      8
    .jump_table:
        .quad   .pstrlen        # 50
        .quad   .default        # Not an option
        .quad   .replace_char   # 52
        .quad   .pstrijcpy      # 53
        .quad   .swap_case      # 54
        .quad   .pstrijcmp      # 55
        .quad   .default        # Not an option
        .quad   .default        # Not an option
        .quad   .default        # Not an option
        .quad   .default        # Not an option
        .quad   .pstrlen        # 60: pstrlen
        
.data

.set                jump_table_size, 11

.text

.globl  run_func
    .type   run_func, @function
run_func:
    pushq   %rbp
    movq    %rsp, %rbp
    
    # HANDLE JUMP TABLE ACCESS
    
    xorq    %r8, %r8                    # Zero %r8, which stores index in jump table
    movl    %edi, %r8d                  # Move function number into %r8
    subq    $50, %r8                    # Get relative index
    cmpq    $jump_table_size, %r8       # Compare with size of jump table
    jae     .default                    # Go to default case
    
    movq    %rsi, %rdi                  # Move addr of first string to %rdi
    movq    %rdx, %rsi                  # Move addr of second string to %rsi
    
    jmp     *.jump_table(,%r8, 8)       # Jump to corresponding case in switch table
    
    .pstrlen:                           # pstrlen routine
    call    dialog_pstrlen
    jmp     .end_jump_table
    
    .replace_char:                      # replace_char routine
    call    dialog_replace_char
    jmp     .end_jump_table
    
    .pstrijcpy:                         # pstrijcpy routine
    call    dialog_pstrijcpy
    jmp     .end_jump_table
    .swap_case:                         # swap_case routine
    call    dialog_swapCase
    jmp     .end_jump_table
    .pstrijcmp:                         # pstrijcmp routine
    call    dialog_pstrijcmp
    jmp     .end_jump_table
    .default:                           # default routine - print "invalid input"
    movq    $invalid_inp_msg, %rdi      # Print error message for invalid input
    xorq    %rax, %rax
    call    printf
    .end_jump_table:
    
    xorq    %rax, %rax                  # Return value is 0
    movq    %rbp, %rsp
    popq    %rbp
    ret


    .type   dialog_pstrlen, @function
dialog_pstrlen:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %r12                                # Saving callee-save register
    
    call    pstrlen                             # Get length of first string (addr in %rdi)
    movq    %rax, %r12                          # Store in %r12
    movq    %rsi, %rdi                          # Move len of second string into %rdi for func call
    call    pstrlen                             # Get length of second string (addr in %rdi)
    movq    %rax, %rdx                          # Move length of second string in %rdx (for printf)
    movq    %r12, %rsi                          # Store len of first string in %rsi (for printf)
    movq    $pstrlen_output_string, %rdi        # Input format str
    xorq    %rax, %rax                          # Zero %rax for printf
    call    printf                              # Print
    
    popq    %r12                                # Release calee-save register
    xorq    %rax, %rax                          # Return value is 0
    movq    %rbp, %rsp
    popq    %rbp
    ret
    
    .type   dialog_replace_char, @function
dialog_replace_char:
    pushq   %rbp
    movq    %rsp, %rbp
    
    subq    $32, %rsp                               # Allocate memory for input
    movq    %rdi, 12(%rsp)                          # Store first string addr on stack
    movq    %rsi, 20(%rsp)                          # Store second string addr on stack

    movq    $replace_char_dialog_inp_str, %rdi      # Input string for scanf
    movq    %rsp, %rsi                              # Stores first number
    leaq    1(%rsp), %rdx                           # Stores second number
    xorq    %rax, %rax                              # Zero rax before function call
    call    scanf

    xorq    %rsi, %rsi                              # Clean register
    xorq    %rdx, %rdx                              # Clean register
    movzbq  (%rsp), %rsi                            # Load first number
    movzbq  1(%rsp), %rdx                           # Load second number
            
    movq    12(%rsp), %rdi                          # Restore original first string addr
    call    replaceChar                             # Replace char in first string
    movzbq  (%rsp), %esi                            # Load first number
    movzbq  1(%rsp), %edx                           # Load second number
    movq    20(%rsp), %rdi                          # Restore original second string addr
    call    replaceChar                             # Replace char in second string
    
    movq    $replace_char_dialog_outp_str, %rdi     # Output string for printf
    movb    (%rsp), %sil                            # Load first number
    movb    1(%rsp), %dl                            # Load second number
    movq    12(%rsp), %rcx                          # Load first string as param
    inc     %rcx                                    # Skip first byte at str addr (which is size byte)
    movq    20(%rsp), %r8                           # Load second string as param
    inc     %r8                                     # Skip first byte at str addr (which is size byte)
    xor     %rax, %rax
    call    printf
    
    xorq    %rax, %rax                              # Return value is 0
    movq    %rbp, %rsp
    popq    %rbp
    ret

    .type   dialog_pstrijcpy, @function
dialog_pstrijcpy:
    pushq   %rbp
    movq    %rsp, %rbp    

    subq    $32, %rsp                       # Allocate memory for input
    movq    %rdi, 12(%rsp)                  # Store first string addr on stack
    movq    %rsi, 20(%rsp)                  # Store second string addr on stack

    movq    $pstrij_dialog_inp_str, %rdi    # Input format string
    leaq    4(%rsp), %rsi                   # Move storage address for first number
    leaq    8(%rsp), %rdx                   # Move storage address for second number
    xorq    %rax, %rax                      # Zero rax before function call
    call    scanf
    
    movq    12(%rsp), %rdi                  # Load addr of first str as first param
    movq    20(%rsp), %rsi                  # Load addr of second str as second param
    movl    4(%rsp), %edx                   # Load first inputted number as third param
    movl    8(%rsp), %ecx                   # Load second inputted number as fourth param
    call    pstrijcpy
    
    # PRINT FIRST STRING
    
    movq    $pstrij_dialog_outp_str, %rdi   # Load format string
    movq    12(%rsp), %rax                  # Load address OF address of dest str into %rax
    movzbq  (%rax), %rsi                    # Load address of dest str (also addr of size bit) into %rsi as second param
    leaq    1(%rax), %rdx                   # Load address of dest str (plus one to skip size bit)
    xorq    %rax, %rax
    call    printf    
    
    # PRINT SECOND STRING
    
    movq    $pstrij_dialog_outp_str, %rdi   # Load format string
    movq    20(%rsp), %rax                  # Load address OF address of src str into %rax
    movzbq  (%rax), %rsi                    # Load address of src str (also addr of size bit) into %rsi as second param
    leaq    1(%rax), %rdx                   # Load address of src str (plus one to skip size bit)
    xorq    %rax, %rax
    call    printf    
    
    xorq    %rax, %rax                      # Return value is 0
    movq    %rbp, %rsp
    popq    %rbp
    ret

.globl  dialog_swapCase
    .type   dialog_swapCase, @function
dialog_swapCase:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %r12                            # %r12 stores addr of first str (backup for %rdi)
    pushq   %r13                            # %r13 stores addr of first str (backup for %rsi)
    
    movq    %rdi, %r12                      # Backup %rdi into %r12
    movq    %rsi, %r13                      # Backup %rsi into %r13
    
    call    swapCase                        # Call swapCase on first str
    movq    %r13, %rdi                      # Load second str into param 1
    call    swapCase                        # Call swapCase on second str
    
    movq    $pstrij_dialog_outp_str, %rdi   # Load format string
    movzbq  (%r12), %rsi                    # Copy size bit of first str into second param
    leaq    1(%r12), %rdx                   # Copy addr of first str (skipping size byte) into third param
    xorq    %rax, %rax
    call    printf    
    
    movq    $pstrij_dialog_outp_str, %rdi   # Load format string
    movzbq  (%r13), %rsi                    # Copy size bit of second str into second param
    leaq    1(%r13), %rdx                   # Copy addr of second str (skipping size byte) into third param
    xorq    %rax, %rax
    call    printf    
    
    popq    %r13                            # Restore callee-save registers
    popq    %r12                            # Restore callee-save registers
    movq    %rbp, %rsp
    popq    %rbp
    ret


.globl  dialog_pstrijcmp
    .type   dialog_pstrijcmp, @function
dialog_pstrijcmp:
    pushq   %rbp
    movq    %rsp, %rbp    

    subq    $32, %rsp                           # Allocate memory for input
    movq    %rdi, 12(%rsp)                      # Store first string addr on stack
    movq    %rsi, 20(%rsp)                      # Store second string addr on stack

    movq    $pstrij_dialog_inp_str, %rdi        # Input format string
    leaq    4(%rsp), %rsi                       # Move storage address for first number
    leaq    8(%rsp), %rdx                       # Move storage address for second number
    xorq    %rax, %rax                          # Zero rax before function call
    call    scanf
    
    movq    12(%rsp), %rdi                      # Load addr of first str as first param
    movq    20(%rsp), %rsi                      # Load addr of second str as second param
    movl    4(%rsp), %edx                       # Load first inputted number as third param
    movl    8(%rsp), %ecx                       # Load second inputted number as fourth param
    call    pstrijcmp
    
    movq    $pstrijcmp_dialog_outp_str, %rdi    # Load format string
    movq    %rax, %rsi                          # Load return value of pstrijcmp into second param
    xorq    %rax, %rax
    call    printf
                
    xorq    %rax, %rax                          # Return value is 0
    movq    %rbp, %rsp
    popq    %rbp
    ret





