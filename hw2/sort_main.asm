.include "sort_data.asm"
.include "hw2.asm"

.data
nl: .asciiz "\n"
sort_output: .asciiz  "sort output: "

.text
.globl main
main:
la $a0, sort_output
li $v0, 4
syscall
la $a0, all_cars
li $a1, 12
jal sort
move $a0, $v0
li $v0, 1
syscall
la $a0, nl
li $v0, 4
syscall

li $t0,0
la $s0,all_cars
print_cars_arr:
	beq $t0,12,exit_print
	
	lw $a0,0($s0)
	li $v0,4
	syscall
	addi $s0,$s0,4
	lw $a0,0($s0)
	li $v0,4
	syscall
	addi $s0,$s0,4
	lw $a0,0($s0)
	li $v0,4
	syscall
	addi $s0,$s0,4
	lh $a0,0($s0) 
	li $v0,1
	syscall
	addi $s0,$s0,4
	la $a0,nl
	li $v0,4
	syscall
	
	addi $t0,$t0,1
	j print_cars_arr
exit_print:
	la $a0, nl
	li $v0, 4
	syscall

li $v0, 10
syscall
