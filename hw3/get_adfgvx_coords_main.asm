.text
.globl main
main:
li $a0, 5
li $a1, 3
jal get_adfgvx_coords

move $a0, $v0

beq $a0,-1,print_int
li $v0, 11
j print

print_int:
li $v0,1
syscall
li $a0, ' '
li $v0,11
syscall
move $a0, $v1
li $v0,1
syscall
li $v0,11
li $a0, '\n'
syscall
j exit

print:
syscall
li $a0, ' '
syscall
move $a0, $v1
syscall
li $a0, '\n'
syscall

exit:
li $v0, 10
syscall

.include "hw3.asm"
