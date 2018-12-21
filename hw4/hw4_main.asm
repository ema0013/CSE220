.data
map_filename: .asciiz "map3.txt"
# num words for map: 45 = (num_rows * num_cols + 2) // 4 
# map is random garbage initially
.asciiz "Don't touch this region of memory"
map: .word 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 
.asciiz "Don't touch this"
# player struct is random garbage initially
player: .word 0x2912FECD
.asciiz "Don't touch this either"
# visited[][] bit vector will always be initialized with all zeroes
# num words for visited: 6 = (num_rows * num*cols) // 32 + 1
visited: .word 0 0 0 0 0 0 
.asciiz "Really, please don't mess with this string"

welcome_msg: .asciiz "Welcome to MipsHack! Prepare for adventure!\n"
pos_str: .asciiz "Pos=["
health_str: .asciiz "] Health=["
coins_str: .asciiz "] Coins=["
your_move_str: .asciiz " Your Move: "
you_won_str: .asciiz "Congratulations! You have defeated your enemies and escaped with great riches!\n"
you_died_str: .asciiz "You died!\n"
you_failed_str: .asciiz "You have failed in your quest!\n"

.text
print_map:
la $t0, map  # the function does not need to take arguments
lbu $t1,0($t0)#number of rows
lbu $t2,1($t0)#umber of cols
addi $t0,$t0,2
li $t3,-1 #curr row
loop:
addi $t3,$t3,1
beq $t3,$t1,done_print
li $t4,0 #curr col
inner_loop:
beq $t4,$t2,print_nl
lbu $t5,0($t0)
srl $t6,$t5,7
beq $t6,1,print_space
move $a0,$t5
li $v0,11
syscall
#next character
addi $t0,$t0,1
addi $t4,$t4,1
j inner_loop
print_nl:
li $a0,'\n'
li $v0,11
syscall
j loop
print_space:
li $a0,' '
li $v0,11
syscall
#next character
addi $t0,$t0,1
addi $t4,$t4,1
j inner_loop
done_print:
jr $ra

print_player_info:
# the idea: print something like "Pos=[3,14] Health=[4] Coins=[1]"
la $t0, player
la $a0,pos_str
li $v0,4
syscall
lbu $t1,0($t0)
li $v0,1
move $a0,$t1
syscall
li $a0,','
li $v0,11
syscall
lbu $t1,1($t0)
move $a0,$t1
li $v0,1
syscall
la $a0,health_str
li $v0,4
syscall
lb $t1,2($t0)
move $a0,$t1
li $v0,1
syscall
la $a0,coins_str
li $v0,4
syscall
lbu $t1,3($t0)
move $a0,$t1
li $v0,1
syscall
li $a0,']'
li $v0,11
syscall
li $a0,'\n'
syscall
jr $ra


.globl main
main:
la $a0, welcome_msg
li $v0, 4
syscall

# fill in arguments
la $a0, map_filename
la $a1,map
la $a2,player
jal init_game

# fill in arguments
la $a0,map
la $t0,player
lbu $a1,0($t0)
lbu $a2,1($t0)
jal reveal_area

li $s0, 0  # move = 0

game_loop:  # while player is not dead and move == 0:
la $t0,player
lb $t1,2($t0)
ble $t1,0,game_over

jal print_map # takes no args

jal print_player_info # takes no args

# print prompt
la $a0, your_move_str
li $v0, 4
syscall

li $v0, 12  # read character from keyboard
syscall
move $s1, $v0  # $s1 has character entered
li $s0, 0  # move = 0

li $a0, '\n'
li $v0 11
syscall

# handle input: w, a, s or d
# map w, a, s, d  to  U, L, D, R and call player_turn()
beq $s1,'w',mapU
beq $s1,'s',mapD
beq $s1,'a',mapL
beq $s1,'d',mapR
beq $s1,'r',call_reveal

call_reveal:
la $a0,map
la $t0,player
lbu $t1,0($t0)
lbu $t2,1($t0)
move $a1,$t1
move $a2,$t2
la $a3,visited
jal flood_fill_reveal
j game_loop

# if move == 0, call reveal_area()  Otherwise, exit the loop.
mapU:
li $a2,'U'
la $a0,map
la $a1,player
jal player_turn
#reveal area
j reveal_main
mapD:
li $a2,'D'
la $a0,map
la $a1,player
jal player_turn
#reveal area
j reveal_main
mapL:
li $a2,'L'
la $a0,map
la $a1,player
jal player_turn
j reveal_main
mapR:
li $a2,'R'
la $a0,map
la $a1,player
jal player_turn
j reveal_main
reveal_main:
#reveal area
la $a0,map
la $t0,player
lbu $a1,0($t0)
lbu $a2,1($t0)
jal reveal_area
j game_loop

game_over:
jal print_map
jal print_player_info
li $a0, '\n'
li $v0, 11
syscall

# choose between (1) player dead, (2) player escaped but lost, (3) player escaped and won

won:
la $a0, you_won_str
li $v0, 4
syscall
j exit

failed:
la $a0, you_failed_str
li $v0, 4
syscall
j exit

player_dead:
la $a0, you_died_str
li $v0, 4
syscall

exit:
li $v0, 10
syscall

.include "hw4.asm"
