## mmn 12 q4 ##
## Ofek Yaari-312456817 ##

.data
number: .byte -10,-8,-6,-4,-2,0,2,4,6,8
#number: .byte  100,0,120,6,-2,45,67,89,-12,23
#number: .byte 23,-2,45,67,89,12,-100,0,120,6 

decimal_msg: .asciiz "\nPrinting in base 10:"
base4_msg: .asciiz "\n\nPrinting in base 4:"
oct_msg: .asciiz "\n\nPrinting in base 8:"
section_a_msg: .asciiz "\n The signed numbers divisible by 8 are: "
section_b_msg: .asciiz "\n The unsigned numbers divisible by 4 are: "
section_c_msg: .asciiz "\n The sum of the array (sign) is: "
section_d_msg: .asciiz "\n The sum of the array (unsigned) is: "
section_e_msg: .asciiz "\n The differences are: "
is_arithmetic_progression_msg: .asciiz "\n\nThe array is an arithmetic progression."
not_arithmetic_progression_msg: .asciiz "\n\nThe array is not an arithmetic progression."
enter_num_msg: .asciiz "\n Please enter a number from 50 to 100: "
invalid_input_msg: .asciiz " Invalid input, Please try again."
index_msg: .asciiz " The value at index "
Value_by_location_msg: .asciiz " in the arithmetic progression is: "

.text
.globl main
main:
##### sections a-e by base 10 #####
	li $v0,4
	la $a0,decimal_msg # print: "Printing in base 10:"
	syscall
	
	la $a0,number # a0 is pointer to the array "number"
	li $a1,10 # a1 is the length of the array "number"
	li $a2,10 # a2 is the base required for printing
	jal sections_a_to_e
	
##### section f: sections a-e by base 4 #####
	li $v0,4
	la $a0,base4_msg # print: "Printing in base 4:"
	syscall
	
	la $a0,number
	li $a1,10
	li $a2,4
	jal sections_a_to_e

##### section g: sections a-e by base 8 #####
	li $v0,4
	la $a0,oct_msg # print: "Printing in base 8:"
	syscall
	
	la $a0,number
	li $a1,10
	li $a2,8
	jal sections_a_to_e
	
### section h ###
	jal arithmetic_progression

not_seq:
	li $v0,4
	la $a0,not_arithmetic_progression_msg # print: "The array not an arithmetic progression:"
	syscall
	j exit
	
arithmetic_progression:
	la $a0,number
	li $a1,10
	lb $t0,0($a0) # t0 is the first byte
	lb $t1,1($a0) # t1 is the second byte
	sub $t0,$t0,$t1 # t0 = t0 - t1
	addi $t1,$a0,1 # t1 points to the second byte
	add $t2,$a0,$a1
	subi $t2,$t2,1 # t2 points to the last byte
	
arithmetic_progression_loop:
	lb $t3, 0($t1) # t3 is the current byte
	lb $t4, 1($t1) # t4 is the next byte
	sub $t3,$t3,$t4 # t3 = t3 - t4
	bne $t3,$t0,not_seq # if the difference are not equal, exit loop 
	addi $t1,$t1,1 # t1++
	bne $t1,$t2,arithmetic_progression_loop
	
	li $v0,4
	la $a0,is_arithmetic_progression_msg # print: "The array is an arithmetic progression:"
	syscall
	
### section i ###
	la $a0,number
	lb $t0,0($a0) # t0 is the first byte
	lb $t1,1($a0) # t1 is the second byte
	sub $t1,$t1,$t0 # t1 = t1 - t0
	
Value_by_location:	
	li $v0,4
	la $a0,enter_num_msg # print: "Please enter a number from 50 to 100:"
	syscall
	li $v0,5 # read input number
	syscall
	
	move $t2,$v0 # save input as t2
	blt $t2,50,invalid_input # check if t2 => 50, else: invalid
	bgt $t2,100,invalid_input # check if t2 =< 100, else: invalid
	
	li $v0,4
	la $a0,index_msg # print: "The value at index ___"
	syscall
	li $v0,1
	move $a0,$t2 # save input as a0 and print it
	syscall
	li $v0,4
	la $a0,Value_by_location_msg # print: "in the arithmetic progression is ___:"
	syscall
	
	# a1 = t0 = the first term in the sequence
	# d = t1 = the common difference between terms
	# n = t2 = location in the sequence 
	# a_n = a0 = the n term in the sequence
	# Formula of an arithmetic progression: a1+(n-1)d = t0+(t2-1)t1 
	addi $a0,$t2,-1 # a0 = t2 - 1
	mulo $a0,$a0,$t1 # a0 = a0 * t1
	add $a0,$a0,$t0 # a0 = a0 + t0
	li $v0,1 
	syscall
	
exit: # end of program
	li $v0,10
	syscall

invalid_input:  # belongs to section i
	li $v0,4
	la $a0,invalid_input_msg # print: "Invalid input, Please try again"
	syscall
	j Value_by_location
	
set: # belongs to sections a and b
	lw $a0,8($sp) # pointer to array
	lw $a2,0($sp) # output base
	lw $a3,4($sp) # length of array
	addi $sp,$sp,-4 # push word to stack
	jr $ra

base:
	move $t0,$a0 # save a0 as t0
	beqz $t0,decimal # if t0 = 0, then 0 will be printed for each base
	beq $a2,10,decimal # if base = 10, then direct printing using syscall 1(print_int)
	bgtz $t0,print_by_base # Positive or negative

	li $v0,11
	li $a0,'-' # t0 < 0, therefore we will add a negative sign
	syscall
	
	abs $t0,$t0 # |t0|

print_by_base:
	beq $a2,4,base_4
	li $t3,3 # t3 = 3, print in base 2^3 = 8
	li $t1,7 # mask: t1 = 0...00111
	j oct
	
base_4:
	li $t3,2 # t3 = 2, print in base 2^2 = 4
	li $t1,3 # mask: t1 = 0...00011

oct:
	clz $t2,$t0 # count the number of leading zeros in t0 and put the result in t2
	li $t4,31 # t4 = 31
	sub $t2,$t4,$t2 # t2 = t4 - t2
	div $t2,$t2,$t3 # t2 = t2 / t3
	mulo $t2,$t2,$t3 # t2 = t2 * t3
	li $v0,1

base_loop:
	srlv $a0,$t0,$t2 
	and $a0,$a0,$t1
	syscall
	sub $t2,$t2,$t3 
	bgt $t2,-1,base_loop
	j base_return
	
decimal: # print in base 10
	li $v0,1
	move $a0,$t0 # a0 = t0
	syscall
	
base_return: # The conversion to the required base has been completed
	jr $ra 
	
base_byte:
	addi $sp,$sp,-4 # push word to stack
	sw $ra,0($sp) # save return address
	bne $a1,0,unsigned_base_byte # determine if we should print as signed or unsigned byte
	lb $a0,0($a0) # load byte with sign extension
	j base_byte_ret
	
unsigned_base_byte:
	lbu $a0,0($a0) # load byte with 0 extension

base_byte_ret:
	jal base 
	lw $ra,0($sp) # restore return address
	addi $sp,$sp,4 # pop word off stack
	jr $ra
	
print_division:
	lw $ra,16($sp) # restore return address
	lw $s0,0($sp) # restore s0
	addi $sp,$sp,20 # pop 5 words
	addi $sp,$sp,4 # pop argument off the stack
	jr $ra
	
division:
	addi $sp,$sp,-20  # space on stack
	sw $ra,16($sp) # save return address
	sw $a0,12($sp)
	sw $a1,8($sp)
	sw $a2,4($sp)
	sw $s0,0($sp) 
	add $s0,$a0,$a3 # s0 point to one byte after the end of the array
	
division_loop:
	sub $s0,$s0,1 # move s0 one byte
	blt $s0,$a0,print_division # if s0 < a0 then the loop is over
	lbu $t0,0($s0)
	lw $t1,20($sp)
	rem $t1,$t0,$t1 # save t1 as remainder of t0/t1
	bnez $t1,division_loop # if (t1 != 0)
	move $a0,$s0
	jal base_byte # print the number by the selected base
	
	li $v0,11
	li $a0,' ' # print space after number
	syscall
	
	lw $a0,12($sp)
	lw $a1,8($sp)
	lw $a2,4($sp)
	# we dont need a3 anymore so no need to restore it back..
	j division_loop

sections_a_to_e:
	addi $sp,$sp,-16 # space on stack
	sw $ra,12($sp) # save return address
	sw $a0,8($sp) # save $a0 as pointer to array
	sw $a1,4($sp) # length of array
	sw $a2,0($sp) # output base
	
### section a ###
	li $v0,4 
	la $a0,section_a_msg # print: "the signed numbers divisible by 8 are:"
	syscall
	
	jal set
	li $a1,1 # print as signed
	li $t0,8
	sw $t0,0($sp) # save t0 on stack
	jal division	
	
### section b ###
	li $v0,4
	la $a0,section_b_msg # print:  "The unsigned numbers divisible by 4 are:"
	syscall
	
	jal set
	li $a1,0 # print as unsigned
	li $t0,4
	sw $t0,0($sp)# save t0 on stack 
	jal division

### section c ###
	li $v0,4
	la $a0,section_c_msg # print: "The sum of the array (sign) is:"
	syscall
	
	li $a0,0 # a0 = The sum
	li $t0, 0 # t0 is the current array index	

signed_sum_loop:
	lb $t1, number($t0)
	add $a0, $a0, $t1 # a0 = a0 + t1
	addi $t0, $t0, 1 # t0++
	bne $t0, 10, signed_sum_loop # if the array didn't end, continue with the loop
	jal base

### section d ###
	li $v0,4
	la $a0,section_d_msg # print: "The sum of the array (unsigned) is:"
	syscall
	
	li $a0,0 # a0 = The sum
	li $t0, 0 # t0 is the current array index
	
unsigned_sum_loop:
	lbu $t1, number($t0)
	add $a0, $a0, $t1 # a0 = a0 + t1
	addi $t0, $t0, 1 # t0++
	bne $t0, 10, unsigned_sum_loop # if the array didn't end, continue with the loop
	jal base
	
### section e ###
	li $v0,4
	la $a0,section_e_msg # print: "The differences are:"
	syscall
	
	lw $a0,8($sp) # pointer to array
	lw $a1,4($sp) # length of array
	lw $a2,0($sp) # output base
	addi $sp,$sp,-16 #  space on stack
	sw $ra,12($sp) # save return address
	sw $a2,8($sp)
	sw $s0,4($sp)
	sw $s1,0($sp)
	move $s0,$a0 # s0 is pointer to current byte in the array
	add $s1,$a0,$a1 # s1 is pointer to last byte in the array
	subi $s1,$s1,1
	
difference:
	lb $a0,0($s0) # a0 is the value of the current byte 
	lb $t3,1($s0) # t0 is the value of the next byte 
	sub $a0, $a0, $t3 # calculate difference
	lw $a2,8($sp) # a2 = output base
	jal base
	
	li $a0, ' '# print space before next number
	li $v0, 11
	syscall
	
	addi $s0, $s0, 1
	bne $s0, $s1, difference # if the array didn't end, continue with the loop
	addi $sp,$sp,16 # pop 4 words
	lw $ra,12($sp) # restore return address
	lw $s0,4($sp) # restore s0
	lw $s1,0($sp) # restore s1
	
	jr $ra 
