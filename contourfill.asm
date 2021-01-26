.data

#You must use accurate an file path.
#These file paths are EXAMPLES,
#These will not work for you!
	
file1:		.asciiz "test2.txt"
file3:		.asciiz "testfill.pbm"	#used as output

buffer:  	.space 10000		# buffers for upto 10000 bytes
newbuff: 	.space 10000		# (increase sizes if necessary)

openError:		.asciiz "Error in opening the file!"
readError:		.asciiz "Error in reading the file!"
closeError:		.asciiz "Error in closing the file!"
p1:				.asciiz "P1" 
fiftyfifty:		.asciiz "50 50"
newLine:		.asciiz "\n"

	.text
	.globl main

main:	
	la		$a0, file1			#readfile takes $a0 as input
	jal 	readfile

    la 		$a0, newbuff		# load address of array 
	li		$a1, 25	# row
	li		$a2, 25			# column
	jal 	fillregion

	la 		$a0, file3		#writefile will take $a0 as file location
	la 		$a1,newbuff		#$a1 takes location of what we wish to write.
	jal 	writefile

#######################################################################################
	li 		$v0, 10		# exit
	syscall
#######################################################################################
readfile:
#Open the file to be read,using $a0
#Conduct error check, to see if file exists
# You will want to keep track of the file descriptor*
	li		$v0, 13         # syscall code = 13
    la		$a0, file1     	# get the file name
    li		$a1, 0          # read (0)
    syscall
    move	$s0, $v0		# save file descriptor 

	bltz	$v0, error1		# check if there is opening error 

# read from file
# use correct file descriptor, and point to buffer
# address of the ascii string you just read is returned in $v1.
# the text of the string is in buffer
	li		$v0, 14			# syscall code = 14
	move	$a0, $s0		# file descriptor $s0 = $a0 
	la		$a1, buffer 	# buffer 
	la		$a2, 10000		# hardcode maximum number of chars to read
	syscall

	bltz	$v0, error2		# check if there is reading error 

	# print whats in the file
	li		$v0, 4		
	la		$a0, buffer
	syscall
	
# close the file (make sure to check for errors)
   	li		$v0, 16         # syscall code = 16
    move	$a0, $s0      	# file descriptor -> close
    syscall

    bltz	$v0, error3		# check if there is closing error 
	
#######################################################################################
storeInArray:
	li 		$s0, 0  # load 0 
	li 		$s1, 1  # load 1 
	li 		$s2, 48 #ascii for 0
	li 		$s3, 49 #ascii for 1
	li 		$s4, 10 #ascii for \n
	li 		$s5, 0  #null terminator 
	
	la 		$t1, buffer #load address for buffer 
	la 		$t2, newbuff #load address for newbuffer 
loop_convert:
	lb 		$t0, 0($t1) # load byte
	beq 	$t0, $s2, zero #if byte = 48, conver to 0 
	beq 	$t0, $s3, one #if byte = 49, conver to 1 
	beq 	$t0, $s4, incre #if byte = 10, increment 
	beq 	$t0, $s5, return1 # check if it is the null terminator, if yes, return 
	j 		loop_convert
zero:	
	sb 		$s0, 0($t2) #store 0
	addi 	$t2, $t2, 1 #increment new buffer pointer 
	addi 	$t1, $t1, 1 #increment buffer pointer 
	j 		loop_convert
one: 
	sb 		$s1, 0($t2)	#store 1
	addi 	$t2, $t2, 1 #increment new buffer pointer 
	addi 	$t1, $t1, 1 #increment buffer pointer 
	j 		loop_convert
incre:
	addi 	$t1, $t1, 1 #increment buffer pointer 
	j 		loop_convert
	
#######################################################################################
fillregion:
	li		$t1, 1 				# value 1 
	#li		$a1, 8				# row = 8
	#li		$a2, 14				# column = 14
	#la		#a0, array 

	mul 	$t2, $a1, 50		# i * num_of_column 
	add 	$t2, $t2, $a2		# i * num_of_column + j
	mul		$t2, $t2, 1 		# (i * num_of_column + j) * sizeof(data_type)
	add		$t2, $t2, $a0 		# (i * num_of_column + j) * sizeof(data_type) + base address 

	lb 		$t3, ($t2)	# load number 
	beq 	$t3, $t1, found1	# check if current number is 1, if yes, restore the stack and return
	sb		$t1, ($t2)	# store 1 into the current index 

#check all 8 neighbors 

	#check neighbor ($s1-1, $s2)
	addi    $sp, $sp, -12		
	sw      $ra, 0($sp)   	
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)

	addi	$a1, $a1, -1		# $s1 - 1
	jal		fillregion

	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw      $ra, 0($sp)		# restore $ra and 
	addi    $sp, $sp,12	# restore the stack

	#check neighbor ($s1-1, $s2-1)
	addi    $sp, $sp, -12		
	sw      $ra, 0($sp)   	
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)

	addi	$a1, $a1, -1		# $s1 - 1
	addi	$a2, $a2, -1		# $s2 - 1
	
	jal		fillregion

	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw      $ra, 0($sp)		# restore $ra and 
	addi    $sp, $sp,12	# restore the stack

	#check neighbor ($s1-1, $s2+1)
	addi    $sp, $sp, -12		
	sw      $ra, 0($sp)   	
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)

	addi	$a1, $a1, -1		# $s1 - 1
	addi	$a2, $a2, 1			# $s2 + 1

	jal		fillregion

	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw      $ra, 0($sp)		# restore $ra and 
	addi    $sp, $sp,12	# restore the stack

	#check neighbor ($s1+1, $s2)
	addi    $sp, $sp, -12		
	sw      $ra, 0($sp)   	
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)

	addi	$a1, $a1, 1			# $s1 + 1
	
	jal		fillregion

	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw      $ra, 0($sp)		# restore $ra and 
	addi    $sp, $sp,12	# restore the stack

	#check neighbor ($s1+1, $s2-1)
	addi    $sp, $sp, -12		
	sw      $ra, 0($sp)   	
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)

	addi	$a1, $a1, 1			# $s1 + 1
	addi	$a2, $a2, -1		# $s2 - 1
	
	jal		fillregion

	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw      $ra, 0($sp)		# restore $ra and 
	addi    $sp, $sp,12	# restore the stack

	#check neighbor ($s1+1, $s2+1)
	addi    $sp, $sp, -12		
	sw      $ra, 0($sp)   	
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)

	addi	$a1, $a1, 1			# $s1 + 1
	addi	$a2, $a2, 1			# $s2 + 1

	jal		fillregion

	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw      $ra, 0($sp)		# restore $ra and 
	addi    $sp, $sp,12	# restore the stack

	#check neighbor ($s1, $s2-1)
	addi    $sp, $sp, -12		
	sw      $ra, 0($sp)   	
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)

	addi	$a2, $a2, -1		# $s2 - 1
	
	jal		fillregion

	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw      $ra, 0($sp)		# restore $ra and 
	addi    $sp, $sp,12	# restore the stack

	#check neighbor ($s1, $s2+1)
	addi    $sp, $sp, -12		
	sw      $ra, 0($sp)   	
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)

	addi	$a2, $a2, 1			# $s2 + 1

	jal		fillregion

	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw      $ra, 0($sp)		# restore $ra and 
	addi    $sp, $sp,12	# restore the stack

#base case 
found1: 
	jr		$ra 
#######################################################################################
writefile:
	la 		$a0, newbuff 	 #use address as newbuff pointer 
	li		$t0, 1			 #set pointer 
	li 		$t1, 2500  		 #set bound for looping 
looping:
	lb 		$t2, 0($a0)		
	addi 	$t2, $t2, 48	#convert to ascii for each byte 
	sb 		$t2, 0($a0)		
	addi 	$t0, $t0, 1 	#advance pointer 
	addi 	$a0, $a0, 1 	#advance newbuff pointer 
	beq 	$t0, $t1, write
	j 		looping		
#######################################################################################
write:
#done in warmup
	li		$v0, 13         # syscall code = 13
    la		$a0, file3		# get the file name
    li		$a1, 1        	# write (1)
    syscall
    move	$s0, $v0		# save file descriptor 

	bltz	$v0, error1		# check if there is opening error 

	li		$v0, 15			# syscall code = 15
    move	$a0, $s0		# file descriptor
    la		$a1, p1			
    la 		$a2, 2			# length of the toWrite string
    syscall

	li		$v0, 15			# syscall code = 15
    move	$a0, $s0		# file descriptor
    la		$a1, newLine		
    la 		$a2, 1			# length of the toWrite string
    syscall
#50 50
	li		$v0, 15			# syscall code = 15
    move	$a0, $s0		# file descriptor
    la		$a1, fiftyfifty	# 
    la 		$a2, 5			# length of the toWrite string
    syscall

	li		$v0, 15			# syscall code = 15
    move	$a0, $s0		# file descriptor
    la		$a1, newLine		
    la 		$a2, 1			# length of the toWrite string
    syscall
#write the content stored at the address in $a1.
	li		$v0, 15			# syscall code = 15
    move	$a0, $s0		# file descriptor
    la		$a1, newbuff	
    la 		$a2, 10000		# length of the toWrite string
    syscall
	
#close the file (make sure to check for errors)
    li		$v0, 16       
    move	$a0, $s0      	
    syscall

	bltz	$v0, error3		# check if there is closing error 

	j 		return1

#######################################################################################
error1:
	li		$v0, 4		# read_string syscall code = 4
	la		$a0, openError
	syscall
	j 		return1

error2:
	li		$v0, 4		# read_string syscall code = 4
	la		$a0, readError
	syscall
	j 		return1

error3:
	li		$v0, 4		# read_string syscall code = 4
	la		$a0, closeError
	syscall
	j 		return1

#######################################################################################
return1:	
	jr 		$ra

