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
init_game:
move $t0,$a0 #map filename
move $t3,$a1 #map pointer
move $t4,$a2 #player pointer
#syscall 13 to read file
move $a0,$t0
li $v0,13
li $a1,0 #read only
li $a2,0 
syscall
move $t5,$v0 #file descriptor saved
#allocate stack space
addi $sp,$sp,-2 
move $a0,$t5
move $a1,$sp
li $a2,2 #read two chars
li $v0,14 
syscall
lb $t0,0($sp)
addi $t0,$t0,-48
li $t1,10
mul $t0,$t0,$t1
lb $t1,1($sp)
addi $t1,$t1,-48
add $t0,$t0,$t1 #rows
sb $t0,0($t3) #save to first byte of map struct
addi $sp,$sp,2
addi $sp,$sp,-4
move $a0,$t5
move $a1,$sp
li $a2,4 #read 3 chars
li $v0,14 
syscall
lb $t0,1($sp)
addi $t0,$t0,-48
li $t1,10
mul $t0,$t0,$t1
lb $t1,2($sp)
addi $t1,$t1,-48
add $t0,$t0,$t1 #cols
sb $t0,1($t3) #byte 1 is now cols
addi $sp,$sp,4
lbu $t0,0($t3)
lbu $t1,1($t3)
mul $t0,$t1,$t0 #row * col
addi $t3,$t3,2#map pointer
li $t2,-1 #counter
#need registers for current row and current column
li $t6,0 #curr row
li $t7, 0 #curr column
map_loop:
addi $t2,$t2,1
beq $t2,$t0,done
addi $sp,$sp,-1
move $a0,$t5 #file descriptor
move $a1,$sp #input buffer
li $a2,1 #read one character
li $v0,14
syscall
lbu $t1,0($sp)#load the byte just read
beq $t1,'\n',new_row #if end of row, next row
beq $t1,'@',init_player#initialize player coord
li $t8,0x80
or $t1,$t1,$t8
sb $t1,0($t3)
addi $t7,$t7,1
addi $t3,$t3,1
addi $sp,$sp,1
j map_loop
new_row:
addi $t6,$t6,1 #cur row +1
li $t7,0 #reset the curr col to 0
addi $sp,$sp,1
addi $t2,$t2,-1 #compensate for overadding
j map_loop
init_player:
#$t2 is the player pointer
sb $t6,0($t4)#row of player
sb $t7,1($t4)#col of player
li $t8,0x80
or $t1,$t1,$t8
sb $t1,0($t3)
addi $t7,$t7,1 
addi $t3,$t3,1
addi $sp,$sp,1
j map_loop
done:
#read starting health of player
addi $sp,$sp,-3
move $a0,$t5
move $a1,$sp
li $a2,5
li $v0,14
syscall

lbu $t0,1($sp)
addi $t0,$t0,-48
li $t1,10
mul $t0,$t0,$t1
lbu $t1,2($sp)
addi $t1,$t1,-48
add $t0,$t0,$t1 #player health
sb $t0,2($t4)
li $t0,0
sb $t0,3($t4)#starting gold
addi $sp,$sp,3
#close file
move $a0,$t5
li $v0,16
syscall
jr $ra

# Part II
is_valid_cell:
move $t0,$a0 #map pointer address
move $t1,$a1 #row
move $t2,$a2 #col
lbu $t3,0($t0)

bge $t1,$t3,error_2
blt $t1,0,error_2
lbu $t3,1($t0)

bge $t2,$t3,error_2
blt $t2,0,error_2
li $v0,0
jr $ra
error_2:
li $v0,-1
jr $ra

# Part III
get_cell:
#already should come with a0,a1,a2 similar to is_valid_cell
addi $sp,$sp,-4
sw $ra,0($sp)
jal is_valid_cell
lw $ra,0($sp)
addi,$sp,$sp,4
beq $v0,0,get_cell_math #returns either -1 or 0
jr $ra
get_cell_math:
move $t0,$a0 #map pointer
move $t1,$a1 #row
move $t2,$a2 #col
lbu $t3,1($t0)#num of columns
addi $t0,$t0,2 #we don't need the first two bytes
mul $t1,$t3,$t1 #row*number of columns
add $t1,$t1,$t2 #row*number of columns + col 
add $t0,$t0,$t1 #add to address
lbu $t3,0($t0)
move $v0,$t3 #the character at [row][col]
jr $ra

# Part IV
set_cell:
#a0,a1,a2 are the same inputs for is_valid_cell
addi $sp,$sp,-4
sw $ra,0($sp)
jal is_valid_cell
lw $ra,0($sp)
addi $sp,$sp,4
beq $v0,0,set_cell_math
jr $ra
set_cell_math:
move $t0,$a0 #map pointer
move $t1,$a1 #row
move $t2,$a2 #col
move $t4,$a3 #character to set
lbu $t3,1($t0)#num of columns
addi $t0,$t0,2 #we don't need the first two bytes
mul $t1,$t3,$t1
add $t1,$t1,$t2
add $t0,$t0,$t1
sb $t4,0($t0)
li $v0,0
jr $ra

# Part V
reveal_area:
addi $sp,$sp,-24
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $ra,20($sp)

move $s0,$a0 #address of map pointer
move $s1,$a1 #original row
move $s2,$a2 #orignal col
#initially call is_valid_cell
jal is_valid_cell
#do nothing with the result???
addi $s1,$s1,-2 #leftmost corner of the 3x3
addi $s2,$s2,-1
li $s3,-1 #row counter
reveal_loop:
addi $s1,$s1,1 #next row
addi $s3,$s3,1 
beq $s3,3,finish_reveal
li $s4,-1 #col counter
reveal_loop_inner:
addi $s4,$s4,1
beq $s4,3,reveal_loop_next
#call get_cell
move $a0,$s0
move $a1,$s1
move $a2,$s2
jal get_cell
move $t0,$v0
beq $t0,-1,invalid_reveal
andi $t0,$t0,0x7F
move $a0,$s0
move $a1,$s1
move $a2,$s2
move $a3,$t0
jal set_cell
invalid_reveal:
addi $s2,$s2,1 #next col
j reveal_loop_inner
reveal_loop_next:
#reset $s2 to inital
addi $s2,$s2,-3
j reveal_loop
finish_reveal:
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $ra,20($sp)
addi $sp,$sp,24
jr $ra

# Part VI
get_attack_target:
#map pointer, player pointer and character direction
move $t0,$a0
move $t1,$a1
move $t2,$a2
check_direction:
addi $sp,$sp,-4
sw $ra,0($sp)
beq $t2,'U',check_targetU
beq $t2,'D',check_targetD
beq $t2,'L',check_targetL
beq $t2,'R',check_targetR
error_6:
lw $ra,0($sp)
addi $sp,$sp,4
li $v0,-1
jr $ra
check_targetU:
lbu $t3,0($t1) #player row-1
addi $t3,$t3,-1 
lbu $t4,1($t1) #player col

move $a0,$t0
move $a1,$t3
move $a2,$t4
jal get_cell
move $t0,$v0 #cell content
j check_cell6
check_targetR:
lbu $t3,0($t1) #player row
lbu $t4,1($t1) #player col+1
addi $t4,$t4,1 

move $a0,$t0
move $a1,$t3
move $a2,$t4
jal get_cell
move $t0,$v0 #cell content
j check_cell6
check_targetD:
lbu $t3,0($t1) #player row+1
addi $t3,$t3,1
lbu $t4,1($t1) #player col

move $a0,$t0
move $a1,$t3
move $a2,$t4
jal get_cell
move $t0,$v0 #cell content
j check_cell6
check_targetL:
lbu $t3,0($t1) #player row
lbu $t4,1($t1) #player col-1
addi $t4,$t4,-1 

move $a0,$t0
move $a1,$t3
move $a2,$t4
jal get_cell
move $t0,$v0 #cell content
j check_cell6
check_cell6:

beq $t0,-1,error_6
beq $t0,'B',return_result
beq $t0,'m',return_result
beq $t0,'/',return_result
j error_6
return_result:
lw $ra,0($sp)
addi $sp,$sp,4
move $v0,$t0
jr $ra

# Part VII
complete_attack:
#map pointer, player pointer, tar row, tar col
#get character at target coord
addi $sp,$sp,-20
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $ra,16($sp)

move $s0,$a0
move $s1,$a1
move $s2,$a2
move $s3,$a3

move $a0,$s0
move $a1,$s2
move $a2,$s3
jal get_cell
#assumed target is valid character
move $t0,$v0
beq $t0,'m',mon
beq $t0,'B',boss
beq $t0,'/',door
mon:
li $t0,'$'
move $a0,$s0
move $a1,$s2
move $a2,$s3 
move $a3,$t0
jal set_cell

lb $t0,2($s1) #change health
addi $t0,$t0,-1
sb $t0,2($s1)
j check_hero7
boss:
li $t0,'*'
move $a0,$s0
move $a1,$s2
move $a2,$s3 
move $a3,$t0
jal set_cell

lb $t0,2($s1) #change health
addi $t0,$t0,-2
sb $t0,2($s1)
j check_hero7
door:
li $t0,'.'
move $a0,$s0
move $a1,$s2
move $a2,$s3 
move $a3,$t0
jal set_cell
j check_hero7
check_hero7:
lb $t0,2($s1)
bgt $t0,0,return7
#heros is dead
lbu $t0,0($s2)
lbu $t1,1($s2)
li $t2,'X'
move $a0,$s0
move $a1,$t0
move $a2,$t1
move $a3,$t2
jal set_cell
return7:
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $ra,16($sp)
addi $sp,$sp,20
jr $ra

# Part VIII
monster_attacks:
#map pointer,player pointer
addi $sp,$sp,-16
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $ra,12($sp)

move $s0,$a0
move $s1,$a1
li $s2,0 #counter for total damage
up8:
lbu $t0,0($s1)
addi $t0,$t0,-1
lbu $t1,1($s1)
move $a0,$s0
move $a1,$t0
move $a2,$t1
jal get_cell
move $t0,$v0
beq $t0,'m',addmonU
beq $t0,'B',addBossU
down8:
lbu $t0,0($s1)
addi $t0,$t0,1
lbu $t1,1($s1)
move $a0,$s0
move $a1,$t0
move $a2,$t1
jal get_cell
move $t0,$v0
beq $t0,'m',addmonD
beq $t0,'B',addBossD
left8:
lbu $t0,0($s1)
lbu $t1,1($s1)
addi $t1,$t1,-1
move $a0,$s0
move $a1,$t0
move $a2,$t1
jal get_cell
move $t0,$v0
beq $t0,'m',addmonL
beq $t0,'B',addBossL
right8:
lbu $t0,0($s1)
lbu $t1,1($s1)
addi $t1,$t1,1
move $a0,$s0
move $a1,$t0
move $a2,$t1
jal get_cell
move $t0,$v0
beq $t0,'m',addmonR
beq $t0,'B',addBossR
return8:

move $v0,$s2
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $ra,12($sp)
addi $sp,$sp,16
jr $ra
addmonU:
addi $s2,$s2,1
j down8
addBossU:
addi $s2,$s2,2
j down8
addmonD:
addi $s2,$s2,1
j left8
addBossD:
addi $s2,$s2,2
j left8
addmonL:
addi $s2,$s2,1
j right8
addBossL:
addi $s2,$s2,2
j right8
addmonR:
addi $s2,$s2,1
j return8
addBossR:
addi $s2,$s2,2
j return8

# Part IX
player_move:
#call monster_attacks
addi $sp,$sp,-20
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $ra,16($sp)
move $s0,$a0
move $s1,$a1
move $s2,$a2
move $s3,$a3

move $a0,$s0
move $a1,$s1
jal monster_attacks
move $t0,$v0
lb $t1,2($s1)
sub $t1,$t1,$t0
sb $t1,2($s1)
bgt $t1,0,move9#player still alive
li $t0,'X'
lbu $t1,0($s1)
lbu $t2,1($s1)
move $a0,$s0
move $a1,$t1
move $a2,$t2
move $a3,$t0
jal set_cell
done_9:
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $ra,16($sp)
addi $sp,$sp,20
li $v0,0 #done successful move
jr $ra
move9:
#get cell of target
move $a0,$s0
move $a1,$s2
move $a2,$s3
jal get_cell
#cell contents
beq $v0,'.',movedot
beq $v0,'$',movecoin
beq $v0,'*',movejewel
#content is exit otherwise
li $t0,'.'
lbu $t1,0($s1)
lbu $t2,1($s1)
move $a0,$s0
move $a1,$t1
move $a2,$t2
move $a3,$t0
jal set_cell#curr pos is now a .
li $t0,'@'
move $a0,$s0
move $a1,$s2
move $a2,$s3
move $a3,$t0
jal set_cell #set target to player
sb $s2,0($s1)#new row and col
sb $s3,1($s1)
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $ra,16($sp)
addi $sp,$sp,20
li $v0,-1
jr $ra
movecoin:
#player money +1
lbu $t0,3($s1)
addi $t0,$t0,1
sb $t0,3($s1)
j movedot
movedot:
li $t0,'.'
lbu $t1,0($s1)
lbu $t2,1($s1)
move $a0,$s0
move $a1,$t1
move $a2,$t2
move $a3,$t0
jal set_cell#curr pos is now a .
li $t0,'@'
move $a0,$s0
move $a1,$s2
move $a2,$s3
move $a3,$t0
jal set_cell #set targetcell to player icon
sb $s2,0($s1)#new row and col
sb $s3,1($s1)
j done_9
movejewel:
#player money +5
lbu $t0,3($s1)
addi $t0,$t0,5
sb $t0,3($s1)
j movedot

# Part X
player_turn:
#map pointer,player pointer,direction
#check direction is ok
beq $a2,'U',valid_index
beq $a2,'D',valid_index
beq $a2,'L',valid_index
beq $a2,'R',valid_index
#assume here not valid direction
li $v0,-1
jr $ra
valid_index:
addi $sp,$sp,-24
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)#target row
sw $s4,16($sp)#target col
sw $ra,20($sp)

move $s0,$a0
move $s1,$a1
move $s2,$a2

beq $s2,'U',valid_up_10
beq $s2,'D',valid_down_10
beq $s2,'L',valid_left_10
beq $s2,'R',valid_right_10
valid_up_10:
lbu $t0,0($s1)
addi $t0,$t0,-1
lbu $t1,1($s1)
add $s3,$s3,$t0
add $s4,$s4,$t1

move $a0,$s0
move $a1,$s3
move $a2,$s4
jal is_valid_cell
beq $v0,-1,bad_index
j next_10
valid_down_10:
lbu $t0,0($s1)
addi $t0,$t0,1
lbu $t1,1($s1)
add $s3,$s3,$t0
add $s4,$s4,$t1

move $a0,$s0
move $a1,$s3
move $a2,$s4
jal is_valid_cell
beq $v0,-1,bad_index
j next_10
valid_left_10:
lbu $t0,0($s1)
lbu $t1,1($s1)
addi $t1,$t1,-1
add $s3,$s3,$t0
add $s4,$s4,$t1

move $a0,$s0
move $a1,$s3
move $a2,$s4
jal is_valid_cell
beq $v0,-1,bad_index
j next_10
valid_right_10:
lbu $t0,0($s1)
lbu $t1,1($s1)
addi $t1,$t1,1
add $s3,$s3,$t0
add $s4,$s4,$t1

move $a0,$s0
move $a1,$s3
move $a2,$s4
jal is_valid_cell
beq $v0,-1,bad_index
j next_10
bad_index:
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)#target row
lw $s4,16($sp)#target col
lw $ra,20($sp)
addi $sp,$sp,24
li $v0,0
jr $ra

next_10:
#get_cell

move $a0,$s0
move $a1,$s3
move $a2,$s4
jal get_cell
bne $v0,'#',call_attack
j bad_index
call_attack:
#call get attack target
move $a0,$s0
move $a1,$s1
move $a2,$s2
jal get_attack_target
beq $v0,-1,move_player10
#call attack
move $a0,$s0
move $a1,$s1
move $a2,$s3
move $a3,$s4
jal complete_attack
li $v0,0
j succ_10
move_player10:
#move player
move $a0,$s0
move $a1,$s1
move $a2,$s3
move $a3,$s4
jal player_move
#keep $v0 as is
succ_10:
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)#target row
lw $s4,16($sp)#target col
lw $ra,20($sp)
addi $sp,$sp,24
jr $ra

# Part XI
flood_fill_reveal:
#map pointer, row,col,bit[][]visited
addi $sp,$sp,-20
sw $s0,0($sp) #map pointer
sw $s1,4($sp) #visited[][]
sw $s2,8($sp) #row placeholder
sw $s3,12($sp)#col placeholder 
sw $ra,16($sp)

move $s0,$a0 
move $s1,$a3
move $s2,$a1 #row
move $s3,$a2 #col

move $a0,$s0
move $a1,$s2
move $a2,$s3 
jal is_valid_cell
beq $v0,-1,error_11

move $t0,$s2
move $t1,$s3

#fp = sp
move $fp,$sp

#push row and col onto sp
addi $sp,$sp,-8
sw $t0,0($sp)
sw $t1,4($sp)

while_11:
beq $sp,$fp,complete_11
lw $t0,0($sp) #row
lw $t1,4($sp) #col
addi $sp,$sp,8 #pop
move $s2,$t0 #row
move $s3,$t1 #col
#make that coord visible
move $a0,$s0
move $a1,$s2
move $a2,$s3
jal get_cell
move $t0,$v0
andi $t0,$t0,0x7F
move $a0,$s0
move $a1,$s2
move $a2,$s3
move $a3,$t0
jal set_cell
#for up,down,left,and right of curr cell
up_11:
addi $s2,$s2,-1 #row-1

move $a0,$s0
move $a1,$s2
move $a2,$s3
jal get_cell
beq $v0,'.',is_visited_up
j down_11
down_11:
addi $s2,$s2,2 #row+1

move $a0,$s0
move $a1,$s2
move $a2,$s3
jal get_cell
beq $v0,'.',is_visited_down
j left_11
left_11:
addi $s2,$s2,-1 #row
addi $s3,$s3,-1 #col-1

move $a0,$s0
move $a1,$s2
move $a2,$s3
jal get_cell
beq $v0,'.',is_visited_left
j right_11
right_11:
addi $s3,$s3,2 #col+1

move $a0,$s0
move $a1,$s2
move $a2,$s3
jal get_cell
beq $v0,'.',is_visited_right
j while_11

is_visited_up:
lbu $t2,1($s0) #num cols
mul $t2,$t2,$s2
add $t2,$t2,$s3
li $t3,32
div $t2,$t3
mfhi $t4 #bit%32
mflo $t5 #offset
li $t6,4
mul $t5,$t5,$t6
add $t2,$s1,$t5
lw $t5,0($t2)#word to look at
addi $t3,$t3,-1
sub $t6,$t3,$t4 #31-mod
sllv $t7,$t5,$t6
srl $t7,$t7,31

beq $t7,1,down_11
#not visited

li $t6,1
sllv $t6,$t6,$t4
or $t5,$t5,$t6
sw $t5,0($t2)
move $t0,$s2
move $t1,$s3
addi $sp,$sp,-8
sw $t0,0($sp)
sw $t1,4($sp)
j down_11
is_visited_down:
lbu $t2,1($s0) #num cols
mul $t2,$t2,$s2
add $t2,$t2,$s3
li $t3,32
div $t2,$t3
mfhi $t4 #bit%32
mflo $t5 #offset
li $t6,4
mul $t5,$t5,$t6
add $t2,$s1,$t5
lw $t5,0($t2)#word to look at
addi $t3,$t3,-1
sub $t6,$t3,$t4 #31-mod
sllv $t7,$t5,$t6
srl $t7,$t7,31

beq $t7,1,left_11
#not visited

li $t6,1
sllv $t6,$t6,$t4
or $t5,$t5,$t6
sw $t5,0($t2)
move $t0,$s2
move $t1,$s3
addi $sp,$sp,-8
sw $t0,0($sp)
sw $t1,4($sp)
j left_11
is_visited_left:
lbu $t2,1($s0) #num cols
mul $t2,$t2,$s2
add $t2,$t2,$s3
li $t3,32
div $t2,$t3
mfhi $t4 #bit%32
mflo $t5 #offset
li $t6,4
mul $t5,$t5,$t6
add $t2,$s1,$t5
lw $t5,0($t2)#word to look at
addi $t3,$t3,-1
sub $t6,$t3,$t4 #31-mod
sllv $t7,$t5,$t6
srl $t7,$t7,31

beq $t7,1,right_11
#not visited

li $t6,1
sllv $t6,$t6,$t4
or $t5,$t5,$t6
sw $t5,0($t2)
move $t0,$s2
move $t1,$s3
addi $sp,$sp,-8
sw $t0,0($sp)
sw $t1,4($sp)
j right_11
is_visited_right:
lbu $t2,1($s0) #num cols
mul $t2,$t2,$s2
add $t2,$t2,$s3
li $t3,32
div $t2,$t3
mfhi $t4 #bit%32
mflo $t5 #offset
li $t6,4
mul $t5,$t5,$t6
add $t2,$s1,$t5
lw $t5,0($t2)#word to look at
addi $t3,$t3,-1
sub $t6,$t3,$t4 #31-mod
sllv $t7,$t5,$t6
srl $t7,$t7,31

beq $t7,1,while_11
#not visited

li $t6,1
sllv $t6,$t6,$t4
or $t5,$t5,$t6
sw $t5,0($t2)
move $t0,$s2
move $t1,$s3
addi $sp,$sp,-8
sw $t0,0($sp)
sw $t1,4($sp)
j while_11

complete_11:
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $ra,16($sp)
addi $sp,$sp,20
li $v0,0

jr $ra
error_11:
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $ra,16($sp)
addi $sp,$sp,20
jr $ra

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
