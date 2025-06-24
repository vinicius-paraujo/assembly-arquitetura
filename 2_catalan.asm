.data
msg1:       .asciiz "C_"
msg2:       .asciiz " = "
input_msg:  .asciiz "Digite o valor de n: "
novalinha:  .asciiz "\n"

.text
.globl catalan
.globl catalan_entry

catalan_entry:
    # Pergunta o valor de n
    li $v0, 4
    la $a0, input_msg
    syscall

    # Leitura do inteiro n
    li $v0, 5
    syscall
    move $s0, $v0       # salva n em $s0

    # Calcula catalan(n)
    move $a0, $s0       # argumento n
    jal catalan
    move $s1, $v0       # resultado em $s1

    # Imprime "C_"
    li $v0, 4
    la $a0, msg1
    syscall

    # Imprime o valor de n
    move $a0, $s0
    li $v0, 1
    syscall

    # Imprime " = "
    li $v0, 4
    la $a0, msg2
    syscall

    # Imprime o resultado catalan(n)
    move $a0, $s1
    li $v0, 1
    syscall

    # Nova linha
    li $v0, 4
    la $a0, novalinha
    syscall

    # Finaliza o programa
    li $v0, 10
    syscall

##############################
# Função catalan
# Recebe n em $a0
# Retorna catalan(n) em $v0
##############################
catalan:
    addi $sp, $sp, -8     # salvar $ra e $t4 (temporário)
    sw $ra, 4($sp)
    sw $t4, 0($sp)

    move $t4, $a0         # salva n original em $t4

    # fatorial(2n)
    sll $a0, $t4, 1       # a0 = 2 * n
    jal fatorial
    move $t0, $v0         # t0 = fat(2n)

    # fatorial(n + 1)
    addi $a0, $t4, 1      # a0 = n + 1
    jal fatorial
    move $t1, $v0         # t1 = fat(n + 1)

    # fatorial(n)
    move $a0, $t4         # a0 = n
    jal fatorial
    move $t2, $v0         # t2 = fat(n)

    # denom = t1 * t2
    mul $t3, $t1, $t2

    # resultado = t0 / denom
    div $t0, $t3
    mflo $v0

    lw $t4, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

##############################
# Função fatorial (recursiva)
# Entrada: n em $a0
# Saída: factorial(n) em $v0
##############################
fatorial:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    ble $a0, 1, base_case

    addi $a0, $a0, -1
    jal fatorial         # fat(n - 1)
    lw $a0, 0($sp)       # restaura n
    mul $v0, $a0, $v0    # v0 = n * fat(n - 1)

    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

base_case:
    li $v0, 1
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra