.data
	msg1: .asciiz "C_"
	msg2: .asciiz " = "
	input_msg: .asciiz "Digite o valor de n: "
	novalinha: .asciiz "\n"

	# mensagens da triangulação
	msg_geo1: .asciiz "Um poligono de "
	msg_geo2: .asciiz " lados pode ser triangulado de "
	msg_geo3: .asciiz " maneiras."

.text
.globl triangular_entry

triangular_entry: 
	li $v0, 4
	la $a0, input_msg
	syscall

	li $v0, 5
	syscall
	move $s0, $v0

	move $a0, $s0
	jal catalan
	move $s1, $v0
	
	li $v0, 4
	la $a0, msg1
	syscall

	move $a0, $s0
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, msg2
	syscall

	move $a0, $s1
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, novalinha
	syscall

	addi $t0, $s0, 2

	li $v0, 4
	la $a0, msg_geo1
	syscall

	move $a0, $t0
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, msg_geo2
	syscall

	move $a0, $s1
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, msg_geo3
	syscall

	li $v0, 4
	la $a0, novalinha
	syscall

	li $v0, 10
	syscall