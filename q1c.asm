.data

buffer:   .space 100
beginarray: .word 5, 3, 4, 1, 2, -999			#â€™beginarray' with some contents	 DO NOT CHANGE THE NAME "beginarray"
array: .space 4000						#allocated space for â€˜array'
str_command:	.asciiz "Enter a command (i, d, s or q): " # command to execute
str_error:	.asciiz "Invalid Input! Enter a command (i, d, s or q): " # command to execute
blank:	.asciiz "\n"

index_please: .asciiz "Please enter an index: "
integer_please: .asciiz "Please enter an integer: "

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

    la      $a2, array
    jal     deletion

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
    #add     $a0, $a2, $zero     # $a0 = argument for length 
    #jal     length 
    #add     $s1, $zero, $v0     # use $s1 for bound 
    
    move     $t3, $s1          # set bound
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

enterCommand: 
### Prompt User to Enter command (i) ###
    addi    $sp, $sp, -4		# create 4 bytes on the stack to save $ra
	sw      $ra, 0($sp)           # to save $ra

    li      $v0, 4          # Prompt User to Enter command (i)
	la      $a0, str_command 
	syscall 

	li      $v0, 8	        # Get command from user
    la      $a0, buffer     #load byte space into address
    li      $a1, 20         # allot the byte space for string
    syscall
    lb      $a0, ($a0)      # fetch first character entered

    j return 

prompt_enter_again:
    addi    $sp, $sp, -4		# create 4 bytes on the stack to save $ra
	sw      $ra, 0($sp)           # to save $ra
    li      $v0, 4     # Prompt User to Enter command (i)
	la      $a0, str_error 
	syscall 
	
	li      $v0, 8	# Get command from user
    la      $a0, buffer #load byte space into address
    li      $a1, 20 # allot the byte space for string
    syscall
    lb      $a0, ($a0) # fetch first character entered

    j return 

### deletion function goes here ###
deletion: 
    addi    $sp, $sp, -4		# create 4 bytes on the stack to save $ra
	sw      $ra, 0($sp)         # to save $ra

    jal enterCommand

Compare1: 
	li      $t1, 'd'
    bne     $a0, $t1, prompt_enter_againd
    j       enter_indexd

prompt_enter_againd: 
    jal     prompt_enter_again
    j       Compare1

### Prompt User to Enter Index ###
enter_indexd: 
   #### length of array ### 
    la      $a2, array  
    li      $a0, 0 
    add     $a0, $a2, $zero     # $a0 = argument for length 
    jal     length 
    add     $s1, $zero, $v0     # use $s2 for bound 

    li      $v0, 4              # Prompt User to Enter index
	la      $a0, index_please 
	syscall 

    li      $v0, 5	    # Get index from user
    syscall
    move    $t1, $v0    # save index to t1
   
   	#addi $s1,$zero, 5
    bgt     $t1, $s1, enter_indexd   # if the index exceed 

#delete number 
    la      $a2, array      #load address of array
    subi    $t0, $s1, 1     # last index for traversing
    move    $t2, $t1        # $t2 = deletion index tracker 
    beq     $t2, $t0, sizede # just decrease the size if it is the last index 
    move    $t4, $t2        
    sll     $t4, $t4, 2     # $t4 = $t2 * 4 -> $t3 = $2 (offset) + base address 
    move    $t3, $a2        # $t3 point to the base address of array 
    add     $t3, $t3, $t4   # $t3 points to the deletion index 
loop4: 
    lw      $t4, 4($t3)     # next element's value 
    sw      $t4, 0($t3)     # store in current index 
    addi    $t3, $t3, 4     # increase array pointer 
    addi    $t2, $t2, 1     # increase counter 
    blt     $t2, $t0, loop4
sizede: 
    subi    $s1, $s1, 1
    j       return 

############################################################################################
### insertion function goes here ###
insertion: 
    addi    $sp, $sp, -4		# create 4 bytes on the stack to save $ra
	sw      $ra, 0($sp)         # to save $ra

    jal     enterCommand

Compare2: 
	li      $t1, 'i'
    bne     $a0, $t1, prompt_enter_againi
    j       enter_indexi

prompt_enter_againi: 
    jal     prompt_enter_again
    j       Compare2

### Prompt User to Enter Index ###
enter_indexi: 

	### length of array ###
    la      $a2, array  
    li      $a0, 0 
    add     $a0, $a2, $zero     # $a0 = argument for length 
    jal     length 
    add     $s2, $zero, $v0     # use $s2 for bound 

    li      $v0, 4     # Prompt User to Enter index
	la      $a0, index_please 
	syscall 

    li      $v0, 5	    # Get index from user
    syscall
    move    $t1, $v0    # save index to t1
   
    bgt     $t1, $s2, enter_indexi   # if the index exceed 


    li      $v0, 4      # Prompt User to Enter Integer
	la      $a0, integer_please 
	syscall 

    li      $v0, 5  	# Get index from user
    syscall
    move    $t2,$v0     #save Integer to t0

#add number
    add     $v0, $zero, $zero	# use $v0 as the counter and initialize it
    la      $a2, array
    addi    $s2, $s2, 1          #increment size of array
    loop3:	 
        beq     $s2, $v0, shift	    # reached the last index
	    addi    $v0, $v0, 1		    # increment count
	    addi    $a2, $a2, 4		    # advance pointer by 4
	    j       loop3			    # continue loop

     #for (c = size-1 ; c > position ; c--)
     #array[c+1] = array[c];
    shift: 
    beq     $v0, $t1, add_int       #if reach the index 
    addi    $v0, $v0, -1            #decrement counter 
    lw      $t3, -4($a2)            #load word of the current last index 
    sw      $t3, ($a2)
    addi    $a2, $a2, -4            #decrement pointer  
    j       shift
    add_int:
    sw      $t2, ($a2)              # insertion of new element 
    j       return 


return:	
    lw      $ra, 0($sp)		#  restore $ra and 
	addi    $sp, $sp, 4		# restore the stack
	jr      $ra