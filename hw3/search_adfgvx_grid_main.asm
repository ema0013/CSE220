.data
adfgvx_grid: .asciiz "IQSP4TONLZJUGACHXVE73WKY5MB126980FRD"
# QWE3RT0YU2IO4PLK9J1HGF5DSAZ86XCVB7NM
.text
.globl main
main:
la $a0, adfgvx_grid
li $a1, 'O'
jal search_adfgvx_grid

move $a0, $v0
li $v0, 1
syscall
li $a0, ' '
li $v0, 11
syscall
move $a0, $v1
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "hw3.asm"
