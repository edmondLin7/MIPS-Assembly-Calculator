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
 #frame4sp
 addi $sp, $sp, -12
 sw   $fp,  12($sp)
 sw   $ra,  8($sp)
 addi $fp, $sp, 12
 
beq $a2 '+', au_normalL1 
beq $a2 '-', au_normalL2
beq $a2 '*', au_normalL3 
beq $a2 '/', au_normalL4 
j au_normal_end

au_normalL1: add $v0, $a0, $a1
             j au_normal_end
au_normalL2:sub $v0 $a0, $a1
	    j au_normal_end
au_normalL3:mul $t3 $a0, $a1
	    mflo $v0 
	    mfhi $v1
	    j au_normal_end
au_normalL4:div $t3, $a0, $a1
	    mflo $v0
	    mfhi $v1
	    j au_normal_end
au_normal_end:
 lw   $fp  12($sp)
 lw   $ra  8($sp)
 addi $sp, $sp, 12
# TBD: Complete it
	jr	$ra
