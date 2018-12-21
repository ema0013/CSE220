# Edwin Ma
# edma
# 111645435

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
addr_arg2: .word 0
addr_arg3: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Output strings
zero_str: .asciiz "Zero\n"
neg_infinity_str: .asciiz "-Inf\n"
pos_infinity_str: .asciiz "+Inf\n"
NaN_str: .asciiz "NaN\n"
floating_point_str: .asciiz "_2*2^"

# Miscellaneous strings
nl: .asciiz "\n"

# Put your additional .data declarations here, if any.
#Part 3 Declarations
neg_sign:"-"
one_dot:"1."
# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beq $a0, 0, zero_args
    beq $a0, 1, one_arg
    beq $a0, 2, two_args
    beq $a0, 3, three_args
four_args:
    lw $t0, 12($a1)
    sw $t0, addr_arg3
three_args:
    lw $t0, 8($a1)
    sw $t0, addr_arg2
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here
zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory
    
start_coding_here:
    lw $s0, addr_arg0
    lbu $t0, 0($s0) #load the first byte in register s0, which is argument
    li $s1, 1 #constant one for comparisons
    
    li $t1, 'C'
    seq $t2, $t0, $t1 #set $t4 to 1 if $t0 and $t1 are equal, else 0
    beq $t2, $s1, run_c #if $t2 is 1 go to run_c
    
    li $t1, 'F'
    seq $t2, $t0, $t1 #set $t4 to 1 if $t0 and $t1 are equal, else 0
    beq $t2, $s1, run_f #if $t2 is 1 go to run_f
    
    li $t1, '2'
    seq $t2, $t0, $t1 #set $t4 to 1 if $t0 and $t1 are equal, else 0
    beq $t2, $s1, run_2 #if $t2 is 1 go to run_2
    
    beqz $t2, invalid_oper # if zero go to invalid_oper
    
run_c:
    li $t0, 4 #register value 4
    la $s2, num_args #load address of number of arguments
    lbu $t1, 0($s2) #set t1 to number of args
    
    bne $t0, $t1, invalid_args #if num args not equal to 4
    #part four
    lw $s2, addr_arg1
    lbu $s0, 0($s2) #first character of addr1
    lw $t1, addr_arg2
    lbu $s1, 0($t1) #base of input in ascii
    li $s4, '\0'
    li $s3, 0 #length of string
valid_loop:
    addi $s3,$s3,1
    bge $s0,$s1,invalid_args
    addi $s2,$s2,1
    lbu $s0, 0($s2)
    beq $s0,$s4,valid_loop_done
    j valid_loop
valid_loop_done:
     lw $s1, addr_arg2
     lbu $t0,0($s1)
     li $t1, '0'
     sub $s1,$t0,$t1 #s1 is value of the base
     addi $s3,$s3,-1 #s3 is now length-1
     lw $s2, addr_arg1
     lbu $s0, 0($s2) #first character of addr1
     li $s5, 0 #decimal form of value
     li $s6, 1 #for storing current value of the digit place
     sub $s0,$s0,$t1 #for numeric value of character
     addi $s4,$s3,0 #set $s4 to current value of length for looping 
base_dec_loop:
    bgt $s4,$zero,power_loop  
    mul $s6,$s6,$s0 #multiply s6 by digits place
    add $s5,$s5,$s6
    
    addi $s3,$s3,-1 #subtract one from s3
    beq $s3, -1, dec_base      
    addi $s2,$s2,1
    li $s6,1
    lbu $s0,0($s2)
    li $t0,'0'
    sub $s0,$s0,$t0
    addi $s4,$s3,0                                 
    j base_dec_loop
power_loop:
    mul $s6,$s6,$s1 #multiply s6 by base
    addi $s4,$s4, -1 #subtract from s4 to keep loop going
    j base_dec_loop
dec_base:    
    lw $s1, addr_arg3
    move $a0,$s1
    li $v0,84
    syscall
    move $s1,$v0 #s1 is the base to convert to
    li $s2,0 #loop counter
dec_base_loop:
    div $s5,$s1 #divide to get quotient
    mflo $s5 #quotient
    mfhi $t0 #remainder
    
    addi $sp,$sp,-4
    sw $t0,0($sp)
    addi $s2,$s2,1 #loop counter for stack
    
    beq $s5,$zero,print_base
    j dec_base_loop
print_base:
    lw $t0,0($sp)
    addi $sp,$sp,4 #going through the stack since its FILO
    addi $s2,$s2,-1
    li $v0, 1
    move $a0,$t0
    syscall 
    beq $s2,$zero,exit
    j print_base
run_f:
    li $t0, 2 #temp register value of two
    la $s2, num_args
    lbu $t1, 0($s2) #load value of num_args
    
    bne $t0, $t1, invalid_args #if number of arguments not two invalid arguments 
    #Part three of HW
    li $s0, 0 #current length of arg being read
    lw $s1, addr_arg1 #word of second input
    lbu $s4, 0($s1) #first character of addr_arg
    li $s5, '\0'
test_loop:
    addi $s0,$s0,1 #add one to current length
    ##code for testing if character is hexadecimal
    li $t0, '0'
    li $t1, '9'
    blt $s4,$t0,invalid_args # if less than A ascii invalid arg
    bgt $s4,$t1,is_char_alpha
    addi $s1,$s1,1 #add one to address
    lbu $s4, 0($s1) #move to next char
    beq $s4,$s5,test_loop_done
    j test_loop 
    
is_char_alpha:
    li $t0, 'A'
    li $t1, 'F'
    blt $s4,$t0,invalid_args
    bgt $s4,$t1,invalid_args 
    addi $s1,$s1,1 #add one to address
    lbu $s4, 0($s1) #move to next char
    beq $s4,$s5,test_loop_done
    j test_loop 
test_loop_done:
    li $t5,8 #arg_1 must be exactly length 8
    bne $t5,$s0,invalid_args
    #convert string into a binary
    li $s3, 0 #this will contain the binary value 
    lw $s1, addr_arg1
    lbu $s4, 0($s1) #first character of addr_arg
hex_bin_loop:
    li $t0, '9'
    bgt $s4,$t0,alpha_convert
    li $t0, '0'
    sub $t1,$s4,$t0 #t1 has value of s4 character
    li $t0, 1
    sub $s0,$s0,$t0
    li $t2,4
    mul $t2,$t2,$s0 #how many bits to shift by
    sllv $t1,$t1,$t2
    
    add $s3,$s3,$t1
    addi $s1,$s1,1
    lbu $s4, 0($s1)
    beq $s4,$s5,interpret_special  
    j hex_bin_loop
alpha_convert:
    li $t0, '7' #7 has ascii value of 55 
    sub $t1,$s4,$t0 #t1 has value of s4 char 
    li $t0, 1
    sub $s0,$s0,$t0
    li $t2,4
    mul $t2,$t2,$s0
    sllv $t1,$t1,$t2
    
    add $s3,$s3,$t1
    addi $s1,$s1,1
    lbu $s4, 0($s1)
    beq $s4,$s5,interpret_special                                                   
    j hex_bin_loop
interpret_special:
     beq $s3,$zero,print_zero #check for positive zero
     li $t0, 8
     srl $t1,$s3,28
     beq $t0,$t1,check_zero
     li $t0, 255
     sll $t1,$s3,1
     srl $t1,$t1,24 #e of ieee format 
     seq $t2,$t0,$t1 #t2 is 1 if e is ff
     sll $t0,$s3,9 #t0 is mantissa
     sne $t3,$t0,$zero #set t3 to 1 if mantissa not a zero
     beq $t2,$t3, print_nan #check for nan first to prevent short circuiting
     srl $t1,$s3,20 #for checking positive or negative infinity
     li $t0, 2040
     beq $t0,$t1,print_pos_inf
     li $t0, 4088
     beq $t0,$t1,print_neg_inf
print_ieee: #interpreting part
     srl $t0,$s3,31
     beq $t0,1,negative_ieee 
     li $v0,4 #print leading one
     la $a0, one_dot
     syscall
     
     sll $s6,$s3,9 #mantissa
     li $s2,23 #length of mantissa
print_mantissa:
    srl $t1,$s6,31 #shift left by 1 to get leftmost bit
    li $v0,1 #print t1
    move $a0,$t1
    syscall 
    
    li $t0,1
    sub $s2,$s2,$t0 #subtract one from length
    sll $s6,$s6,1
    beq $s2,0,print_exp
    j print_mantissa  
print_exp:
    li $v0,4
    la $a0,floating_point_str
    syscall
    sll $t1,$s3,1
    srl $t1,$t1,24 #e of ieee format  
    li $t0,127
    sub $t1,$t1,$t0 #get rid of the 127 bias
    li $v0, 1
    move $a0, $t1
    syscall
    j exit
negative_ieee:
    li $v0,4 #print -
    la $a0,neg_sign     
    syscall
    li $v0,4 #print leading one
    la $a0, one_dot
    syscall
    sll $s6,$s3,9 #mantissa
    li $s2,23 #length of mantissa
    j print_mantissa
print_nan:
     li $v0,4
     la $a0, NaN_str
     syscall
     j exit
print_pos_inf:
     li $v0,4
     la $a0, pos_infinity_str
     syscall
     j exit
print_neg_inf:
     li $v0,4
     la $a0, neg_infinity_str
     syscall
     j exit      
check_zero:     #check for negative zero
     sll $t0,$s3,4 
     beq $t0,$zero,print_zero                  
print_zero:
     li $v0,4
     la $a0, zero_str
     syscall
     j exit    
run_2:
    li $t0, 2 #temp register value of two
    la $s2, num_args
    lbu $t1, 0($s2) #load value of num_args
    bne $t0, $t1, invalid_args #if number of arguments not two invalid arguments 
    #Part two of HW
    li $s0, 32 #max length of argument, size of 32 characters
    li $s1, 0 #current length of arg that's been read reading
    lw $s2, addr_arg1 #word of second input
    li $s3, '1' #one constant
    li $s4, '0' #zero constant
    # loop
    lbu $s6, 0($s2) #first character of addr_arg
    li $s5, '\0'
char_while_loop: 
    addi $s1, $s1, 1 #add one to current length of chars read
    beq $s6,$s3,IF
    bne $s6,$s4, invalid_args
IF:
    addi $s2, $s2, 1 #add one to address at s2
    lbu $s6, 0($s2) #move s6 to next char
    beq $s6,$s5, char_while_loop.done
    j char_while_loop   
char_while_loop.done:
    bgt $s1, $s0, invalid_args #if total # of chars read greater than 32 
    li $s0, 1 #set s0 to 1 for subtraction loops
    li $s7, 0 #this will be the int containing the decimal value
    lw $s2, addr_arg1
    lbu $s6, 0($s2) #leftmost bit, the sign bit
    sub $s1,$s1,$s0 #s1 is now s1-1
    beq $s6,$s4,reg_bin #if the leftmost bit is a 0, do regular binary conversion 
    ##CODE FOR two's complement negative
twos_loop:
    lbu $s6, 0($s2) #set s6 to next character
    seq $t0,$s6,$s4 #t0 is 0 if char is 1, else 1 if char is 0 
    sllv $t1, $t0, $s1 #convert to decimal by 1*2^(counter) shift left 
    sub $s7, $s7, $t1 #subtract from sum
    addi $s2, $s2, 1 #add one to address at s2
    sub $s1, $s1, $s0 #move counter to next char input
    lbu $s6, 0($s2) #move s6 to next char
    beq $s6,$s5, add_one        
    j twos_loop
add_one:
    sub $s7,$s7,$s0 
    j print_ans2   
reg_bin:
    lbu $s6, 0($s2) #set s6 to next character
    seq $t0,$s6,$s3 #t0 is 1 if char is 1, else 0
    sllv $t1, $t0, $s1 #convert to decimal by 1*2^(counter) shift left
    add $s7, $s7, $t1 #add to sum
    addi $s2, $s2, 1 #add one to address at s2
    sub $s1, $s1, $s0 #move counter to next char input
    lbu $s6, 0($s2) #move s6 to next char
    beq $s6,$s5, print_ans2	
    j reg_bin
print_ans2:
    li $v0, 1
    move $a0, $s7
    syscall
    j exit     
invalid_oper:
    la $a0, invalid_operation_error #load address for ascii invalid operation
    li $v0, 4
    syscall  #print $a0
    j exit
invalid_args:
    la $a0, invalid_args_error #load address for ascii invalid arguments
    li $v0, 4
    syscall  #print $a0
    j exit        
exit:
    li $v0, 10   # terminate program
    syscall