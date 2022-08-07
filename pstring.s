# 584698174 David Dinkevich

.section    .rodata

pstrij_error_msg:               .string     "invalid input!\n"

.text


.globl  pstrlen
    .type   pstrlen, @function
pstrlen:
    pushq   %rbp
    movq    %rsp, %rbp

    movzbq  (%rdi), %rax                        # Move size byte into %rax (zero extend)

    movq    %rbp, %rsp
    popq    %rbp
    ret

.globl  replaceChar
    .type   replaceChar, @function
replaceChar:
    pushq   %rbp
    movq    %rsp, %rbp
    
    movzbq  (%rdi), %r8         # Get length of string (first bit in str addr)
    
    xorq    %rcx, %rcx          # Zero counter
    xorq    %r9, %r9            # Zero %r9--which will store current char value
    leaq    1(%rdi), %r10       # Stores pointer to curr char (address)
    
    .loop:
        cmp     %rcx, %r8               # Check if we finished iterating string
        je      .end_loop_replaceChar   # If so, exit
        
        movb    (%r10), %r9b            # %r9 stores char at index
        
        cmp     %r9b, %sil              # Check if char is eq to oldChar (in %rsi/%sil)
        jne     .not_eq_replaceChar     # Skip if not eq
        movb    %dl, (%r10)             # Set char equal to new char
        
        .not_eq_replaceChar:
        
        inc     %rcx                    # Increment counter
        inc     %r10                    # Increment pointer
        jmp     .loop
    .end_loop_replaceChar:
    
    
    movq    %rdi, %rax          # Return value is pointer to str
    movq    %rbp, %rsp
    popq    %rbp
    ret

.globl  pstrijcpy
    .type   pstrijcpy, @function
pstrijcpy:
    pushq   %rbp
    movq    %rsp, %rbp
        
    # PREP
    movzbq  %dl, %rdx            # Clean register--byte extend
    movzbq  %cl, %rcx            # Clean register--byte extend
    movzbq  (%rdi), %r8          # Get len of dest string (in %rdi already), store in %r8
    movzbq  (%rsi), %r9          # Get len of dest string (in %rdi already), store in %r9
    
    # INPUT VALIDATION
    
    cmp     %r8, %rdx                       # Check if %rdx >= %r8 => i >= len(str1)
    jge     .begin_bad_box_pstrijcpy    
    cmp     %r9, %rdx                       # Check if %rdx >= %r9 => i >= len(str2)
    jge     .begin_bad_box_pstrijcpy    
    cmp     $0, %rdx                        # Check if %rdx < 0    => i < 0
    jl      .begin_bad_box_pstrijcpy
    
    cmp     %r8, %rcx                       # Check if %rcx >= %r8 => j >= len(str1)
    jge     .begin_bad_box_pstrijcpy
    cmp     %r9, %rcx                       # Check if %rcx >= %r9 => j >= len(str2)
    jge     .begin_bad_box_pstrijcpy
    cmp     $0, %rcx                        # Check if %rcx < 0    => j < 0
    jl      .begin_bad_box_pstrijcpy
    cmp     %rdx, %rcx                      # Check if j < i
    jl      .begin_bad_box_pstrijcpy
    
    jmp     .end_bad_box_pstrijcpy          # Good news! We passed! Skip the bad box...

    .begin_bad_box_pstrijcpy:               # Bad box -- invalid input, must output error msg
    
    xorq	   %rax, %rax                       # Zero rax before function call
    movq   $pstrij_error_msg, %rdi          # Format string
    call   printf                           # Print error
    jmp     .end_of_func_pstrijcpy
    
    .end_bad_box_pstrijcpy:
    
    # WRITING INTO DEST
    
    xorq    %rax, %rax                  # $rax is used as temp in next loop
    leaq    1(%rdi, %rdx), %r10         # %r10 holds initial write address in dest
    leaq    1(%rsi, %rdx), %r11         # %r11 holds initial copy address in src        

    .loop_pstrijcpy:                    
    cmp     %rcx, %rdx                  # While i < j
    jg      .end_of_func_pstrijcpy      # Exit condition: %rdx > %rcx AKA i > j
    movb    (%r11), %al                 # Write char from src (currently held by %r11) into temp (%rax)
    movb    %al, (%r10)                 # Write %rax into dst (currently held by %r10)

    inc     %r10                        # Increment pointer to dest
    inc     %r11                        # Increment pointer to src
    inc     %rdx                        # Increment i
    jmp     .loop_pstrijcpy
    
    .end_of_func_pstrijcpy:             # Exit point--end of function

    movq    %rdi, %rax                  # Return value is pointer to dest
    movq    %rbp, %rsp
    popq    %rbp
    ret
    
.globl  swapCase
    .type   swapCase, @function
swapCase:
    pushq   %rbp
    movq    %rsp, %rbp
    
    call    pstrlen                     # Get length of str
    movq    %rax, %r8                   # Store length in %r8
    
    xorq    %rcx, %rcx                  # Initialize counter
    xorq    %r9, %r9                    # %r9 stores char address
    
    .loop_swapCase:
        cmp     %r8, %rcx               # While %rcx < %r8 => counter < len
        jge     .end_loop_swapCase
        
        leaq    1(%rdi, %rcx), %r9      # Copy addr of char into %r9
        movb    (%r9), %al              # Copy char value into %al
        
        cmp     $65, %al                # If char value < 65, neither
        jl      .is_neither_swapCase
        cmp     $90, %al                # If char value <= 90, then uppercase
        jle     .is_upper_swapCase
        cmp     $97, %al                # If char value < 97, then neither
        jl      .is_neither_swapCase
        cmp     $122, %al               # If char value > 122, then neither
        jg      .is_neither_swapCase    # Otherwise, lowercase
        
        .is_lower_swapCase:
        subb    $32, (%r9)              # Make uppercase - subtract 32
        jmp     .is_neither_swapCase    # Skip lowercase section
        .is_upper_swapCase:
        addb    $32, (%r9)              # Make lowercase - add 32
        
        .is_neither_swapCase:
        inc     %rcx                    # Increment counter
        jmp     .loop_swapCase
        
    .end_loop_swapCase:
    
    movq    %rdi, %rax                  # Return value is pointer to dest
    movq    %rbp, %rsp
    popq    %rbp
    ret


.globl  pstrijcmp
    .type   pstrijcmp, @function
pstrijcmp:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %r12                # Will be used later as temp variable
    pushq   %r13                # Will be used later as temp variable
    pushq   %r14                # Will be used later as temp variable
    
    movzbl  (%rdi), %r8         # %r8 stores length of string 1
    movzbl  (%rsi), %r9         # %r9 stores length of string 2
    
    movzbl  %dl, %rdx           # Clean %rdx register and only relate to first byte
    movzbl  %cl, %rcx           # Clean %rdx register and only relate to first byte
        
    # INPUT VALIDATION
    
    cmp     %r8, %rdx                       # Check if %rdx >= %r8 => i >= len(str1)
    jge     .begin_bad_box_pstrijcmp    
    cmp     %r9, %rdx                       # Check if %rdx >= %r9 => i >= len(str2)
    jge     .begin_bad_box_pstrijcmp    
    cmp     $0, %rdx                        # Check if %rdx < 0    => i < 0
    jl      .begin_bad_box_pstrijcmp
    
    cmp     %r8, %rcx                       # Check if %rcx >= %r8 => j >= len(str1)
    jge     .begin_bad_box_pstrijcmp
    cmp     %r9, %rcx                       # Check if %rcx >= %r9 => j >= len(str2)
    jge     .begin_bad_box_pstrijcmp
    cmp     $0, %rcx                        # Check if %rcx < 0    => j < 0
    jl      .begin_bad_box_pstrijcmp
    cmp     %rdx, %rcx                      # Check if j < i
    jl      .begin_bad_box_pstrijcmp
    
    jmp     .end_bad_box_pstrijcmp          # Good news! We passed! Skip the bad box...
    
    .begin_bad_box_pstrijcmp:               # Bad box -- invalid input, must output error msg
    
    xorq	   %rax, %rax                       # Zero rax before function call
    movq    $pstrij_error_msg, %rdi         # Format string
    call    printf                          # Print error
    movq    $-2, %rax                       # Set return value
    jmp     .end_of_func_pstrijcmp
    
    .end_bad_box_pstrijcmp:
    
    xorq    %rax, %rax                  # %rax is counter in next loop
    movq    %rcx, %r12                  # %r12 holds value j-i
    subq    %rdx, %r12
    xorq    %r10, %r10                  # Clean register
    xorq    %r11, %r11                  # Clean register
    leaq    1(%rdi, %rdx), %r10         # %r10 holds initial write address in str1
    leaq    1(%rsi, %rdx), %r11         # %r11 holds initial write address in str2        
    
    .loop_pstrijcmp:   
        cmp     %r12, %rax              # Check if counter > %rax, if so, strings are equal
        jg      .equal_strs_pstrijcmp

        movb    (%r10), %r13b           # Get char in str1 at current index (as per counter %rax)
        movb    (%r11), %r14b           # Get char in str2 at current index (as per counter %rax)
        
        cmp     %r13b, %r14b            # Compare chars of both strings
        jl      .str1_greater_than_str2
        jg      .str1_less_than_str2
        
        inc     %rax                    # Increment counter
        inc     %r10                    # Increment pointer in str 1
        inc     %r11                    # Increment pointer in str 2
        jmp     .loop_pstrijcmp
    
    .equal_strs_pstrijcmp:
    xorq    %rax, %rax                  # If strings are equal, return value is 0
    jmp     .end_of_func_pstrijcmp      # Skip to end of function

    .str1_less_than_str2:               
    movq    $-1, %rax                   # If str1 < str2, return value is -1
    jmp     .end_of_func_pstrijcmp      # Skip to end of function
    
    .str1_greater_than_str2:
    movq    $1, %rax                    # If str1 > str2, return value is 1

    .end_of_func_pstrijcmp:

    popq    %r14                        # Restore callee-save registers
    popq    %r13                        # Restore callee-save registers
    popq    %r12                        # Restore callee-save registers
    movq    %rbp, %rsp
    popq    %rbp
    ret
