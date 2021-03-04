.data
BufferMatX1: .space 800
BufferMatX2: .space 800
BufferMatX3: .space 800
file1: .asciiz "mat1.txt"
file2: .asciiz "mat2.txt"
file3: .asciiz "mat3.txt"

readErrorMsg: .asciiz "\nError in reading from file\n"			 	###
openErrorMsg: .asciiz "\nError in opening file\n"     				 ###

.text

main:
# Open mat1.txt                                                							part1	
	la $a0, file1 # File to open
        li $a1, 0 # Open to read  
	li $v0, 13 # Open file command                   
	syscall	
	bltz $v0, openError # If negative number than there is an error      
	move $s0, $v0 # Save file descriptor           
# Read mat1.txt
	move $a0, $s0 # Set file descriptor           
	la $a1, BufferMatX1 # Address of output buffer          
	li $a2, 800 # Hardcoded buffer length        
	li $v0, 14 # Read from file command        
	syscall             	
	bltz $v0, readError  								###
	
	# Close file mat1.txt
	li   $v0, 16 # Close operation      
	move $a0, $s0 # matrix.txt decriptor
	syscall 
	
# Open mat2.txt
	la $a0, file2 # File to open     
	li $a1, 0 #Open to read      
	li $v0, 13 # Open file command                 
	syscall
	
	bltz $v0, openError # If negative number than there is an error    		 ###
	move $s1, $v0 # Save file descriptor   

# Read mat2.txt
	li $v0, 14 # Read from file command         
	move $a0, $s1  # Set file descriptor       
	la $a1, BufferMatX2 # Address of output buffer      
	li $a2, 800 # Hardcoded buffer length        
	syscall             
	
	bltz $v0, readError  								###
	
	# Close file mat2.txt
	li   $v0, 16 # Close operation        
	move $a0, $s1 # matrix.txt decriptor      
	syscall
	############################################################################################ from now on you can use $s0, $s1
														#part2
#	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~``~~``~``~~~~```~~~~~~~```~~~`~~``~~~~`~~~~`~~`~``~`~```~~~~~`~~

	move $s0, $zero # Columns counter
	la $t0, BufferMatX1 # Get Start of BufferMatX1 address and save in temporary
	subi $t0, $t0, 1
	
countColumns:
	addi $t0, $t0, 1 # Go further in buffer
	lbu $t1, 0($t0) # Get byte from buffer
	beq $t1, ' ', increaseCounter # If new btye == space
	beq $t1, '\n', endCountColumns # If new btye == new line 
        j countColumns


increaseCounter:
	addi $s0, $s0, 1 # Counter++
	j countColumns
#	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~``~~``~``~~~~```~~~~~~~```~~~`~~``~~~~`~~~~`~~`~``~`~```~~~~~`~~
#       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
endCountColumns:
# Calculate array bit size
	mul $t0, $s0, $s0 # Rows*Columns = number of elements
	addi $t1 , $zero, 4
	mul $t0, $t0, $t1 # Multiply number of elements by 4

# Create matrix 1
move  $a0, $t0 # Bit amount to allocate
	li  $v0, 9 # Allocate heap memory
	syscall
	move $s3, $v0 # Save matrix 1 in $s3

# Create matrix 2
move  $a0, $t0 # Bit amount to allocate
	li  $v0, 9 # Allocate heap memory
	syscall
	move $s2, $v0 # Save matrix 2 in $s2

# Create matrix 3
move  $a0, $t0 # Bit amount to allocate
	li  $v0, 9 # Allocate heap memory
	syscall
	move $s1, $v0 # Save matrix 3 in $s1
#       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	addi $t0, $zero,0 # Initialize number to 0
	la $t1 BufferMatX1 # Get Start of BufferMatX1 address and save in temporary
	subi $t1, $t1, 1 # Go back by one bit to fit loop
	la $t2, 0($s3) # Get Start of matrix1 address and save in temporary	
	addi $t5, $zero, 10 # Save 10 as temporary
        addi $t3, $zero, 1 # Multiply number
convertFileToMatrix1:
	addi $t1, $t1, 1 # Go further in buffer
	lbu $t4, 0($t1) # Get byte from buffer
	
	beq $t4, 0, end1  # End of buffer	
	beq $t4, 10, convertFileToMatrix1 # If new btye == new line 
	beq $t4, 32, addNumberToMatrix1 # If new btye == space
	blt $t4, 48, convertFileToMatrix1 # If new byte < 0 in ascii form
	bgt $t4, 57, convertFileToMatrix1 # If new byte > 9 in ascii form

	
	mul $t0, $t0, $t3 # Multiply number by 1 or 10
	move $t3, $t5 # Change multiply amount to 10
	subi $t4, $t4, 48 # Reduce 48 from number in ascii form
	add $t0, $t0, $t4 # Add new number to current number
	
	j convertFileToMatrix1
	
	
addNumberToMatrix1:
	sw $t0, 0($t2) # Store number into matrix1
	addi $t2, $t2, 4 # Go to next address in matrix1
	addi $t3, $zero, 1 # Reset multiply number
	addi $t0, $zero,0 # Reset number to 0
	j convertFileToMatrix1

end1:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	addi $t0, $zero,0 # Initialize number to 0
	la $t1 BufferMatX2 # Get Start of BufferMatX2 address and save in temporary
	subi $t1, $t1, 1 # Go back by one bit to fit loop
	la $t4, 0($s2) # Get Start of matrix2 address and save in temporary
	addi $t3, $zero, 1 # Multiply number

convertFileToMatrix2:
	addi $t1, $t1, 1 # Go further in buffer
	lbu $t2, 0($t1) # Get byte from buffer
	beq $t2, 0, end2  # End of buffer
	beq $t2, 32, addNumberToMatrix2 # If new btye == space
	beq $t2, 10, convertFileToMatrix2 # If new btye == new line 
	blt $t2, 48, convertFileToMatrix2 # If new byte < 0 in ascii form
	bgt $t2, 57, convertFileToMatrix2 # If new byte > 9 in ascii form

	subi $t2, $t2, 48 # Reduce 48 from number in ascii form
	mul $t0, $t0, $t3 # Multiply number by 1 or 10
	add $t0, $t0, $t2 # Add new number to current number
	move $t3, $t5 # Change multiply amount to 10
	j convertFileToMatrix2
	
	addNumberToMatrix2:
	sw $t0, 0($t4) # Store number into matrix2
	addi $t4, $t4, 4 # Go to next address in matrix2
	addi $t3, $zero, 1 # Reset multiply number
	addi $t0, $zero,0 # Reset number to 0  
	j convertFileToMatrix2

end2:
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        addi, $t0, $zero,0 # Number Sum
	la $t1, 0($s3) # Get Start of matrix1 address and save in temporary				
	la $t2, 0($s2) # Get Start of matrix2 address and save in temporary
	la $t3, 0($s1) # Get Start of matrix3 address and save in temporary
	addi $s5, $0, 4 # Save word length
	mul $s5, $s5, $s0 # Length of whole row
        mul $t4, $s5, $s0 # Size of whole array
# Initialize Matrix 3
	sub $t5, $0, 1 # Index i = -1
 
loop_i:
	
	subi $t6, $0, 1 # Index j = -1
        addi $t5, $t5, 1 # i++
	blt $t5, $s0, loop_j # If i < rows/columns size
	beq $t5, $s0, end3

loop_j:
       
        addi $t7, $zero,0 # Index k = 0
	addi $t6, $t6, 1 # j++
	blt $t6, $s0, loop_k # If j < rows/columns size	
	sub $t2, $t2, $s5 # reset matrix2 address
	add $t1, $t1, $s5 # Move to next row
	beq $t6, $s0, loop_i # If j == rows/columns size
loop_k:
	addi $t7, $t7, 1 # k++
	lw $t8, 0($t1) # Load matrix1[i][k]
	lw $t9, 0($t2) # Load matrix2[k][j]
	add $t2, $t2, $s5 # matrix2 next row
	addi $t1, $t1, 4 # matrix1 next column
	mul $t8, $t8, $t9 # temporary = matrix1[i][k]*matrix2[k][j]
	add $t0, $t0, $t8 # sumn += temporary	
	blt $t7, $s0, loop_k # If k < rows/columns size
	sw $t0, 0($t3) # matrix3[i][j] = sum
	addi $t0, $zero , 0  # sum = 0
	addi $t3, $t3, 4 # matrix3 address++
	sub $t1, $t1, $s5 # Reset matrix1 address
	sub $t2, $t2, $t4 # reset matrix2 address
	addi $t2, $t2, 4 # Move to next column
	beq $t7, $s0, loop_j # If k == rows/columns size
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
												#part4
end3:
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	la $t0, 0($s1) # Save matrix3 address to a temporary
	la $t1, BufferMatX3 # Save matrix3 buffer address
	subi $t2, $zero, 1 # i = -1
	addi $t3, $zero, 1 # Devision amount
	move $t4, $t3 
	addi $t5, $zero, 10 # Space in ascii
	addi $t6, $zero, 32 # New line in ascii
initializeMatrix3BufferLoop1:
	addi $t2, $t2, 1 # i++
	subi $t7, $zero, 1 # j = -1
	blt $t2, $s0, initializeMatrix3BufferLoop2 # If i < rows\columns size, jump
	j initializeMatrix3File
	
initializeMatrix3BufferLoop2:	
	
	lw $t8, 0($t0) # Get number for matrix 3
	addi $t7, $t7, 1 # j++
	blt $t7, $s0, itoa # If j < rows\columns size, jump	
	sb $t5, 0($t1) # Store new line into buffer
	addi $t1, $t1, 1 # buffer adress++	
	beq $t7, $s0, initializeMatrix3BufferLoop1 # If j == rows\columns size, jump

itoa:
	div $t8, $t3 # Current number / 10
	mflo $t9 # Qoutient
	mul $t3, $t3, $t5 # Increase devision amount by 10	
	bge $t9, $t5, itoa # If Qoutient >= 10, jump	
	div $t3, $t3, $t5 # Decrease devision amount by 10	
itoaRemainder:
        div $t3, $t3, $t5 # Decrease devision amount by 10
	addi $t9, $t9, 48 # Turn into ascii form
	sb $t9, 0($t1) # Store number into buffer
	addi $t1, $t1, 1 # buffer adress++	
	div $t9, $t8, $t3 # Current number = current number / 10000, 1000, 100, 10, 1
	div $t9, $t5 # Current number / 10
	mfhi $t9	
	bgt $t3, $t4, itoaRemainder
	move $t3, $t4
	addi $t9, $t9, 48 # Turn into ascii form
	sb $t9, 0($t1) # Store number into buffer
	addi $t0, $t0, 4 # matrix 3 address++
	addi $t1, $t1, 1 # buffer adress++	
	sb $t6, 0($t1) # Store space into buffer
	addi $t1, $t1, 1 # buffer adress++	
	j initializeMatrix3BufferLoop2
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
initializeMatrix3File:
# Open mat3.txt file

	li $v0, 13 # Open file operation
	li $a2, 0 # Mode is ignored
	li $a1, 1 # Open for writing
	la $a0, file3 # File name
	syscall
	move $s7, $v0 # Save file descriptor 

# Write to mat3.txt file
	li   $v0, 15       # system call for write to file
	li   $a2, 800       # hardcoded buffer length
	la   $a1, BufferMatX3   # address of buffer from which to write
	move $a0, $s7      # file descriptor 
	syscall            # write to file

# Close file mat3.txt
	li   $v0, 16 # Close operation        
	move $a0, $s1 # matrix.txt decriptor      
	syscall
	
endProgram:                                            				###
	li $v0, 10 # Terminate executaion
	syscall





############################################################################################################מטפל במטריצות לא תקינות
openError:
	li $v0, 4 # Print string
	la $a0, openErrorMsg # Set string
	syscall
	j endProgram

readError:
	li $v0, 4 # Print string
	la $a0, readErrorMsg # Set string    
	syscall
	j endProgram
