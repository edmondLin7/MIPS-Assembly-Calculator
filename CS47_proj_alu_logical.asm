.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
###################################################################\##
au_logical:
	addi $sp, $sp, -12 
	sw   $fp,  12($sp)
	sw   $ra,  8($sp)
	addi $fp, $sp, 12
 
	beq $a2 '+', au_add_logical
	beq $a2 '-', au_sub_logical
	#beq $a2 '*', au_mult_logical
	#beq $a2 '/', au_div_logical
	j au_logical_end

au_add_logical:
	jal add_logical
	j au_logical_end

au_sub_logical:
	jal sub_logical
	j au_logical_end
# other
# ------------------------------------------
add_logical:
	addi $sp, $sp, -24
	sw   $fp  24($sp)
	sw   $ra  20($sp)
	sw   $s0  16($sp)
	sw   $a0  12($sp)
	sw   $a1  8($sp)
	addi $fp, $sp, 24
	
	
	li $s0, 0 #index holder
	li $s1, 0 #Carry
	li $s2, 0 #Sum Holder Y
	li $s3, 0 #A bit
	li $t4, 0 #B bit
	li $s4, 0 #Holder
	beq $s0 32 end_addLoop
   addLoop:
   	extract_nth_bit($s3, $a0, $t1)
   	extract_nth_bit($s4, $a1, $t2)
   	#Half adder logic
	xor $s1, $s3, $s4
	and $s2, $s3, $s4
	#Full adder logic
	and $t3, $s1, $s2
	xor $s3, $t3, $s2
	xor $s2, $s1, $s2
	insert_to_nth_bit($s4, $s0, $s2 ,$t4)
	addi $s0, $s0, 1
	end_addLoop:
	move $v0, $s0
	lw   $fp  24($sp)
	lw   $ra  20($sp)
	lw   $s0  16($sp)
	lw   $a0  12($sp)
	lw   $a1  8($sp)
	addi $sp, $sp, 24
	jr $ra
	
	#li $t1, 0 # position pointer
	#li $s2, 0 # Sum holder
	#li $t3, 0 # C holder half
	#li $t4, 0 # CI holder
	#li $t5, 0 # bit holder for a0
	#li $t6, 0 # bit holder for a1
	#li $s7, 0 # CO holder
	#li $t8, 0 # Bit holder for insert
sub_logical:
	addi	$sp, $sp, -20
	sw	$a1, 20($sp)
	sw	$a0, 16($sp)
	sw	$ra, 12($sp)
	sw	$fp, 8($sp)
	addi	$fp, $sp 20
	
	neg	$a1, $a1 #negation for 2 bits subtraction
	jal	add_logical #same logic still need to start with 1 bit carry
	
	lw	$a1, 20($sp)
	lw	$a0, 16($sp)
	lw	$ra, 12($sp)
	lw	$fp, 8($sp)
	add	$sp, $sp, 20
	jr	$ra

# TBD: Complete it
au_logical_end:
	lw   $fp,  12($sp)
	lw   $ra,  8($sp)
	addi $sp, $sp, 12
	jr 	$ra
