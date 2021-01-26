
.data

bank_array: .word 0, 0, 0, 0, 0		# this array holds banking details
queries_size: .word 0  # store the count of queries 
queries_array: .space 10000	# update after each opeartion 
buffer: .space 10000		# buffers for upto 10000 bytes
# error message for invalid transactions
error_message:	.asciiz "That is an invalid banking transaction. Please enter a valid one.\n" 
# you can add more directives here: including additional arrays and variables.

	.text
	.globl main

	la		$a3, buffer  	#address for initial command
main:
	# main code comes here
	jal 	Read			# reading using MMIO
	add 	$a0,$v0,$zero	# in an infinite loop
	j		main
Read: 
	lui     $t0, 0xffff 	# $t0 = 0xffff0000
Loop1:	
	li 		$s4, 10 		# ascii for \n	
	beq		$v0, $s4, checkCommand # if /n, check command 
	lw		$t1, 0($t0) 	# $t1 = value(0xffff0000)
	andi 	$t1,$t1,0x0001	# Is Device ready?
	beq 	$t1,$zero,Loop1	# No: Check again..
	lw 		$v0, 4($t0) 	# Yes : read data from 0xffff0004
   	sb 		$v0, ($a3)     # Save the character into buffer
	lb		$v0, ($a3) 
    addi 	$a3, $a3, 1
	jr		$ra
	# main code ends here

checkCommand: 
	la      $a0, buffer     # load byte space into address
	la		$a3, buffer 	# clear the previous pointer for the next command	
###############################
    lb      $t1, 0($a0)     # fetch first character entered
	check_C: 
	li 		$s1, 67			# ascii code for C
	beq		$t1, $s1, check_H1 # if C, check H1
	check_S: 
	li 		$s1, 83			# ascii code for S
	beq		$t1, $s1, check_V # if S, check V
	check_D: 
	li 		$s1, 68			# ascii code for D
	beq		$t1, $s1, check_E # if D, check E
	check_W: 
	li 		$s1, 87			# ascii code for W
	beq		$t1, $s1, check_T2 # if W, check T
	check_L1: 
	li 		$s1, 76			# ascii code for L
	beq		$t1, $s1, check_N # if L, check N
	check_T1: 
	li 		$s1, 84			# ascii code for T
	beq		$t1, $s1, check_R # if T, check R
	check_B: 
	li 		$s1, 66			# ascii code for B
	beq		$t1, $s1, check_L3 # if B, check L3
	check_Q: 
	li 		$s1, 81			# ascii code for Q
	beq		$t1, $s1, check_H2
	bne		$t1, $s1, error1	  # if none of the letter above, output error message 
############################################
	check_H1:
	lb      $t1, 1($a0)     # fetch second character entered
	li		$s2, 72			# ascii code for H
	beq		$t1, $s2, openChecking  # run open_account
	bne		$t1, $s2, check_L2	  # if not CH, check for CL
	check_V:
	lb      $t1, 1($a0)     # fetch second character entered
	li		$s2, 86			# ascii code for V
	beq		$t1, $s2, openSaving  # run open_account
	bne		$t1, $s2, error1	  # if not SV, output error message 
	check_E:
	lb      $t1, 1($a0)     # fetch second character entered
	li		$s2, 69			# ascii code for E
	beq		$t1, $s2, deposit  # run deposite
	bne		$t1, $s2, error1	  # if not DE, output error message
	check_T2:
	lb      $t1, 1($a0)     # fetch second character entered
	li		$s2, 84			# ascii code for T
	beq		$t1, $s2, withdraw  # run withdraw
	bne		$t1, $s2, error1	  # if not WT, output error message 
	check_N:
	lb      $t1, 1($a0)     # fetch second character entered
	li		$s2, 78			# ascii code for N
	beq		$t1, $s2, get_loan  # run loan
	bne		$t1, $s2, error1	  # if not LN, output error message 
	check_R:
	lb      $t1, 1($a0)     # fetch second character entered
	li		$s2, 82			# ascii code for R
	beq		$t1, $s2, transfer  # run transfer
	bne		$t1, $s2, error1	  # if not TR, output error message 
	check_L2:
	lb      $t1, 1($a0)     # fetch second character entered
	li		$s2, 76			# ascii code for L
	beq		$t1, $s2, close_account # run closing account
	bne		$t1, $s2, error1	  # if not CH or CL, output error message 
	check_L3: 
	lb      $t1, 1($a0)     # fetch second character entered
	li		$s2, 76			# ascii code for L
	beq		$t1, $s2, get_balance # run balance
	bne		$t1, $s2, error1	  # if not BL, output error message 
	check_H2:
	lb      $t1, 1($a0)     # fetch second character entered
	li		$s2, 72			# ascii code for H
	beq		$t1, $s2, history # run hisotry
	bne		$t1, $s2, check_T3	  # if not QH, check for QT
	check_T3: 
	lb      $t1, 1($a0)     # fetch second character entered
	li		$s2, 84			# ascii code for 
	beq		$t1, $s2, QUIT 	# run QUIT
	bne		$t1, $s2, error1	  # if not QT, output error message

open_account:
	openChecking: 
	addi    $sp,$sp,-4			# Allocate stack space for two words
	sw      $ra, 0($sp)			# Save return address to stack
	la		$a2, bank_array	  	# load address of the array
	la		$a0, buffer			# load address of buffer
	addi	$a0, $a0, 3			# ignore CH command 	
	lb		$t2, ($a0)			# load current bit
	beq		$t2, 0, error 		# check if it is /n	
	jal 	conversion			# store checking account number
	blez	$a1, error 			# if account number is a string of 0 or invalid
	bge		$a1, 100000, error  # if it is 6 digits  
	lw		$t0, 0($a2)         # load current checking account number
	beq		$t0, $a1, error		# if $t0 = $a1, account numbers are the same, error 
	lw		$t1, 4($a2)         # load current saving account number
	beq		$t1, $a1, error		# if $t1 = $a1, checking and saving account cannot be the same, error 
	sw		$a1, 0($a2)
	addi	$a0, $a0, 1			# ignore checking account number
	lb		$t2, ($a0)			# load current bit
	beq		$t2, 0, clear_num1 		# check if it is /n
	jal 	conversion  		# store checking account balance 
	sw		$a1, 8($a2)	
	la 		$a2, bank_array	
	jal		printarray		    # print an array of elements
	jal		update_queries		# update query_array after 1 successful opeartion
	j 		return2
	
	openSaving: 
	addi    $sp,$sp,-4			# Allocate stack space for two words
	sw      $ra, 0($sp)			# Save return address to stack
	la		$a2, bank_array	    # load address of the array
	la		$a0, buffer			# load address of buffer	
	addi	$a0, $a0, 3			# ignore CH command
	lb		$t2, ($a0)			# load current bit
	beq		$t2, 0, error 		# check if it is /n		
	jal 	conversion
	blez	$a1, error 			# if account number is a string of 0 or invalid
	bge		$a1, 100000, error  # if it is 6 digits  	 	
	lw		$t0, 4($a2)         # load current saving account number
	beq		$t0, $a1, error		# if $t0 = $a1, account numbers are the same, error 
	lw		$t1, 0($a2)         # load current checking account number
	beq		$t1, $a1, error		# if $t1 = $a1, checking and saving account cannot be the same, error 	 
	sw		$a1, 4($a2)
	addi	$a0, $a0, 1			# ignore checking account number
	lb		$t2, ($a0)			# load current bit
	beq		$t2, 0, clear_num2 		# check if it is /n	 		
	jal 	conversion 
	sw		$a1, 12($a2)
	la 		$a2, bank_array		
	jal		printarray		 # print an array of elements
	jal		update_queries		# update query_array after 1 successful opeartion	
	j 		return2

deposit:
	addi    $sp,$sp,-4			#Allocate stack space for two words
	sw      $ra, 0($sp)			#Save return address to stack
	la		$a2, bank_array	  # load address of the array
	la		$a0, buffer		  # load address of buffer
	addi 	$a0, $a0, 3		  # ignore DE command
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no account number 
	beq		$t0, $t4, error   # if nothing gets deposited	
	jal		conversion		
	move    $t0, $a1		  # deposit account
	lw		$t1, 4($a2)		  # load saving account
	beq		$t0, $t1, deposit_saving # if deposit account = saving account 
	lw		$t3, 0($a2)		  # load checking account	
	bne		$t3, $t0, error	  # if account number does not match, this account does not exist
	deposit_checking: 		  # if match, deposit to checking 
	addi	$a0, $a0, 1		  # ignore checking account number 
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no deposite value 
	beq		$t0, $t4, error   # if nothing gets deposited	 	 
	jal 	conversion        # convert deposit amount 
	lw		$t2, 8($a2)	  # load current saving amount
	add 	$a1, $a1, $t2	  # total = saving + deposit 
	sw		$a1, 8($a2)	  # store updated saving amount
	la 		$a2, bank_array	
	jal		printarray		 # print an array of elements
	jal		update_queries		# update query_array after 1 successful opeartion	
	j 		return2
	deposit_saving: 		  # deposit to saving 
	addi	$a0, $a0, 1		  # ignore checking account number 
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no deposite value 
	beq		$t0, $t4, error   # if nothing gets deposited			 
	jal 	conversion        # convert deposit amount	 
	lw		$t2, 12($a2)	  # load current saving amount
	add 	$a1, $a1, $t2	  # total = saving + deposit 
	sw		$a1, 12($a2)	  # store updated saving amount
	la 		$a2, bank_array	
	jal		printarray		 # print an array of elements
	jal		update_queries		# update query_array after 1 successful opeartion	
	j 		return2

withdraw:
	addi    $sp,$sp,-4		  # Allocate stack space for two words
	sw      $ra, 0($sp)		  # Save return address to stack
	la		$a2, bank_array	  # load address of the array
	la		$a0, buffer		  # load address of buffer
	addi 	$a0, $a0, 3		  # ignore WT command
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no account number 
	beq		$t0, $t4, error   # if no account 
	jal		conversion
	lw		$t1, 0($a2)		  # load checking account number
	beq		$t1, $a1, withdraw_checking  # checking account withdrawal 
	lw		$t1, 4($a2)		  # load saving account number
	bne		$t1, $a1, error	  # if account number does not match, this account does not exist 
	withdraw_saving:
	addi	$a0, $a0, 1		  # ignore checking account number
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no account number 
	beq		$t0, $t4, error   # if no account 	
	jal 	conversion        # convert withdrawl amount 
	lw		$t2, 12($a2)	  # load current saving amount
	li		$t4, 20 		  # divide by 20 = multiply by 5%	
	div		$a1, $t4			  # withdrawl / 20 
	mflo	$t3				  # transaction fee 5% $t3
	add 	$a1, $a1, $t3	  # total withdrawl amount = withdraw + fee 	
	blt		$t2, $a1, error	  # check if saving amount is smaller than withdraw amount					  
	sub 	$a1, $t2, $a1	  # total = checking - withdrawl
	sw		$a1, 12($a2)	  # store updated saving amount
	la 		$a2, bank_array	
	jal		printarray		  # print an array of elements
	jal		update_queries		# update query_array after 1 successful opeartion	
	j 		return2
	withdraw_checking:
	addi	$a0, $a0, 1		  # ignore checking account number
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no account number 
	beq		$t0, $t4, error   # if no account 	
	jal 	conversion        # convert withdrawl amount 
	lw		$t2, 8($a2)	 	  # load current checking amount
	blt		$t2, $a1, error	  # check if saving amount is smaller than withdraw amount 	
	sub 	$a1, $t2, $a1	  # total = checking - withdrawl
	sw		$a1, 8($a2)	  	  # store updated checking amount
	la 		$a2, bank_array	
	jal		printarray		  # print an array of elements
	jal		update_queries	  # update query_array after 1 successful opeartion	
	j 		return2
	
get_loan:
	addi    $sp,$sp,-4		  # Allocate stack space for two words
	sw      $ra, 0($sp)		  # Save return address to stack
	la		$a2, bank_array	  # load address of the array
	la		$a0, buffer		  # load address of buffer
	addi 	$a0, $a0, 3		  # ignore LN command
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no loan number 
	beq		$t0, $t4, error   # if no account 	
	jal		conversion		  # convert loan amount
	lw		$t0, 16($a2) 	  # load loan amount 	
	lw		$t1, 8($a2)		  # load checking amount
	lw 		$t2, 12($a2)	  # load saving amount 
	add 	$t3, $t1, $t2	  # total amount in account
	li		$t4, 10000		  # condition
	bgt     $t4, $t3, error	  # if total balance is less than condition, output an error message 
	li		$t5, 2			  # time 50% = divide by 2
	div		$t3, $t5	      # total / 2 
	mflo	$t6				  # 50% of total 
	add     $a1, $a1, $t0 	  # loan total = loan + loan in account 
	bgt		$a1, $t6, error	  # if loan amount is greater than 50% of total 
	sw		$a1, 16($a2) 	  # store the loan amount
	la 		$a2, bank_array	 	 
	jal		printarray		  # print an array of elements
	jal		update_queries	  # update query_array after 1 successful opeartion	
	j 		return2
	
transfer:
	addi    $sp,$sp,-4		  # Allocate stack space for two words
	sw      $ra, 0($sp)		  # Save return address to stack
	la		$a2, bank_array	  # load address of the array
	la		$a0, buffer		  # load address of buffer
	addi 	$a0, $a0, 3		  # ignore TR command
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no loan number 
	beq		$t0, $t4, error   # if no account 		
	jal		conversion		  # convert Transfer From account
	move 	$t6, $a1		  # Transfer from 
	lw		$t3, 0($a2)		  # Checking account number
	lw		$t4, 4($a2)		  # Saving account number
	beq		$t3, $t6, checking_pay # if Transfer from = checking
	beq		$t4, $t6, saving_pay # if Trasnfer from = saving 
	j 		error			  # if not checking or saving => error
	saving_pay: 
	addi	$a0, $a0, 1		  # ignore first account number
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no loan number 
	beq		$t0, $t4, error   # if no account 		 
	jal 	conversion        # convert Transfer To account
	move	$t7, $a1		  # Transfer to or payback 
	bne		$t3, $t7, saving_payback	  # if $t7 != checking, go to loan pay back 
	beq	    $t3, $t7, saving_transfer	  # if $t7 = checking, transfer from saving to checking
	saving_payback:	
	addi	$a0, $a0, 1		  # ignore second entry 
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for wrong format 
	bne		$t0, $t4, error   # if there is something that get typed in, error! 
	lw	    $t5, 12($a2) 	  # load saving amount
	bgt		$t7, $t5, error	  # if payback amount is greater than saving amount	
	lw		$t6, 16($a2)	  # loan amount
	bgt		$t7, $t6, error	  # if payback amount is greater than saving amount	
	sub		$t5, $t5, $t7 	  # saving total = saving - payback
	sw		$t5, 12($a2)
	sub		$t6, $t6, $t7	  # loan total = loan - payback
	sw		$t6, 16($a2)	  # update loan amount
	la 		$a2, bank_array	
	jal		printarray		  # print an array of elements
	jal		update_queries	  # update query_array after 1 successful opeartion	
	j 		return2 	 	
	saving_transfer:
	addi	$a0, $a0, 1		  # ignore second account number
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no loan number 
	beq		$t0, $t4, error   # if no account 		 
	jal		conversion		  # convert Transfer amount
	move	$t2, $a1		  # Transfer amount
	bne		$t3, $t7, error	  # if transfer to account does not exist, output error
	lw	    $t5, 12($a2) 	  # load saving amount
	bgt		$t2, $t5, error	  # if transfer amount is greater than saving amount	
	sub		$t5, $t5, $t2	  # saving total = saving - transfer	
	sw		$t5, 12($a2)	  # store updated saving total 	
	lw		$t6, 8($a2) 	  # load checking amount
	add		$t6, $t6, $t2	  # checking total = checking + transfer
	sw		$t6, 8($a2)	  	  # store updated saving total
	la 		$a2, bank_array	
	jal		printarray		  # print an array of elements
	jal		update_queries	  # update query_array after 1 successful opeartion	
	j 		return2
	checking_pay: 
	addi	$a0, $a0, 1		  # ignore first account number
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no number 
	beq		$t0, $t4, error   # if no account 		 
	jal 	conversion        # convert Transfer To account
	move	$t7, $a1		  # Transfer to or payback
	lw		$t4, 4($a2)		  # Saving account number	 
	bne		$t4, $t7, checking_payback	  # if $t7 != saving, go to loan pay back 
	beq	    $t4, $t7, checking_transfer	  # if $t7 = saving, transfer from checking to saving 
	checking_payback:	
	addi	$a0, $a0, 1		  # ignore second entry 
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for wrong format 
	bne		$t0, $t4, error   # if there is something that get typed in, error! 
	lw	    $t5, 8($a2) 	  # load checking amount
	bgt		$t7, $t5, error	  # if payback amount is greater than checking amount	
	lw		$t6, 16($a2)	  # loan amount
	bgt		$t7, $t6, error	  # if payback amount is greater than saving amount	
	sub		$t5, $t5, $t7 	  # saving total = saving - payback
	sw		$t5, 8($a2)
	sub		$t6, $t6, $t7	  # loan total = loan - payback
	sw		$t6, 16($a2)	  # update loan amount	
	la 		$a2, bank_array	
	jal		printarray		  # print an array of elements
	jal		update_queries	  # update query_array after 1 successful opeartion	
	j 		return2 	 		 			 	
	checking_transfer: 
	addi	$a0, $a0, 1		  # ignore second account number
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no loan number 
	beq		$t0, $t4, error   # if no account 		 
	jal		conversion		  # convert Transfer amount
	lw		$t4, 4($a2)		  # Saving account number	
	move	$t2, $a1		  # Transfer amount	
	bne		$t4, $t7, error	  # if transfer to account does not exist, output error
	lw	    $t5, 8($a2) 	  # load checking amount
	bgt		$t2, $t5, error	  # if transfer amount is greater than checking amount	
	sub		$t5, $t5, $t2	  # checking total = checking - transfer	
	sw		$t5, 8($a2)	  	  # store updated checking total 	
	lw		$t6, 12($a2) 	  # load saving amount
	add		$t6, $t6, $t2	  # saving total = saving + transfer
	sw		$t6, 12($a2)	  # store updated saving total
	la 		$a2, bank_array	
	jal		printarray		  # print an array of elements
	jal		update_queries		# update query_array after 1 successful opeartion	
	j 		return2
	
close_account:
	addi    $sp,$sp,-4		  # Allocate stack space for two words
	sw      $ra, 0($sp)		  # Save return address to stack
	la		$a2, bank_array	  # load address of the array
	la		$a0, buffer		  # load address of buffer
	addi	$a0, $a0, 3		  # ignore CL command
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no loan number 
	beq		$t0, $t4, error   # if no account	 	
	jal		conversion		  # convert closing account num 
	move 	$t0, $a1		  # closing account num
	lw		$t3, 0($a2)		  # Checking account number
	lw		$t4, 4($a2)		  # Saving account number
	li		$t5, 0 			  # Check if account is close = 0 	
	beq		$t3, $t0, close_check # if account = checking
	beq		$t4, $t0, close_save  # if account = saving
	j 		error	  		  # if account number is not checking or saving, output error 
	close_check:
	beq		$t5, $t4, other_close	#check if both accounts are closed
	sw		$t5, 0($a2) 	  # close checking account
	lw		$t6, 8($a2)		  # take out checking amount
	sw		$t5, 8($a2)		  # clear checking amount
	lw		$t7, 12($a2)	  # take out saving amount
	add		$t7, $t7, $t6 	  # saving total = saving + checking
	sw		$t7, 12($a2)	  # store updated saving total
	la 		$a2, bank_array	 
	jal		printarray		  # print an array of elements
	jal		update_queries		# update query_array after 1 successful opeartion	
	j 		return2 
	close_save: 
	beq		$t5, $t3, other_close	#check if both accounts are closed
	sw		$t5, 4($a2) 	  # close saving account
	lw		$t6, 12($a2)	  # take out saving amount
	sw		$t5, 12($a2)	  # clear saving amount
	lw		$t7, 8($a2)	  	  # take out checking amount
	add		$t7, $t7, $t6 	  # checking total = saving + checking
	sw		$t7, 8($a2)	  	  # store updated checking total
	la 		$a2, bank_array	 
	jal		printarray		  # print an array of elements
	jal		update_queries		# update query_array after 1 successful opeartion	
	j 		return2 	
	other_close: 	
	lw		$t7, 8($a2)	  	  # take out checking amount
	lw		$t6, 12($a2)	  # take out saving amount
	add		$t7, $t7, $t6	  # remaining balance = saving + checking
	lw		$t8, 16($a2)	  # take loan value out
	bge		$t7, $t8, clear	  # if remaining is greater than or equal to loan 
	blt		$t7, $t8, error	  # if remianing is less than loan, you can't close the account => can't get away with it! 
	clear: 
	sw		$t5, 0($a2)		  # clear checking account 
	sw		$t5, 4($a2)		  # clear saving account
	sw		$t5, 8($a2)		  # store 0 to checking
	sw		$t5, 12($a2)      # store 0 to saving	
	sw		$t5, 16($a2)	  # clearn loan
	la 		$a2, bank_array	 
	jal		printarray		  # print an array of elements
	jal		update_queries		# update query_array after 1 successful opeartion	
	j 		return2 

get_balance:
	addi    $sp,$sp,-4		  # Allocate stack space for two words
	sw      $ra, 0($sp)		  # Save return address to stack
	la		$a2, bank_array	  # load address of the array
	la		$a0, buffer		  # load address of buffer
	addi	$a0, $a0, 3		  # ignore BL command
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no loan number 
	beq		$t0, $t4, error   # if no account	 	
	jal		conversion		  # convert account num 
	move 	$t0, $a1		  # account num
	addi	$a0, $a0, 2		  # ignore second entry 
	lb 		$t7, ($a0)
	li		$t4, 0			  # error check for wrong format 
	bne		$t7, $t4, error   # if there is something that get typed in, error! 
	lw		$t1, 0($a2)		  # Checking account number
	lw		$t2, 4($a2)		  # Saving account number
	beq		$t1, $t0, get_check	# if $t0 = checking account number 
	beq		$t2, $t0, get_saving # if $t0 = saving account number
	j 		error	  		  # if account number is not checking or saving, output error 	 
	get_check:
	lw      $a0, 8($a2) 	  # print saving amount 
    li      $v0, 1
    syscall	
 	li      $a0, 10
    li      $v0, 11  # syscall number for printing character
    syscall
	j		return2 	
	get_saving: 
	lw      $a0, 12($a2) 	  # print checking amount 
    li      $v0, 1
    syscall		
	li      $a0, 10
    li      $v0, 11  # syscall number for printing character
    syscall
	j 		return2

history:
	addi    $sp,$sp,-4		  # Allocate stack space for two words
	sw      $ra, 0($sp)		  # Save return address to stack
	la		$t2, queries_size	# load address of queries size
	lw		$t3, ($t2)			# load queries size
	la		$a0, buffer		  # load address of buffer
	addi	$a0, $a0, 3		  # ignore QH command
	lb 		$t0, ($a0)
	li		$t4, 0			  # error check for no queries number 
	beq		$t0, $t4, error   # if no account	 	
	jal		conversion		  # convert queries number  
	move 	$t4, $a1		  # store queries number 
	check_QH:
	li		$t0, 0				# load 0
	li		$t1, 5				# load 5	
	ble		$t4, $t0, error	  # if queries number <= 0
	bgt		$t4, $t1, error	  # if queries number > 5
	bgt		$t4, $t3, error   # if queries number > queries size
	li		$t5, 0			  # set counter for print_QH = 1
	li		$t6, 20			  # load 20	
	la		$a2, queries_array  # load address of queries array		
	print_QH:
	beq		$t5, $t4, return2
	jal		PRINT
	addi	$t5, $t5, 1		  # increment counter
	j 		print_QH	
	
clear_num1: 
	li		$t3, 0			  # clear account number if format is incorrect	
	sw 		$t3, 0($a2)
	j		error

clear_num2:
	li		$t3, 0			  # clear account number if format is incorrect
	sw 		$t3, 4($a2)
	j		error	

error: 
	li      $v0, 4      		# display error message and need to re-enter 
	la      $a0, error_message
	syscall
	j		return2				# jump to return2

error1:
	li      $v0, 4      		# display error message and need to re-enter 
	la      $a0, error_message
	syscall
	j		clearBuffer		 
	#j		return1				# jump to return2

conversion: 	
	li		$s0, 48				# ascii for 0
	li 		$s1, 57 			# ascii for 9
	li		$s2, 32				# ascii for space 
	li		$s3, 65				# ascii for A
	li 		$s4, 10 			# ascii for \n
	li 		$a1, 0 				# accumulator 	
	convert: 
		lbu      $t1, ($a0)      	# fetch current number 
	    beq     $s4, $t1, return1	# reached \n so we are done 
		beq		$s2, $t1, return1	# storeword
		bgt		$t1, $s1, error  	# if not a digit 
		subi 	 $t1, $t1, 48  		# convert from ascii to digit
		mul 	 $a1, $a1, $s4		# multiply 
		add 	 $a1, $a1, $t1		# accumulate 
		addi     $a0, $a0, 1 		# increment buffer pointer 
		j		 convert			

update_queries:
	la		$a0, queries_size	# load address of queries number
	lw		$s0, ($a0)			# load queries number
	la		$a1, queries_array	# load address of quaries array 
	li		$t1, 5				# load 5
	li		$t2, 1				# load 1  
	li		$t4, 0 				# load 0 
	li		$t5, 4				# load 4
	li		$t7, 20				# load 20
	beq		$s0, $t4, insertion	# directly insert when the number of queries = 0 	 
	mul		$t3, $s0, $t1 		# number of elements in current quaries
	sub		$t3, $t3, $t2 		# last index of quaries array = number of elements - 1
	mul 	$t6, $t3, $t5		# adjust for array pointer = (last index) * 4	
	add 	$a1, $a1, $t6		# add to array address => last element 
	shift:
    blt     $t3, $t4, insertion     # if last index of array < 0
	lw		$a2, ($a1)				# load current element from array
	add 	$a1, $a1, $t7			# go to next index = (current index + 5)*4
	sw 		$a2, ($a1)				# store current element to the index that is 5 elements away
	sub		$a1, $a1, $t7			# go back to current index 
	sub		$a1, $a1, $t5			# decrement pointer by 4
	sub     $t3, $t3, $t2 			# decrement counter of element by 1
    j       shift
	insertion: 
	la		$a1, bank_array			# load address of bank array
	la		$a2, queries_array		# load address of quaries array
	li		$t0, 0 					# set counter = 0
	li		$t1, 5					# set bound 
	insert: 
	beq		$t0, $t1, update		# if counter = 5, quit and update queries size 
	lw		$a0, ($a1)				# load word of bank array
	sw		$a0, ($a2)				# store word in queries array
	addi    $a1, $a1, 4				# increment bank array pointer
	addi    $a2, $a2, 4				# increment queries array pointer	
	addi	$t0, $t0, 1				# increment counter
	j 		insert
	update:
	la		$a0, queries_size	# load address of queries size
	lw		$s0, ($a0)			# load queries number
	addi	$s0, $s0, 1			# increment queries size 
	sw		$s0, ($a0) 			# store updated queries size 
	j		return1 	

printarray:
account_checker_checking:
	li		$t1, 0			# print 0
	lw		$t0, 0($a2)		# load checking account
	beq 		$t0, 0, append_no_0	# if account = 0 
	blt		$t0, 10, append_4_0			# if it is 1 digit
	blt		$t0, 100, append_3_0	    # if it is 2 digits
	blt		$t0, 1000, append_2_0		# if it is 3 digits
	blt		$t0, 10000, append_1_0		# if it is 4 digits
	blt		$t0, 100000, append_no_0	# if it is 5 digits 
	append_4_0: 
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
		lw      $a0, 0($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall			
		j		account_checker_saving
	append_3_0:
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
		lw      $a0, 0($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall			
		j		account_checker_saving
	append_2_0:
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
		move      $a0, $t1		# print 0
        li      $v0, 1
        syscall	
		lw      $a0, 0($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall			
		j		account_checker_saving
	append_1_0:
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
		lw      $a0, 0($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall			
		j		account_checker_saving
	append_no_0:
		lw      $a0, 0($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall			
		j		account_checker_saving				# jump to OHHH
		
account_checker_saving:
	li		$t1, 0			# print 0
	lw		$t0, 4($a2)		# load saving account
	beq 	$t0, 0, append_no	# if account = 0 	
	blt		$t0, 10, append_4			# if it is 1 digit
	blt		$t0, 100, append_3	    # if it is 2 digits
	blt		$t0, 1000, append_2		# if it is 3 digits
	blt		$t0, 10000, append_1		# if it is 4 digits
	blt		$t0, 100000, append_no	# if it is 5 digits 
	append_4: 
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
		lw      $a0, 4($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall			
		j		OHHH 
	append_3:
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
		lw      $a0, 4($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall			
		j		OHHH 
	append_2:
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
		lw      $a0, 4($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall			
		j		OHHH
	append_1:
	    move      $a0, $t1		# print 0
        li      $v0, 1
        syscall
		lw      $a0, 4($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall			
		j		OHHH
	append_no:
		lw      $a0, 4($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall			
		j		OHHH	
	OHHH: 	
   	li		$t3, 5    			# set bound
    li      $t8, 2              # set counter 
    whilec:
        beq     $t8, $t3, return3 # check for array end
        lw      $a0, 8($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall
        addi    $a2, $a2, 4 # advance array pointer
        addi    $t8, $t8, 1 
        j       whilec# repeat the loop

PRINT:  	
   	li		$t3, 5    			# set bound
    li      $t8, 0              # set counter 
    whileD:
        beq     $t8, $t3, return3 # check for array end
        lw      $a0, 0($a2) 		# print array element
        li      $v0, 1
        syscall
        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall
        addi    $a2, $a2, 4 # advance array pointer
        addi    $t8, $t8, 1 
        j       whileD# repeat the loop



return1:
	jr 		$ra
return2:
	jal		clearBuffer
	lw      $ra, 0($sp)		#  restore $ra and 
	addi    $sp, $sp, 4		# restore the stack
	jr      $ra
return3:
 	li      $a0, 10
    li      $v0, 11  # syscall number for printing character
    syscall
	jr 		$ra

clearBuffer:
	li 		$t0, 0 	# null terminator 
	la		$a0, buffer # load address of buffer
    lb		$t1, ($a0) 		  # load bite of buffer	 
	clear_null:
        beq     $t1, $t0, return1 # check for array end
        lb		$t1, ($a0) 		  # load bite of buffer
		sb		$t0, ($a0) 		  # store 0 to current location
		addi	$a0, $a0, 1		  # increment buffer pointer  
        j       clear_null # repeat the loop
QUIT:  
	li 		$v0,10
	syscall
# This program represents a simple banking application
# The program should allow to make the following operations
# a) opening an account b) finding out the balance, c) making a deposit
# d) making a withdrawal, e) transferring between accounts f) taking a loan 
# closing an account and h) displaying query history.
# The program should terminate when QUIT is entered by the user. 
