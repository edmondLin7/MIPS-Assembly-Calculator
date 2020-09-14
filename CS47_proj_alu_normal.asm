.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
# TBD: Complete it
	addi $sp, $sp, -12		 # Saved Stack for return and frame pointer
	sw   $fp, 12($sp)
	sw   $ra, 8($sp)
	addi $fp, $sp, 12
	
	beq $a2 '+', au_normal_add 	 # which operand procedure to jump to
	beq $a2 '-', au_normal_sub
	beq $a2 '*', au_normal_mul
	beq $a2 '/', au_normal_div
	j au_normal_end
	
au_normal_add:
	add $v0, $a0, $a1 		# MIPS Add operation 
	j au_normal_end	 		# Restore stack
		
au_normal_sub:
	sub $v0, $a0, $a1
	j au_normal_end   		# Restore stack
au_normal_mul: 
	mul $t3, $a0, $a1
	mflo $v0			# move lower 32 bits into $v0
	mfhi $v1 			# move higher 32 bits into $v1
	j au_normal_end  		# Restore stack
au_normal_div:
	div $t3, $a0, $a1
	mflo $v0 			# move remainder into $v0
	mfhi $v1			# move quotient into $v1
	j au_normal_end 		 # Restore stack
au_normal_end:				# restore stack
	lw $fp 12($sp)
	lw $ra 8($sp)
	addi $sp, $sp, 12
	jr	$ra
