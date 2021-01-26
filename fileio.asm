 # fileio.asm

.data

#You must use accurate an file path.
#These file paths are EXAMPLES,
#These will not work for you!
	
file1:		    .asciiz "test1.txt"
file2:			.asciiz "test2.txt"
file3:			.asciiz "test3.txt"

fileOutput:		.asciiz "test1.pbm"	#used as output1
openError:		.asciiz "Error in opening the file!"
readError:		.asciiz "Error in reading the file!"
closeError:		.asciiz "Error in closing the file!"
buffer:  		.space 18000 # buffer for upto 4096 bytes (increase size if necessary)
p1:				.asciiz "P1" 
fiftyfifty:		.asciiz "50 50"
newLine:		.asciiz "\n"
	.text
	.globl main

main:	
	la		$a0, file1		#readfile takes $a0 as input
	jal		readfile

	la		$a0, fileOutput		#writefile will take $a0 as file location
	la		$a1, buffer		#$a1 takes location of what we wish to write.
	jal		writefile

	li	$v0, 10		# exit
	syscall

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
	la		$a2, 2500		# hardcode maximum number of chars to read
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
	
	j 		return1

	
writefile:
#open file to be written to, using $a0.

	li		$v0, 13         # syscall code = 13
    la		$a0, fileOutput	# get the file name
    li		$a1, 1        	# write (1)
    syscall
    move	$s0, $v0		# save file descriptor 

	bltz	$v0, error1		# check if there is opening error 

#write the specified characters as seen on assignment PDF:
#P1
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
    la		$a1, buffer		
    la 		$a2, 2500			# length of the toWrite string
    syscall
	
#close the file (make sure to check for errors)
    li		$v0, 16       
    move	$a0, $s0      	
    syscall

	bltz	$v0, error3		# check if there is closing error 

	j return1
	
	return1:	
	jr      $ra
error1:
	li	$v0, 4		# read_string syscall code = 4
	la	$a0, openError
	syscall

error2:
	li	$v0, 4		# read_string syscall code = 4
	la	$a0, readError
	syscall

error3:
	li	$v0, 4		# read_string syscall code = 4
	la	$a0, closeError
	syscall

