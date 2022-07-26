jal main
#                                           ICS 51, Lab #2
# 
#                                          IMPORTATNT NOTES:
# 
#                       Write your assembly code only in the marked blocks.
# 
#                     DO NOT change anything outside the marked blocks.
# 
#                      Remember to fill in your name, student ID in the designated sections.
# 
#
j main
###############################################################
#                           Data Section
.data
# 
# Fill in your name, student ID in the designated sections.
# 
student_name: .asciiz "Zhiyuan Liu"
student_id: .asciiz "25105882"

new_line: .asciiz "\n"
space: .asciiz " "
gets: .asciiz " -> "
testing_label: .asciiz "Testing "
strlen_label: .asciiz "Strlen \n"
valid_id_label: .asciiz "Valid ID \n"
file_label: .asciiz "File read \n"
file:
	.asciiz	"lab2_data.dat"	# File name
	.word	0
buffer:
	.space	30			# Place to store character
num_tests: .word 4
test_1: .asciiz ""
test_2: .asciiz "Pr@p$r %unc&tuation"
test_3: .asciiz "$a&r()$o###ma"
test_4: .asciiz "{CASH}_R...ules_ever23ythi*ng ar( )ound me!."
input_data:
    .word test_1, test_2, test_3, test_4
test_1_out: .space 100
test_2_out: .space 100
test_3_out: .space 100
test_4_out: .space 100
output_data:
    .word test_1_out, test_2_out, test_3_out, test_4_out
###############################################################
#                           Text Section
.text

#                          Main Function
.globl main
main:

li $v0, 4
la $a0, student_name
syscall
la $a0, new_line
syscall  
la $a0, student_id
syscall 
la $a0, new_line
syscall

test_strlen:
lw $s1, num_tests
li $s0, 0
li $v0, 4
la $a0, testing_label
syscall
la $a0, strlen_label
syscall 

test1_loop:
beq $s0, $s1, test_valid_id

la $t0, input_data
sll $a0, $s0, 2
add $t0, $t0, $a0
lw $a0, ($t0)

sub $sp,$sp,4
sw $a0,($sp)

jal strlen

lw $a0,($sp)
addiu $sp,$sp,4

move $t0, $v0
li $v0, 4
syscall
la $a0, gets
syscall  

move $a0, $t0
li $v0, 1
syscall 
li $v0, 4
la $a0, new_line
syscall

addi $s0, $s0, 1
b test1_loop

test_valid_id:

li $v0, 4
la $a0, new_line
syscall
lw $s1, num_tests
li $s0, 0
li $v0, 4
la $a0, testing_label
syscall
la $a0, valid_id_label
syscall 

test2_loop:
beq $s0, $s1, test_file_read

la $t0, input_data
la $t1, output_data

sll $a0, $s0, 2
add $t0, $t0, $a0
lw $a0, ($t0)
sll $a1, $s0, 2
add $a1, $t1, $a1
lw $a1, ($t1)

sub $sp,$sp,4
sw $a0,($sp)
sub $sp,$sp,4
sw $a1,($sp)

jal valid_id

lw $a1,($sp)
addiu $sp,$sp,4
lw $a0,($sp)
addiu $sp,$sp,4

li $v0, 4
syscall
la $a0, gets
syscall 
move $a0, $a1 
syscall 

li $v0, 4
la $a0, new_line
syscall

addi $s0, $s0, 1
b test2_loop

test_file_read:
li $v0, 4
la $a0, new_line
syscall
li $s0, 0
li $v0, 4
la $a0, testing_label
syscall
la $a0, file_label
syscall 
jal file_read
end:
# end program
li $v0, 10
syscall


###############################################################
###############################################################
###############################################################
#                            PART 1 (Strlen)
# You are given a null-terminated strings ($a0). You need calculate its length and store in ($v0).
# Basically you should count number of characters before reaaching the character with value of 0.
# int strlen (str) {
#    int len = 0;
#    while (str[len] != 0)   // 0 != '0'
#        len++;
#    return len;
# }
strlen:
############################## Part 1: your code begins here ###

li $t0, 0
move $t1, $a0
check:
lb $t2, ($t1)
beq $t2, 0, result
addi $t0, $t0, 1
addi $t1, $t1, 1
j check
result:
move $v0, $t0

############################## Part 1: your code ends here   ###
jr $ra
###############################################################
#                           PART 2 (Valid IDs)
#
# Takes a null terminated (C-Style) string and returns another C-style string only
# containing valid characters. Valid characters are defined to be alphanumeric characters (a-A,b-B,0-9)
# and "_" (underscore) character.
# $a0 : pointer to input string buffer
# $a1 : pointer to output string buffer (initially all zeros)
valid_id:
############################### Part 2: your code begins here ##

move $t1, $a0
move $t2, $a1
check2:
lb $t3, ($t1)
beq $t3, 0, result2
beq $t3, 95, addElement
blt $t3, 48, skipElement
blt $t3, 58, addElement
blt $t3, 65, skipElement
blt $t3, 91, addElement
blt $t3, 97, skipElement
blt $t3, 123, addElement
bgt $t3, 122, skipElement
skipElement:
addi $t1, $t1, 1
j check2
addElement:
sb $t3, ($t2)
addi $t1, $t1, 1
addi $t2, $t2, 1
j check2
result2:
sb $zero, ($t2)

############################### Part 2: your code ends here  ##
jr $ra
###############################################################
#                           PART 3 (ReadFile)
#
# You will read characters (bytes) from a file (lab2_data.dat) and print them. Valid characters are only spaces (ASCII code 32), 
#Exclamation points (ASCII code 33), and uppercase letters (A-Z). 
#Lower case letters should be converted to uppercase and eveything else should be discarded
#The expected output should be in one line and read: THIS WAS A SUCCESS!
# $a1 : address of the input buffer
file_read:

# Open File

	li	$v0, 13			# 13=open file
	la	$a0, file		# $a2 = name of file to read
	add	$a1, $0, $0		# $a1=flags=O_RDONLY=0
	add	$a2, $0, $0		# $a2=mode=0
	syscall				# Open FIle, $v0<-file descriptor (fd)
	add	$s0, $v0, $0	# store fd in $s0
	
# Read file and store it in the buffer

	li	$v0, 14			# 14=read from  file
	add	$a0, $s0, $0	# $s0 contains fd
	la	$a1, buffer		# buffer to hold string
	li	$a2, 30		# Read 30 characters
	syscall


############################### Part 3: your code begins here ##

move $t1, $a1
check3:
lb $t3, ($t1)
beq $t3, 0, result3
beq $t3, 32, printCharacter
beq $t3, 33, printCharacter
blt $t3, 65, skipElement3
blt $t3, 91, printCharacter
blt $t3, 97, skipElement3
blt $t3, 123, convert
bgt $t3, 122, skipElement3
skipElement3:
addi $t1, $t1, 1
j check3
printCharacter:
li $v0, 11
move $a0, $t3
syscall
addi $t1, $t1, 1
j check3
convert:
subi $a0, $t3, 32
li $v0, 11
syscall
addi $t1, $t1, 1
j check3
result3:

############################### Part 3: your code ends here  ##
# Close File

done:
	li	$v0, 16			# 16=close file
	add	$a0, $s0, $0	# $s0 contains fd
	syscall				# close file

jr $ra
