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
#####################################################################
au_logical:
	beq $a2 '+', add_logical
	beq $a2 '-', sub_logical
	beq $a2 '*', mul_logical
	beq $a2 '/', div_logical
add_logical:
	saved_stack 				# call stack save
	li $s0, 0   				# addLoop counter
	li $v1, 0 				# carry in bit
	li $v0, 0 				# stored updated sum
	jal add_sub_logical
	restored_stack		 		# stacked restored
sub_logical:
	saved_stack
	move $s0, $a0				# used as save for $a0	
	move $a0, $a1				# move $a1 into $s0 get rdy to call twos_comp
	jal twos_complement     		# calling twos comp ~$a0 + 1
	move $a0, $s0				# move back orginal $a0
	move $a1, $v0				# move updated neg $a1 into $a1
	jal add_logical	
	restored_stack
add_sub_logical:
	li $s1 32               		# full size of Loop
	beq $s0, $s1, exit_add_sub		# if counter equals $s1(32 end) then jump to the restore
	extract_nth_bit($s2, $a0, $s0)  	# LSB of $a0
	extract_nth_bit($s3, $a1, $s0)		# LSB of $a1
	xor $s4, $s2, $s3			# half Adder Logic
	and $s6, $s2, $s3			# A.B
	and $s7, $v1, $s4			
	xor $s5, $v1, $s4			# full Adder Logic
	or $v1, $s7, $s6
	insert_to_nth_bit($v0, $s0, $s5, $t1) 	# insert updated add logic value into $v0
	addi $s0, $s0, 1 			# updated counter
	j add_sub_logical			# Loop back
   exit_add_sub: 				# Finished loop restore frame
   	jr $ra
 # Utility Procedures
# Two's complement ~$reg + 1
twos_complement: 
	saved_stack
twos_complement_no_revert:
	not $a0, $a0 				# Inverse $a0
	li $a1, 1    				# move 1 into $a1
	jal add_logical 			# add $a0 and $a1 
	restored_stack
 # If $a0 is < 0 then return pos value by using two's comp
twos_complement_if_neg:  
	saved_stack
	bltz $a0, twos_complement_no_revert     #less than 0 then jump to 2's comp
	move $v0, $a0  			        # move inverse value into $v0 
	restored_stack
# inverts both lo and hi to get carry value from lo. Add to inverted hi to get with overflow to get 2's complement
twos_complement_64bit:
	saved_stack   
	not $a0, $a0 				# invert lo, first oper. of add
	not $a1, $a1 				# invert hi 
	move $a3, $a1 				# move $a3 as inverted $a1 for temp
	li $a1, 1 				# load $a1 to 1, second oper. of add
	jal add_logical
	move $s0, $v0  				# move result of $s0 as new inverted (new lo)
	move $a0, $v1				# $a0 returns carry out of bit of last oper.
	move $a1, $a3 				# move the saved inverted hi back into $a1
	jal add_logical
	move $v1, $v0 				# move values hi
	move $v0, $s0 				# move values lo
	restored_stack
bit_replicator:
	saved_stack  
	beqz $a0, rep_zero   			# if $a0 is 0 then set $v0 to 0, if not then set it to 32 x 1
	li $v0, 0xFFFFFFFF
	restored_stack
rep_zero:
   	li $v0, 0x00000000
   	restored_stack
mul_logical:
   	saved_stack
   	jal twos_complement_if_neg 
   	move $s0, $v0 				# move $s0 to two's comp of $a0
   	move $a0, $a1 				# save the $a1 value into $a0 for next two's comp
   	jal twos_complement_if_neg 
   	move $a0, $s0				# move two's comp $a0
   	move $a1, $v0 				# move two's comp $a1 
mul_unsigned:
    	li $s0, 0				# set counter to 0
    	li $s2, 0				# set hi to 0
    	move $s1, $a1				# set $s1 to (MPLR)
    	move $s3, $a0   			# saved MCND
    	lw $a0, 52($sp)				# load back orig $a0 from frame
    	lw $a1, 48($sp) 			# load back orig $a1 from frame
    	li $s6, 31  				# set $s6 to 31 to extract MSB
    	extract_nth_bit($t7, $a0, $s6)		# temp store MSB of $a0
 	extract_nth_bit($t8, $a1, $s6)		# temp store LSB of $a1
 	xor $s7, $t7, $t8 			# store $s7 signed bit
extract_first_bit_mplr:
 	extract_nth_bit($a0, $s1, $zero) 	# extract LSB of $a0
 	jal bit_replicator 			# replicate LSB of mplr
 	and $s4, $s3, $v0			# AND of first bit
 	move $a0, $s2				# move hi to first oper. of addition
 	move $a1, $s4				# set result of AND as second oper.
 	jal add_logical				# Add
 	move $s2, $v0				# move result of the two into hi
 	srl $s1, $s1, 1				# right shift mlpr by 1
 	extract_nth_bit($s5, $s2, $zero)	# extract the MSB of hi
 	li $s6, 31
 	insert_to_nth_bit($s1, $s6, $s5, $t1)   # insert to lo MSB
 	srl $s2, $s2, 1				# Shift hi by 1
 	addi $s0, $s0, 1			# +1 to loop
 	li $s6, 32				
 	beq $s0, $s6, exit_multloop		# compare the counter to 32, if not 32 then jump back to extract next mplr
 	j extract_first_bit_mplr
exit_multloop:
 	move $v0, $s1				# move $v0 to 32 bit lo
 	move $v1, $s2				# move $v1 to 32 bit hi
 	beqz $s7, return_mult			# if $s7 is 0 then return pos value, if not result is neg
 	move $a0, $v0				# two's comp of $a0 (lo)
 	move $a1, $v1				# two's comp of $a1 (hi)
 	jal twos_complement_64bit		
return_mult:
	restored_stack				# restored stacks
	
div_logical:
	saved_stack
	jal twos_complement_if_neg 		# if $a0 is neg change to pos 2's comp
	move $s0, $v0
	move $a0, $a1
	jal twos_complement_if_neg	 	# if neg change $a1 to pos 2's comp
	move $a0, $s0	
	move $a1, $v0
unsigned_div:
	li $s0, 0 			 	# counter 
	move $s1, $a0  				# (Dividend)
	move $s2, $a1  				# (Divisor)
	li $s3, 0      				# Quotient
	lw $a0, 52($sp)				# Get the orignal dividend
	lw $a1, 48($sp)				# Get the original divisor
	li $s6, 31				# MSB pos
	extract_nth_bit($t7, $a0, $s6)		# extract MSB of dividend into $t7
	extract_nth_bit($t8, $a1, $s6)		# extract MSB of divisor of $t8
	xor $s7, $t7, $t8			# sign value of the both MSB pos
div_loop:
	sll $s3, $s3, 1				# left shift of remainder
	li $s6, 31				#
	extract_nth_bit($t1, $s1, $s6)		# extract msb of quotient for insertion to LSB of remainder
	insert_to_nth_bit($s3, $zero, $t1, $t2)	# insert extract bit into LSB of remainder
	sll $s1, $s1, 1				# shift left quotient by 1
	move $a0, $s3				# move shifted quotient into $a0 for sub_log
	move $a1, $s2				# move divisor into $a1 for sub_log
	jal sub_logical				# sub_log
	move $s4, $v0				# move result value into $s4
	bltz $s4, counter 			# if the value is less than 0 jump to counter else set remainder to $s4, Q[0] = 1
	move $s3, $s4				# insert quotient with updated neg result
	li $s6, 1				
	insert_to_nth_bit($s1, $zero, $s6, $t2) # if pos insert 1 ast LSB of quotient 
counter:
	addi $s0, $s0, 1			# counter update
	li $s6, 32
	beq $s0, $s6, exit_div			# if loop is 32 exit
	j div_loop
exit_div:
	move $v0, $s1				
	move $v1, $s3
	beqz $s7, sign_remainder		# if sign of quotient is zero then jump to remainder, if 1 it means pos no 2's needed 
	move $a0, $s1
	jal twos_complement			# set quotient to twos-comp
	move $s1, $v0
sign_remainder:					# sign for remainder
	beqz $t7, skip				# if $t7 is one meaning it is pos, no need for twos-comp
	move $a0, $s3
	jal twos_complement			# pos value if entered loop
	move $s3, $v0
skip:
	move $v0, $s1				# input respected signed quotient
	move $v1, $s3				# input respected signed remainder
	restored_stack

	
	
