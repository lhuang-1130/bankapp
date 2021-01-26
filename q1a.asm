.data

beginarray:     .word 2, 3, 77, 5, -999			#â€™beginarray' with some contents	 DO NOT CHANGE THE NAME "beginarray"
array:          .space 4000					#allocated space for â€˜array'
str_command:	.asciiz "Enter a command (i, d, s or q): " # command to execute
blank:	        .asciiz "\n"
	
.text
.globl main

main:
	################### main code comes here ###################
# call length function 
    la      $a1, beginarray  # $a1 = beginarray address 
    add     $a0, $a1, $zero  # $a0 = argument for length 
    jal     length
   	add     $s1, $zero, $v0  # use $s1 for print int 
    # print out the length 
    li      $v0, 1                 
    add     $a0, $zero, $s1
    syscall 

    la      $a0, blank
    li      $v0, 4
    syscall    
       
# call copy function   
    la      $a2, array      # $a2 = array address 
    jal     copyarray

# call print function 
    la      $a2, array      # $a2 = array address 
    jal     printarray

	################### main code ends here ###################
	li      $v0, 10
	syscall

	################### length function ###################
length:
    addi    $sp, $sp, -4		# create 4 bytes on the stack to save $ra
	sw      $ra, 0($sp)         # to save $ra

    add     $v0, $zero, $zero	# use $v0 as the counter and initialize it
    addi    $t1, $zero, -999    # add special number 
    loop:	
        lw      $t2, ($a0)      # load word of the current address 
	    beq     $t2, $t1, return	# reached the special character so we are done
	    addi    $v0, $v0, 1		# increment count
	    addi    $a0, $a0, 4		# advance pointer by 4
	    j       loop			    # continue loop


copyarray:
    addi    $sp, $sp, -4		# create 4 bytes on the stack to save $ra
	sw      $ra, 0($sp)         # to save $ra
    li      $t1, -999 
    add     $t3, $zero, $zero	# use $t3 as the counter and initialize it
    loop2:
        lw      $t4, ($a1)          # load word from array 1
        sw      $t4, ($a2)          # store word to array 2
        lw      $t3, ($a2)
        beq     $t3, $t1, return 
        addi    $a1, $a1, 4         # advance pointer by 4
        addi    $a2, $a2, 4         # advance pointer by 4
        j       loop2			    # continue loop
   	

printarray:
    addi    $sp, $sp, -4		# create 4 bytes on the stack to save $ra
	sw      $ra, 0($sp)         # to save $ra

    #print array address = $a2 
    add     $a0, $a2, $zero     # $a0 = argument for length 
    jal     length 
    add     $s2, $zero, $v0     # use $s2 for bound 
    
    add     $t3, $s2, $zero     # set bound
    li      $t4, 0              # set counter 
    while:
        beq     $t4, $t3, return # check for array end

        lw      $a0, ($a2) # print array element
        li      $v0, 1
        syscall

        li      $a0, 32
        li      $v0, 11  # syscall number for printing character
        syscall

        addi    $a2, $a2, 4 # advance array pointer
        addi    $t4, $t4, 1 
        j       while # repeat the loop

return:	
    lw      $ra, 0($sp)		# restore $ra and 
	addi    $sp, $sp, 4		# restore the stack
	jr      $ra