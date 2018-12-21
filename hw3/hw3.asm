# Edwin Ma
# edma
# 111645435

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################

.text

# Part I
get_adfgvx_coords:
li $v0, -200
li $v1, -200
move $t1, $a0 #index 1
move $t2, $a1 #index 2

bgt $t1,5,return_error 
blt $t1,0,return_error
bgt $t2,5,return_error
blt $t2,0,return_error

addi $sp,$sp,-6
li $t0, 'A'
sb $t0,0($sp)
li $t0, 'D'
sb $t0,1($sp)
li $t0, 'F'
sb $t0,2($sp)
li $t0, 'G'
sb $t0,3($sp)
li $t0, 'V'
sb $t0,4($sp)
li $t0, 'X'
sb $t0,5($sp)

select_v_zro:
beq $t1,0,select_A0
beq $t1,1,select_D0
beq $t1,2,select_F0
beq $t1,3,select_G0
beq $t1,4,select_V0
beq $t1,5,select_X0
select_v_one:
beq $t2,0,select_A1
beq $t2,1,select_D1
beq $t2,2,select_F1
beq $t2,3,select_G1
beq $t2,4,select_V1
beq $t2,5,select_X1

select_A0:
lbu $t0,0($sp)
move $v0,$t0
j select_v_one
select_D0:
lbu $t0,1($sp)
move $v0,$t0
j select_v_one
select_F0:
lbu $t0,2($sp)
move $v0,$t0
j select_v_one
select_G0:
lbu $t0,3($sp)
move $v0,$t0
j select_v_one
select_V0:
lbu $t0,4($sp)
move $v0,$t0
j select_v_one
select_X0:
lbu $t0,5($sp)
move $v0,$t0
j select_v_one

select_A1:
lbu $t0,0($sp)
move $v1,$t0
addi $sp,$sp,6
jr $ra
select_D1:
lbu $t0,1($sp)
move $v1,$t0
addi $sp,$sp,6
jr $ra
select_F1:
lbu $t0,2($sp)
move $v1,$t0
addi $sp,$sp,6
jr $ra
select_G1:
lbu $t0,3($sp)
move $v1,$t0
addi $sp,$sp,6
jr $ra
select_V1:
lbu $t0,4($sp)
move $v1,$t0
addi $sp,$sp,6
jr $ra
select_X1:
lbu $t0,5($sp)
move $v1,$t0
addi $sp,$sp,6
jr $ra

return_error:
li $v0, -1
li $v1, -1 
jr $ra	

# Part II
search_adfgvx_grid:
li $v0, -200
li $v1, -200
move $t5,$a0 #address of grid
move $t6, $a1 #object to find

li $t0, 0 #rows

row_loop:
li $t1, 0 #columns
col_loop:
li $t2, 6 #for multiplication
mul $t3,$t2,$t0 #i*num of rows
add $t3,$t3,$t1 #i*num of rows + j
add $t3,$t3,$t5 #(i*num of rows + j) + grid_address

lbu $t4, 0($t3) #current item
beq $t4,$t6,index_found
addi $t1,$t1,1
beq $t1,6,col_loop_done
j col_loop
col_loop_done:
addi $t0,$t0,1
beq $t0,6,error_statement
j row_loop

error_statement:
li $v0,-1
li $v1,-1
jr $ra

index_found:
move $v0,$t0
move $v1,$t1
jr $ra

# Part III
map_plaintext:
li $v0, -200
li $v1, -200
move $s0,$a0 #adfgvx grid
move $s1,$a1 #plaintext
move $s2,$a2 #middletext buffer

lbu $t0, 0($s1) #first character of plaintext

loop:
li $t1, '\0'
beq $t0,$t1,loop_over
move $a0,$s0 #adfgvx grid
move $a1,$t0 #current letter
addi $sp,$sp,-16
sw $ra,0($sp)
sw $s0,4($sp)
sw $s1,8($sp)
sw $s2,12($sp)
jal search_adfgvx_grid
move $a0,$v0 #coordinate a
move $a1,$v1 #coordinate b
jal get_adfgvx_coords
lw $ra,0($sp)
lw $s0,4($sp)
lw $s1,8($sp)
lw $s2,12($sp)
addi $sp,$sp,16
move $t2,$v0 #letter 1
move $t3,$v1 #letter 2
sb $t2,0($s2) #change buffer
addi $s2,$s2,1 
sb $t3,0($s2) #change buffer

addi $s1,$s1,1 #move on to next plaintext char
addi $s2,$s2,1 #next position in buffer
lbu $t0, 0($s1)#first character of plaintext
j loop

loop_over:
jr $ra

# Part IV
swap_matrix_columns:
li $v0, -200
li $v1, -200
move $s0,$a0 #matrix address
move $s1,$a1 #number of rows
move $s2,$a2 #number of columns
move $s3,$a3 #col #1 index
#column #2 is word $t0 on stack at offset 0

ble $s1,0,error
ble $s2,0,error
blt $s3,0,error
bge $s3,$s2,error
lw $t0,0($sp)
blt $t0,0,error
bge $t0,$s2,error

li $t1,0 #row counter
swap_loop:

mul $t3,$t1,$s2 #i*num of rows
add $t3,$t3,$s3 #i*num of rows + col 1
add $t3,$t3,$s0 #(i*num of rows + col 1 )+ matrix address
lbu $t2,0($t3) #letter at col1

mul $t4,$t1,$s2
add $t4,$t4,$t0 #i*num of rows + col 2
add $t4,$t4,$s0
lbu $t5, 0($t4) #letter at col2

#swap
sb $t5,0($t3)
sb $t2,0($t4)

addi $t1,$t1,1
beq $t1,$s1,end_loop
j swap_loop

end_loop:
li $v0,0
jr $ra
error:
li $v0,-1
jr $ra

# Part V
key_sort_matrix:
li $v0, -200
li $v1, -200
move $s0,$a0 #matrix 
move $s1,$a1 #num rows
move $s2,$a2 #num cols
move $s3,$a3 #key array length 6
#elem_size is in 0($sp) $t0
lw $t0,0($sp)
move $s4,$t0

li $s5,-1 #row counter ie. i 
bubble_sort:
addi $s5,$s5,1
beq $s5,$s2,end #s2 is number of columns ie length of key
sub $s6,$s2,$s5
addi $s6,$s6,-1 #n-i-1
li $s7,-1 #j

inside_loop:
addi $s7,$s7,1
beq $s6,$s7,bubble_sort
beq $s4,4,inside_loop_word
#this for byte elements specifically
add $t4,$s7,$s3 #address of j
addi $t5,$t4,1 #j+1
lbu $t2, 0($t4) #key[j]
lbu $t3, 0($t5) #key[j+1]
bge $t3,$t2,inside_loop #move on if key[j]<=key[j+1]
sb $t2,0($t5)
sb $t3,0($t4)

addi $sp,$sp,-36
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp) #element_size
sw $s5, 24($sp)
sw $s6, 28($sp)
sw $s7, 32($sp)
sw $ra, 36($sp)

move $a0,$s0
move $a1,$s1
move $a2,$s2
move $a3,$s7 #col1
addi $t0,$s7,1 #col2
sw $t0,0($sp)

jal swap_matrix_columns

lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp) #element_size
lw $s5, 24($sp)
lw $s6, 28($sp)
lw $s7, 32($sp)
lw $ra, 36($sp)
addi $t0,$s4,0 
sw $t0,0($sp)
addi $sp,$sp,36
j inside_loop

inside_loop_word:
li $t6,4
mul $t4,$s7,$t6
add $t4,$t4,$s3 #address of key[j]
addi $t5,$t4,4 #address of key[j+1]
lw $t2, 0($t4)
lw $t3, 0($t5)
bge $t3,$t2,inside_loop
sw $t2, 0($t5)
sw $t3, 0($t4)

addi $sp,$sp,-36
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp) #element_size
sw $s5, 24($sp)
sw $s6, 28($sp)
sw $s7, 32($sp)
sw $ra, 36($sp)

move $a0,$s0
move $a1,$s1
move $a2,$s2
move $a3,$s7 #col1
addi $t0,$s7,1 #col2
sw $t0,0($sp)

jal swap_matrix_columns

lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp) #element_size
lw $s5, 24($sp)
lw $s6, 28($sp)
lw $s7, 32($sp)
lw $ra, 36($sp)
addi $t0,$s4,0 
sw $t0,0($sp)
addi $sp,$sp,36
j inside_loop

end:
jr $ra
# Part VI
transpose:
li $v0, -200
li $v1, -200
move $s0,$a0 #source
move $s1,$a1 #destination
move $s2,$a2 #num of rows
move $s3,$a3 #num of cols

ble $s3,0,error
ble $s2,0,error

li $t1,-1 #row counter, i
transpose_loop:
addi $t1,$t1,1
beq $t1,$s2,end

li $t0,-1 #col counter, j
cols_loop:
addi $t0,$t0,1
beq $t0,$s3,transpose_loop
mul $t3,$t1,$s3 #i*num of cols
add $t3,$t3,$t0 #i*num of cols + j
add $t3,$t3,$s0 #(i*num of cols + j )+ src address
lbu $t4,0($t3) #byte at src[i][j]

mul $t5,$t0,$s2
add $t5,$t5,$t1 #j*num of rows + i)+dest address
add $t5,$t5,$s1 #address of dest[j][i]

sb $t4,0($t5) #store src[i][j] at dest[j][i]
j cols_loop
 #end is defined somewhere up top

# Part VII
encrypt:
li $v0, -200
li $v1, -200

move $s0,$a0 #adfgvx grid
move $s1,$a1 #plaintext
move $s2,$a2 #keyword
move $s3,$a3 #ciphertext ie result
#determine space needed to be allocated
li $t0,0
move $t1,$s1
lbu $t2,0($t1)
heap_loop:
beq $t2,'\0',verify_heap
addi $t0,$t0,2
addi $t1,$t1,1
lbu $t2,0($t1)
j heap_loop

verify_heap:
move $s5,$t0 #$t0 has length of heap space
#calculate key length to ensure heap space works
li $t1,0
move $t2,$s2 #keyword address
lbu $t3, 0($t2)
keylength_loop:
beq $t3,'\0',ok_matrix
addi $t1,$t1,1
addi $t2,$t2,1
lbu $t3, 0($t2)
j keylength_loop

ok_matrix:
move $s6,$t1 #we want to key length 

div $s5,$s6 
mfhi $t1 #remainder, if not zero loop again
sub $t2,$s6,$t1 #if the difference isn't 7 we need to add more
bne $t2,7,add_more
j heap_space
add_more:
beq $t2,0,heap_space
addi $s5,$s5,1
addi $t2,$t2,-1
j add_more

heap_space:
move $a0,$s5
li $v0,9
syscall
move $s4,$v0 #address of middletext_buffer
move $t1,$s4
li $t3,0 
asterisk_loop:
beq $t3,$s5,map_plain
li $t2, '*'
sb $t2,0($t1)
addi $t1,$t1,1
addi $t3,$t3,1
j asterisk_loop
map_plain:

addi $sp,$sp,-32
sw $ra,0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)
move $a0,$s0
move $a1,$s1
move $a2,$s4
jal map_plaintext #$s4(heap address) now has ciphertext
lw $ra,0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
addi $sp,$sp,32

sort_key: 
div $s5,$s6 
mflo $s7 #number of rows also want to keep this

addi $sp,$sp,-40
sw $ra,4($sp)
sw $s0, 8($sp)
sw $s1, 12($sp)
sw $s2, 16($sp)
sw $s3, 20($sp)
sw $s4, 24($sp)
sw $s5, 28($sp)
sw $s6,32($sp)
sw $s7,36($sp)

move $a1,$s7 #num of rows
move $a0,$s4 #matrix to keysort
move $a2,$s6 #num of columns
move $a3,$s2 #key address 
#fifth argument 
li $t0,1 #elem_size
sw $t0,0($sp)
jal key_sort_matrix

lw $ra,4($sp)
lw $s0, 8($sp)
lw $s1, 12($sp)
lw $s2, 16($sp)
lw $s3, 20($sp)
lw $s4, 24($sp)
lw $s5, 28($sp)
lw $s6, 32($sp)
lw $s7, 36($sp)
addi $sp,$sp,40

transpose_cipher:

addi $sp,$sp,-36
sw $ra,0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)
sw $s7, 32($sp)

move $a0,$s4 #source
move $a1,$s3 #destination
move $a2,$s7
move $a3,$s6

jal transpose

lw $ra,0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
lw $s7, 32($sp)
addi $sp,$sp,36

move $t0,$s3
lbu $t1,0($t0)
null_loop:
beq $t1,'?',null_t
addi $t0,$t0,1
lbu $t1,0($t0)
j null_loop

null_t:
li $t1,'\0'
sb $t1,0($t0)
jr $ra

# Part VIII
lookup_char:
li $v0, -200
li $v1, -200

move $s0,$a0 #adfgvx grid
move $t1,$a1 #row char
move $t2,$a2 #col char

check_row:
beq $t1,'A',check_col
beq $t1,'D',check_col
beq $t1,'F',check_col
beq $t1,'G',check_col
beq $t1,'V',check_col
beq $t1,'X',check_col
j return_bad
check_col:
beq $t2,'A',set_char
beq $t2,'D',set_char
beq $t2,'F',set_char
beq $t2,'G',set_char
beq $t2,'V',set_char
beq $t2,'X',set_char
return_bad:
li $v0,-1
li $v1,67
jr $ra

set_char:
li $t0,0
beq $t1,'A',set_row_coord
li $t0,1
beq $t1,'D',set_row_coord
li $t0,2
beq $t1,'F',set_row_coord
li $t0,3
beq $t1,'G',set_row_coord
li $t0,4
beq $t1,'V',set_row_coord
li $t0,5
beq $t1,'X',set_row_coord
col_coord:
li $t0,0
beq $t2,'A',set_col_coord
li $t0,1
beq $t2,'D',set_col_coord
li $t0,2
beq $t2,'F',set_col_coord
li $t0,3
beq $t2,'G',set_col_coord
li $t0,4
beq $t2,'V',set_col_coord
li $t0,5
beq $t2,'X',set_col_coord

set_row_coord:
move $t1,$t0
j col_coord

set_col_coord:
move $t2,$t0

find_char:
li $t0,6
mul $t3,$t1,$t0   #(i*num of cols + j )+ src address
add $t3,$t3,$t2
add $t3,$t3,$s0
lbu $t4,0($t3)
move $v1,$t4
li $v0,0
jr $ra

# Part IX
string_sort:
li $v0, -200
li $v1, -200
move $s0,$a0 #string to sort

li $t0,-1
string_len:
addi $t0,$t0,1
add $t2,$s0,$t0
lbu $t1,0($t2)
beq $t1,'\0',bubble
j string_len

bubble:
li $t1,-1 #i
sort_outer:
addi $t1,$t1,1
beq $t1,$t0,return_result
li $t2,0 #j
sub $t3,$t0,$t2
addi $t3,$t3,-1 #n-i-1
sort_inner:
beq $t2,$t3,sort_outer
add $t4,$s0,$t2 #char at j
addi $t6,$t4,1 #char at j+1
lbu $t5,0($t4) #string[j]
lbu $t7,0($t6) #string[j+1]

bgt $t5,$t7,swap_nine
addi $t2,$t2,1 #j+1
j sort_inner

swap_nine:
sb $t5,0($t6)
sb $t7,0($t4)
addi $t2,$t2,1 #j+1
j sort_inner

return_result:
jr $ra

# Part X
decrypt:
li $v0, -200
li $v1, -200

move $s0,$a0 #adfgvx grid
move $s1,$a1 #ciphertext
move $s2,$a2 #keyword
move $s3,$a3 #plaintext

#make a heap size keyword length
addi $sp,$sp,-4
sw $s2,0($sp)

li $t0,0
lbu $t1, 0($s2)
key_size_loop:
beq $t1,'\0',allocate_heap
addi $t0,$t0,1
addi $s2,$s2,1
lbu $t1,0($s2)
j key_size_loop

allocate_heap:
lw $s2,0($sp)
addi $sp,$sp,4
move $s5,$t0 #key length
move $a0,$s5
li $v0,9
syscall
move $s4,$v0 #location of heap_key

li $t0,0
addi $sp,$sp,-4
sw $s4,0($sp)
move_to_heap_string:
beq $t0,$s5,next
add $t1,$s2,$t0
lbu $t2,0($t1)
sb $t2,0($s4)
addi $s4,$s4,1
addi $t0,$t0,1
j move_to_heap_string
next:
lw $s4,0($sp)
addi $sp,$sp,4
addi $sp,$sp,-28
sw $ra,0($sp)
sw $s0,4($sp)
sw $s1,8($sp)
sw $s2,12($sp)
sw $s3,16($sp)
sw $s4,20($sp)
sw $s5,24($sp)

move $a0,$s4
jal string_sort

lw $ra,0($sp)
lw $s0,4($sp)
lw $s1,8($sp)
lw $s2,12($sp)
lw $s3,16($sp)
lw $s4,20($sp)
lw $s5,24($sp)
addi $sp,$sp,28

move $a0,$s5
li $v0,9
syscall

move $s6,$v0 #heap_keyword_indicies

li $s7,0 #indexing for loop
addi $sp,$sp,-36
sw $ra,0($sp)
sw $s0,4($sp)
sw $s1,8($sp)
sw $s2,12($sp)
sw $s3,16($sp)
sw $s4,20($sp)
sw $s5,24($sp)
sw $s6,28($sp)
sw $s7,32($sp)

locate_position:
beq $s7,$s5,transpose_decode
lw $s4,20($sp) #sorted keyword ie the heap
lw $s2,12($sp) #original keyword
add $s4,$s4,$s7
lbu $t0,0($s4) #character
move $a0,$s2 #address
move $a1,$t0
jal index_of

move $t0,$v0 #index of the char 
sb $t0,0($s6) #s6 is heap_keyword_indicies
addi $s6,$s6,1
addi $s7,$s7,1
j locate_position

index_of:
move $t0,$a0 #address of array
move $t1,$a1 #char to find
li $t2,0 #index
lbu $t3,0($t0)
loopers:
beq $t3,'\0',return_fail
beq $t3,$t1,return_index
addi $t2,$t2,1
addi $t0,$t0,1
lbu $t3,0($t0)
j loopers
return_fail:
li $v0,-1
jr $ra
return_index:
move $v0,$t2
jr $ra

transpose_decode:
lw $ra,0($sp)
lw $s0,4($sp)#adfgvx grid, necessary
lw $s1,8($sp) #ciphertext
lw $s2,12($sp) #keyword original, not really needed
lw $s3,16($sp) #plaintext, needed
lw $s4,20($sp) #keyword sorted
lw $s5,24($sp) #length of key
lw $s6,28($sp)#heap_cipher_key
lw $s7,32($sp) #loop index, we can use this for heap cipher storage
addi $sp,$sp,36
#calculate ciphertext_length
sw $s1,0($sp)
li $t0,-1 #cipher length
cipher_text_length:
addi $t0,$t0,1
lbu $t1,0($s1)
beq $t1,'\0',divide
addi $s1,$s1,1
j cipher_text_length

divide:

#create heap space for cipher text
lw $s1,0($sp)
addi $sp,$sp,4

move $a0,$t0
li $v0,9
syscall

move $s7,$v0 #$s7 has the address for the cipherarray heap

div $t0,$s5 #divide by key length, mflo is # of rows
mflo $s2 #s2 is number of rows

addi $sp,$sp,-36
sw $ra,0($sp)
sw $s0,4($sp)
sw $s1,8($sp)
sw $s2,12($sp)
sw $s3,16($sp)
sw $s4,20($sp)
sw $s5,24($sp)
sw $s6,28($sp)
sw $s7,32($sp)

#transpose ciphertext heap
move $a0,$s1 #original src
move $a1,$s7 #destination
move $a2,$s5 #num of cols/but its rows for transposition
move $a3,$s2 #num of rows/^^^
jal transpose

#keysort the array
lw $ra,0($sp)
lw $s0,4($sp)#adfgvx grid, necessary
lw $s1,8($sp) #ciphertext
lw $s2,12($sp) #number of rows
lw $s3,16($sp) #plaintext, needed
lw $s4,20($sp) #keyword sorted
lw $s5,24($sp) #length of key ie number of cols
lw $s6,28($sp)#heap_cipher_key
lw $s7,32($sp) #heap_cipherarray
addi $sp,$sp,36

li $t0,1
addi $sp,$sp,-40
sw $t0,0($sp)
sw $ra,4($sp)
sw $s0,8($sp)
sw $s1,12($sp)
sw $s2,16($sp)
sw $s3,20($sp)
sw $s4,24($sp)
sw $s5,28($sp)
sw $s6,32($sp)
sw $s7,36($sp)

move $a0,$s7
move $a1,$s2
move $a2,$s5
move $a3,$s6
jal key_sort_matrix

lw $ra,4($sp)
lw $s0,8($sp)#adfgvx grid, necessary
lw $s1,12($sp) #ciphertext
lw $s2,16($sp) #keyword original, not really needed
lw $s3,20($sp) #plaintext, needed
lw $s4,24($sp) #keyword sorted
lw $s5,28($sp) #length of key
lw $s6,32($sp)#heap_cipher_key
lw $s7,36($sp) #heap_cipherarray
addi $sp,$sp,40

addi $sp,$sp,-12
sw $ra,0($sp)
sw $s7,4($sp)
sw $s3,8($sp)

lbu $t0,0($s7) 
lbu $t1,1($s7)

derive_plaintext:
beq $t0,'*',null_decode
move $a0,$s0
move $a1,$t0
move $a2,$t1
jal lookup_char
sb $v1,0($s3)#store to plaintext the result
addi $s3,$s3,1
addi $s7,$s7,2
lbu $t0,0($s7)
lbu $t1,1($s7)
j derive_plaintext

null_decode:
li $t0,'\0'
sb $t0,0($s3)

lw $ra,0($sp)
lw $s7,4($sp)
lw $s3,8($sp)
addi $sp,$sp,12        
jr $ra       
#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
