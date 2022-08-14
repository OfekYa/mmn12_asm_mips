## mmn 12 q3 ##
## Ofek Yaari-312456817 ##

.data
input_number:  .asciiz"\nPlease enter a number in the range -9999 to +9999: "
Error_msg:  .asciiz"Invalid input, Please try again"
sec_b_msg: .asciiz " The input value in 16 bits is: "
sec_c_msg: .asciiz "\n The input value in reverse 16 bits is: "
sec_d_msg: .asciiz "\n The value of input value in reverse 16 bits is: "

.text
.globl main
main:

## section a #   get an input and check that it meets the required conditions ##
get_input:
		li $v0,4
		la $a0,input_number # print: Please enter a number in the range -9999 to +9999
		syscall 
		li $v0,5  # read input integer
		syscall
		bgt $v0,9999,Out_Of_Range # if input > 9999
		blt $v0,-9999,Out_Of_Range # if input < -9999
		move $s0,$v0 # save input as s0
		j print_part

Out_Of_Range :
		li $v0,4 
		la $a0,Error_msg
		syscall
		j get_input 
		

## section b # print the input number in 16 bit ##

print_part:
		li $v0,4
		la $a0,sec_b_msg # print: "The value in 16 bits is:"
		syscall
		li $v0,1 
		li $t0,0x8000 # mask: 1000000000000000
print_16_bit:
		and $a0,$s0,$t0 
		beqz $a0,print_digit  # if a0 = 0, print 0
		li  $a0,1 
print_digit:
		syscall
		srl $t0,$t0,1     # shift the mask right
		bnez $t0,print_16_bit # The loop continue until mask = 0
		#li $v0,11
		#li $a0,'\n' # new line
		#syscall

## section C # print the input number in reverse 16 bit ##
		li $v0,4
		la $a0,sec_c_msg # print: "The value in reverse 16 bits is:"
		syscall
		li $v0, 1
		li $t0, 0x01 # mask: 0000000000000001
		li $t1, 0x8000  # the reverse 16 bit mask for section d
		li $t2, 0      # The  reverse  16 bit for section d
print_16_bit_reverse:
		and $a0, $s0, $t0   # a0 is the mask bit
		beqz $a0,print_digit_reverse
		li $a0,1
		or $t2,$t2,$t1
print_digit_reverse:
		syscall
		sll $t0, $t0, 1 # shift the mask left
		srl $t1,$t1,1
		bne $t0, 0x10000,print_16_bit_reverse # loop until t1 = 0 
		
		#li $v0,11
		#li $a0,'\n' # new line
		#syscall

## section D # print int in 16bit reverse in decimal ##
		li $v0,4
		la $a0,sec_d_msg # print: "The value of input value in reverse 16 bits is:"
		syscall

		andi $a0,$t2,0x8000 # check if the number is negative
		beqz $a0,Positive
		lui $a0,0xffff  # in case of negative sign extend by 1111111111111111
Positive:
		or $a0,$a0,$t2
		li $v0,1
		syscall

		li $v0,10 #end of progrem
		syscall

