.data

# Mensagens
prompt_size:     .asciiz "Digite a quantidade de alunos (max 100): "
prompt_iesima_1: .asciiz "Digite a "
prompt_iesima_2: .asciiz "ª nota:"
result_msg:      .asciiz "\nNotas ordenadas:\n"
newline:         .asciiz "\n"
max_size_msg:    .asciiz "Erro: Insira uma quantidade menor ou igual a 100.\n"

# Variáveis
max_size:        .word 100
array:           .space 400       # Espaço para até 100 inteiros (4 bytes cada)

.text
.globl bubble_sort_entry

##########################################################
# Entrada: Nenhuma (espera entrada do usuário)
# Saída: Impressão das notas ordenadas
# Uso:   jal bubble_sort_entry
##########################################################

bubble_sort_entry:

    # Pede a quantidade de alunos
    li $v0, 4
    la $a0, prompt_size
    syscall

    li $v0, 5
    syscall
    move $t0, $v0          # $t0 = quantidade de alunos

    # Se tamanho > 100, exibe erro e sai
    li $t9, 100
    ble $t0, $t9, ler_elementos

    li $v0, 4
    la $a0, max_size_msg
    syscall
    jr $ra                 # Retorna ao chamador

##############################
# Leitura dos elementos
##############################

ler_elementos:
    la $s0, array          # $s0 = endereço base do array
    li $t1, 0              # índice i = 0

ler_loop:
    bge $t1, $t0, bubble_sort

    # Imprime "Digite a "
    li $v0, 4
    la $a0, prompt_iesima_1
    syscall

    # Imprime número da nota (t1 + 1)
    addi $a0, $t1, 1
    li $v0, 1
    syscall

    # Imprime "ª nota:"
    li $v0, 4
    la $a0, prompt_iesima_2
    syscall

    # Quebra de linha
    li $v0, 4
    la $a0, newline
    syscall

    # Lê a nota (inteiro)
    li $v0, 5
    syscall
    move $t2, $v0          # nota lida

    # Calcula endereço array[i] e salva valor
    sll $t4, $t1, 2
    addu $t3, $s0, $t4
    sw $t2, 0($t3)

    addi $t1, $t1, 1
    j ler_loop

##############################
# Algoritmo de Bubble Sort
##############################

bubble_sort:
    addi $t5, $t0, -1      # t5 = tamanho - 1
    li $t1, 0              # i = 0

bubble_i_loop:
    bge $t1, $t5, imprime

    sub $t6, $t0, $t1
    addi $t6, $t6, -1      # limite de j
    li $t2, 0              # j = 0

bubble_j_loop:
    bge $t2, $t6, prox_i

    sll $t7, $t2, 2
    addu $t3, $s0, $t7
    lw $t8, 0($t3)         # array[j]
    lw $t9, 4($t3)         # array[j+1]

    ble $t8, $t9, no_swap

    # Swap array[j] e array[j+1]
    sw $t9, 0($t3)
    sw $t8, 4($t3)

no_swap:
    addi $t2, $t2, 1
    j bubble_j_loop

prox_i:
    addi $t1, $t1, 1
    j bubble_i_loop

##############################
# Impressão dos elementos
##############################

imprime:
    li $v0, 4
    la $a0, result_msg
    syscall

    li $t1, 0             # inicializa o contador para imprimir notas

print_loop:
    bge $t1, $t0, retorno

    sll $t4, $t1, 2
    addu $t3, $s0, $t4
    lw $a0, 0($t3)

    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    addi $t1, $t1, 1
    j print_loop

##############################
# Retorno ao chamador
##############################

retorno:
    jr $ra
