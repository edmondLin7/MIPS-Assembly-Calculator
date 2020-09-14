# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
	.macro extract_nth_bit($regD, $regS, $regT)
     	srlv $regS, $regS, $regT #Shift to whatever bit position then store the shift into destination
        li   $regD, 1 #Reg D will have value 1 to and
     	and  $regD, $regS, $regD #and the saved shift register and value 1 to get right most bit of $regS
     	.end_macro
     	
     	.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
     	move $maskReg, $regT #Instert x0 or x1 into $mask
     	sllv $maskReg, $maskReg, $regS #Shift amount left to the desired index $reg$
     	not  $maskReg, $maskReg #
     	and  $regD, $regD, $maskReg 
     	sllv $regT, $regT, $regS
     	or   $regD, $regD, $regT
	.end_macro
#<------------------ MACRO DEFINITIONS ---------------------->#
        # Macro : print_str
        # Usage: print_str(<address of the string>)
        .macro print_str($arg)
	li	$v0, 4     # System call code for print_str  
	la	$a0, $arg   # Address of the string to print
	syscall            # Print the string        
	.end_macro
	
	# Macro : print_int
        # Usage: print_int(<val>)
        .macro print_int($arg)
	li 	$v0, 1     # System call code for print_int
	li	$a0, $arg  # Integer to print
	syscall            # Print the integer
	.end_macro
	
	# Macro : exit
        # Usage: exit
        .macro exit
	li 	$v0, 10 
	syscall
	.end_macro
	
	.macro read_int($arg) 
	li	$v0, 5  #System call code for read_int
	syscall
	move $arg, $v0   #Take the read integer into target
	.end_macro
	
	.macro print_reg_int($arg) #printing from register
	li    $v0, 1    #print int call
	move  $a0, $arg #write in terms of argument  
	syscall
	.end_macro
	
	.macro swap_hi_lo($temp1, $temp2)
	mfhi $temp1 #set $temp1 with Hi value
	mflo $temp2 #set $temp2 with Lo value
	move $t0, $temp1 #Perform Temp hold on $t0
	move $t1, $temp2 #Perform Temp hold on St1
	mthi $t1  #set the temp $t1 to Hi (Swapped)
	mtlo $t0  #set the temp $t0 to Lo (Swapped)
	syscall
	.end_macro

	.macro print_hi_lo($strHi, $strEqual, $strComma, $strLo)
	print_str($strHi) #Print Hi
	print_str($strEqual) #Print Lo
	li $v0, 1 # Evoke System to get rdy to print
	mfhi, $a0 # Print the Hi as a String I'm going to move mfhi to Sa0
	syscall
	print_str($strComma) #Print comma
	print_str($strLo) #Print Lo 
	print_str($strEqual) #Print equal
	li $v0, 1 #Evoke System to get rdy to print
	mflo, $a0 # Print the Lo as a String
	syscall
	.end_macro
	
	.macro lwi($reg, $ui, $li) # takes immediate values $ui and $li and put them into higher and lower bits of $reg
	lui $reg, $ui #upper bound 16 bit is $ui
	ori $reg, $reg, $li #store the last 16 bits into $reg
	.end_macro
	
	.macro push($reg)
	sw $reg 0x0($sp) #push the contents at $sp into $reg
	addi $sp, $sp, -4  #move the pointer 4 spaces lower
	.end_macro
	
	.macro pop($reg)
	addi $sp, $sp, +4  #move pointer 4 spaces higher
	lw $reg, 0x0($sp) #load the content of $reg into the stack pointer memory $reg
	.end_macro
	
	
