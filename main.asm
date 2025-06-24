# Arquivo principal, atua como um gerenciador da aplicação
# direcionando o usuário para diferentes funcionalidades da aplicação.
.data
menu_msg:     .asciiz "\nEscolha uma funcionalidade:\n1 - Ordenar Notas (Bubble Sort)\n2 - Número de Catalan\n3 - Flappy Bird\n4 - Triangulação\n\nDigite sua escolha: "
op_invalida:  .asciiz "Opção inválida. Encerrando...\n"
newline:      .asciiz "\n"

.text
.globl main

main:
    # Exibe o menu
    li $v0, 4
    la $a0, menu_msg
    syscall

    # Lê a escolha do usuário
    li $v0, 5
    syscall
    move $t0, $v0        # $t0 = opção escolhida

    # Verifica opção 1
    li $t1, 1
    beq $t0, $t1, chama_bubble_sort

    # Verifica opção 2
    li $t1, 2
    beq $t0, $t1, chama_catalan

    # Verificação opção 3
    li $t1, 3
    beq $t0, $t1, chama_flappybird

    # Verifica opção 4
    li $t1, 4
    beq $t0, $t1, chama_triangular

    # Caso inválido
    li $v0, 4
    la $a0, op_invalida
    syscall
    j fim

##############################
# Chamada da funções auxiliares
##############################
chama_bubble_sort:
    jal bubble_sort_entry
    j fim

chama_catalan:
    jal catalan_entry
    j fim

chama_flappybird:
    jal flappybird_entry
    j fim

chama_triangular:
    jal triangular_entry
    j fim

##############################
# Fim do programa
##############################

fim:
    li $v0, 10
    syscall
