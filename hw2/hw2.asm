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

### Part I ###
index_of_car:
##a0 is cars array,a1 is length,a2 is start index,a3 is year
	li $v0, -200 #output
	li $v1, -200
	ble $a1,0,return_error
	blt $a2,0,return_error
	bge $a2,$a1,return_error
	blt $a3,1885,return_error
	
	addi $t0,$a1,0 #set t0 to length
	addi $t1,$a2,0 #set t1 to start
	addi $t3,$a0,0 #set t3 to address
	li $t2,0
#start address is t1 times 16, since each car is 16 bytes
start_adr_loop:
	beq $t1,$t2,loop
        addi $t3,$t3,16
        addi $t2,$t2,1
	j start_adr_loop
loop:
        beq $t0,$t1,return_error
	addi $t3,$t3,12 #add 12 to address, since the year should be byte 12
	lh $t4,0($t3) #load year
	beq $a3,$t4,loop_done
	addi $t1,$t1,1
	addi $t3,$t3,4
	j loop
loop_done:
	move $v0,$t1 #move t1 to v0 for output
	jr $ra	
return_error:
	li $v0, -1
	jr $ra
### Part II ###
strcmp:
	li $v0, -200
	li $v1, -200
	addi $t0,$a0,0 #set t0 to str1 address
	addi $t1,$a1,0 #set t1 to str2 address
	li $t2,0 #length of string if one of them is empty
	lb $t4, 0($t0)#first letter of str1
	lb $t5, 0($t1)#first letter of str2
	beq $t4,'\0',str1_empty
	beq $t5,'\0',str2_empty
	
strloop:
	seq $t3,$t4,$t5 #are t4 and t5 equal then t3 is 1
	li $t6, '\0'
	seq $t7,$t4,$t6 #if t4 is equal to empty string
	and $t3,$t3,$t7 #are they equal and empty
	beq $t3,1,comp_done
	bne $t4,$t5,not_equal	
	addi $t0,$t0,1#offset str1
	addi $t1,$t1,1#offset str2
	lb $t4, 0($t0)#next letter of str1
	lb $t5, 0($t1)#next letter of str2
	j strloop
comp_done:
	li $v0,0
	jr $ra
not_equal:
	sub $t4,$t4,$t5
	move $v0,$t4
	jr $ra
str1_empty:
	bne $t4,$t5,str2_length #str2 is not empty
	#if we reached here assume the strings are equal
	li $v0,0
	jr $ra
str2_length:
	beq $t5,'\0',return_size
	addi $t2,$t2,-1
	addi $t1,$t1,1
	lb $t5, 0($t1)
	j str2_length
str2_empty:
	#if we reached here assume str1 is not empty
	beq $t4,'\0',return_size
	addi $t2,$t2,1
	addi $t0,$t0,1
	lb $t4, 0($t0)
	j str2_empty
	
return_size:
	move $v0,$t2	
	jr $ra
### Part III ###
memcpy:
	li $v0, -200
	li $v1, -200
	ble $a2,0,error_output
	move $t0,$a2 #set t0 to the number of bytes to copy
	move $t1,$a1 #address of dest
	move $t2,$a0 #address of src
	li $t3,0 #counter
	lbu $t4,0($t2)
copy:
	beq $t3,$t0,done_copy
	sb $t4, 0($t1) #copy onto the position
	addi $t1,$t1,1
	addi $t2,$t2,1
	lbu $t4,0($t2)
	addi $t3,$t3,1
	j copy
done_copy:
	li $v0,0
	jr $ra
error_output:
	li $v0,-1
	jr $ra

### Part IV ###
insert_car:
	li $v0, -200
	li $v1, -200
	blt $a1,0,return_error_car
	blt $a3,0,return_error_car
	bgt $a3,$a1,return_error_car
	move $s0,$a0 #address of car array
	move $s1,$a1 #length of array
	move $s2,$a2 #car to insert
	move $s3,$a3 #index to insert
	li $t0, 16 # for multiplication
	mul $t1,$t0,$s1 
	add $t1,$s0,$t1 #last position in car array
	addi $t2,$t1,-16 #second to last position in car array
	move $t0, $s1 #indexing array
back_loop:
	beq $t0,$s3,insert
	addi $sp,$sp,-32
	sw $ra,0($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $s2,12($sp)
	sw $s3,16($sp)
	sw $t0,20($sp)
	sw $t1,24($sp)
	sw $t2,28($sp)
	
	move $a0,$t2 #source
	move $a1,$t1 #dest
	li $a2,16 #how many bytes
	jal memcpy
 	
 	lw $ra,0($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $s2,12($sp)
	lw $s3,16($sp)
	lw $t0,20($sp)
	lw $t1,24($sp)
	lw $t2,28($sp)
	addi $sp,$sp,32 #restore constants
	
	addi $t0,$t0,-1 #subtract from index
	addi $t1,$t1,-16
	addi $t2,$t2,-16 #adjust the addresses for shifting by one element
	j back_loop
insert:
	addi $sp,$sp,-32
	sw $ra,0($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $s2,12($sp)
	sw $s3,16($sp)
	sw $t0,20($sp)
	sw $t1,24($sp)
	sw $t2,28($sp)
	
	move $a0,$s2 #source
	move $a1,$t1 #dest
	li $a2,16 #how many bytes
	jal memcpy
 	
 	lw $ra,0($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $s2,12($sp)
	lw $s3,16($sp)
	lw $t0,20($sp)
	lw $t1,24($sp)
	lw $t2,28($sp)
	addi $sp,$sp,32 #restore constants
	
	li $v0,0
	jr $ra
return_error_car:
	li $v0, -1
	jr $ra	
### Part V ###
most_damaged:
	li $v0, -200
	li $v1, -200
	ble $a2,0,error_return
	ble $a3,0,error_return
	move $s0,$a0	#car array
	move $s1,$a1    #repair array
	move $s2,$a2
	move $s3,$a3
	li $s4, 0 #tracking highest index
	li $s5, 0 #tracking highest repair cost
	li $s6,0 #tracking index
cars_loop:
	beq $s6,$s2,return_highest 
	addi $sp,$sp,-32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $ra, 28($sp)
	
	lw $t0, 0($s0) #load car vin for comparisons
	li $t1,1 #for indexing through repairs array
	li $t6,0 #reset t6 to 0
	jal repairs_loop
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $ra, 28($sp)
	addi $sp,$sp,32
	
	move $s5,$t5 #move highest index and higest repair cost
	move $s4,$t4 #highest cost
	addi $s6,$s6,1 #move to next index
	addi $s0,$s0,16 #move to next car 
	j cars_loop
repairs_loop:
	beq $t1,$s3,current_high
	lw $t2, 0($s1)
	lw $t2, 0($t2) #repair vin 
	addi $t1,$t1,1 #next index
	lh $t3,8($s1) #cost of current repair
	addi $s1,$s1,12 #next repair address
	bne $t2,$t0,repairs_loop
	
	add $t6,$t6,$t3 #add cost to sum     
	j repairs_loop
current_high:
	bgt $t6,$s5,change_high
	ble $t6,$s5,same_high
change_high:
	move $t4,$s6 
	move $t5,$t6
	jr $ra
same_high:
	move $t4,$s4
	move $t5,$s5
	jr $ra
return_highest:
	move $v0,$s4
	move $v1,$s5
	jr $ra
error_return:
	li $v0,-1
	li $v1,-1
	jr $ra

### Part VI ###
sort:
	li $v0, -200
	li $v1, -200
	ble $a1,0,return_error
	move $s0,$a0 #address of car array
	move $s1,$a1 #length of car array
	li $t0, 0 #for true or false
	
sort_stub:
	bne $t0,0,return #while statement
	addi $sp,$sp,-12
	sw $s0,0($sp) 
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	li $t0,1 #set s1 to true
	
	li $t1, 1 #start index
	addi $s0,$s0,16 #start at first car
	addi $s1,$s1,-1
	jal sort_sub
	
	lw $s0,0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp,$sp,12
	#restore the values 
	addi $sp,$sp,-12
	sw $s0,0($sp) 
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	li $t1,0 #start index
	addi $s1,$s1,-1
	jal sort_sub
	
	lw $s0,0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp,$sp,12
	
	j sort_stub
sort_sub:
	bge $t1,$s1,back
	addi $sp,$sp,-4
	sw $ra, 16($sp)
	
	lh $t2,12($s0) #load the year of current car
	lh $t3,28($s0) #load the year of next car
	bgt $t2,$t3,swap
	addi $t1,$t1,2
	addi $s0,$s0,32 #move to the next-next car
	
	lw $ra, 16($sp)
	addi $sp,$sp,4
	j sort_sub
swap:
	addi $t5,$s0,0 #car i address
	addi $t6,$s0,16 #car i+1 address

	addi $sp,$sp,-16
	
	move $a0,$t6
	move $a1,$sp
	li $a2, 16 #copy car[i] to stack
	jal memcpy
	
	move $a0,$t5
	move $a1,$t6
	li $a2, 16 #copy car[j] to car[i] position
	jal memcpy
	
	move $a0,$sp
	move $a1,$t5
	li $a2, 16
	jal memcpy #copy stack car to car[j] position
		
	addi $sp,$sp,16
	
	li $t0,0 #set t0 to false
	addi $t1,$t1,2
	addi $s0,$s0,32 #move to the next-next car
	lw $ra, 16($sp)
	addi $sp,$sp,4
	j sort_sub
back:
	jr $ra
return:
	li $v0,0		
	jr $ra
### Part VII ###
most_popular_feature:
	li $v0, -200
	li $v1, -200
	ble $a1,0,return_error
	blt $a2,1,return_error
	bgt $a2,15,return_error
	
	move $s0,$a0 #address of car array
	move $s1,$a1 #length of car array
	move $s2,$a2 #byte for determining which car features
	li $t0,0 #for indexing through car array
	
	li $t2,0 #gps count
	li $t3,0 #window count
	li $t4,0 #hybrid count
	li $t5,0 #convertible count
feature_loop:
	beq $t0,$s1,return_feature
	
	addi $sp,$sp,-16
	sw $s0,0($sp)
	sw $s1,4($sp)
	sw $s2,8($sp)
	sw $ra,12($sp)
	
	lb $t6, 14($s0) #load features of current car
	
	srl $t1,$s2,3 #msb of feature
	jal check_one
	
	sll $t1,$s2,29 #next bit
	srl $t1,$t1,31 
	jal check_two
	
	sll $t1,$s2,30 #next bit
	srl $t1,$t1,31
	jal check_three
	
	sll $t1,$s2,31 #last bit
	srl $t1,$t1,31
	jal check_four
	
	lw $s0,0($sp)
	lw $s1,4($sp)
	lw $s2,8($sp)
	lw $ra,12($sp)
	addi $sp,$sp,16
	
	addi $t0,$t0,1 #next index
	addi $s0,$s0,16 #next car
	
	j feature_loop
check_one:
	srl $t7,$t6,3 #msb of current car
	
	and $t7,$t1,$t7
	add $t2,$t2,$t7 #add to total count of GPS
	
	jr $ra
check_two:
	sll $t7,$t6,29 #next bit of current car
	srl $t7,$t7,31
	
	and $t7,$t1,$t7
	add $t3,$t3,$t7 #add to total count of GPS
	
	jr $ra
check_three:
	sll $t7,$t6,30 #next bit of current car
	srl $t7,$t7,31 
	
	and $t7,$t1,$t7
	add $t4,$t4,$t7 #add to total count of GPS
	
	jr $ra
check_four:
	sll $t7,$t6,31 #lsb of current car
	srl $t7,$t7,31 
	
	and $t7,$t1,$t7
	add $t5,$t5,$t7 #add to total count of GPS
	jr $ra
return_feature:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	
	move $t7,$t2 #tracker of greatest feature, rn set to $t2
	bgt $t3,$t7,new_great
next_feature:
	bgt $t4,$t7,new_great2
next_feature2:
	bgt $t5,$t7,new_great3
return_greatest:
	lw $ra, 0($sp)
	addi $sp,$sp,4
		
	beq $t7,$t2,eight
	beq $t7,$t3,four
	beq $t7,$t4,two
	beq $t7,$t5,one
	
new_great:
	move $t7,$t3
	 j next_feature
new_great2:
	move $t7,$t4
	j next_feature2
new_great3:
	move $t7,$t5
	j return_greatest
eight:
	li $v0,8
	jr $ra
four:
	li $v0,4
	jr $ra
two:
	li $v0,2
	jr $ra
one:
	li $v0,1
	jr $ra
### Optional function: not required for the assignment ###
transliterate:
	#takes in a0 as string, a1 as character
	sw $ra,0($sp)
	
	jal index_of
	
	move $t0,$v0
	li $t1,10
	div $t0,$t1 #modulus
	mfhi $v0 #remainder
	
	lw $ra,0($sp)
	
	jr $ra
### Optional function: not required for the assignment ###
char_at:
	move $t0,$a0 #array
	move $t1,$a1 #index to check
	add $t0,$t0,$t1 #add index to array to get the character
	
	lbu $v0, 0($t0) #load character at index 
	
	jr $ra
### Optional function: not required for the assignment ###
index_of:
	move $t0,$a0 #address 
	move $t1,$a1 #character
	li $t2,0 #indexing
loops:
	lbu $t3 0($t0)
	beq $t1,$t3,return_index
	addi $t0,$t0,1
	addi $t2,$t2,1
	j loops
return_index:
	move $v0,$t2
	jr $ra
### Part VIII ###
compute_check_digit:
	li $v0, -200
	li $v1, -200
	move $s0,$a0 #vin address
	move $s1,$a1 #map address
	move $s2,$a2 #weight address
	move $s3,$a3 #transliterate string
	li $s4,0 #sum
	li $s5,0 #index
	
looper:
	beq $s5,17,return_func
	
	addi $sp,$sp,-32
	sw $ra,4($sp)
	sw $s0,8($sp)
	sw $s1,12($sp)
	sw $s2,16($sp)
	sw $s3,20($sp)
	sw $s4,24($sp)
	sw $s5,28($sp)
	
	move $a0,$s0 #move vin
	move $a1,$s5 #move index
	jal char_at
	
	move $a0,$s3 #move transliterate string
	move $a1,$v0 #move char from char_at func
	jal transliterate
	
	move $t4,$v0 #t4 is the value given from transliterate func
	
	move $a0,$s2 #address of weight
	move $a1,$s5 #index
	jal char_at
	
	move $a0,$s1 #map address
	move $a1,$v0 #more char from char_at func
	jal index_of

	move $t5,$v0 #t5 is value from index_of map char
	
	lw $ra,4($sp)    
	lw $s0,8($sp)
	lw $s1,12($sp)
	lw $s2,16($sp)
	lw $s3,20($sp)
	lw $s4,24($sp)
	lw $s5,28($sp)
	addi $sp,$sp,32
	
	mul $t4,$t4,$t5 #transliterate(vin.charAt(i),transliterate_str)*map.index_of(weights.char_at(i))
	add $s4,$s4,$t4 #add t4 to sum
	
	addi $s5,$s5,1 #next index
	j looper	
return_func:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	
	li $t0,11
	div $s4,$t0
	mfhi $a1 #sum % 11
	move $a0,$s1 #map address
	jal char_at
	##char_at should return a character in $v0
	lw $ra 0($sp)
	addi $sp,$sp,4
	
	
	
	jr $ra
	
#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
