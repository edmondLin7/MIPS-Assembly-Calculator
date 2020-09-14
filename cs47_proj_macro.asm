# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
# Used to extract nth bit, will place bit in LSB of $regD
# RegD destination register
# RegS Source Register
# RegT amount of bits Shifted
.macro extract_nth_bit($regD, $regS, $regT)
	move $t0, $regS  # Store source into temp reg.
	srlv $t0, $t0, $regT # Shift the number to the right LSB bit whatever value wanted by $regT
	andi $regD, $t0, 1 # Use AND Logical get the LSB which is the extracted bit store it into $regD
	.end_macro
# #regD bit pattern in which 0x1 or 0x0 will be inserted
# $regS which position  bit to be inserted
# $regT register that contains 0x1 or 0x0
# $maskReg register to hold temp mask
.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
	li $maskReg, 1					# load temp mask with 1
	sllv $maskReg, $maskReg, $regS			# shift to the value bit to insert
	not $maskReg, $maskReg				# invert mask 
	and $regD, $regD, $maskReg			# And Logical should force insert bit to 0
	sllv $regT, $regT, $regS			# Shift value to insert
	or $regD, $regD, $regT				# Use Or logical since regD source pattern position is now 0 whatever value inserted will be overtaken with OR Logical
.end_macro

.macro saved_stack   #macro to save all stack frames
addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw	$a2, 44($sp)
	sw	$a3, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 60
.end_macro	

.macro restored_stack   #macro to restore all stack frames
	lw	$fp, 60($sp)
	lw	$ra, 56($sp)
	lw	$a0, 52($sp)
	lw	$a1, 48($sp)
	lw	$a2, 44($sp)
	lw	$a3, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 60
	jr	$ra
.end_macro