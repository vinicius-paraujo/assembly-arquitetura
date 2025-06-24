# Tamanho do display: 256x256. largura do pixel:8  endereco:0x10040000 (heap)
# Conecte também o MMIO keyboard 
# Aperte espaço para pular
# O programa recebe um input do teclado do usuário (tecla espaço) e faz o passaro voar
.data
frame_buffer: .word 0x10040000
x_pos: .word 5
y_pos: .word 5
jump_force: .word 3
x_cactus: .word 30
y_upper_cactus: .word 10
cactus_gap: .word 8
y_down_cactus: .word 16 # y+gap
points_text: .asciiz "Sua pontuação: "
points: .word 0
colors:
	.word 0xFF15BFE6 #Cor do ceu 
	.word 0xFFF25405 #Cor do pássaro
	.word 0xFFFCA103 #cor da tela de morte
	.word 0xFF0DFF19
.text
.globl flappybird_entry
flappybird_entry:
	li $a2, 0
	li $a1,0
	jal clean_screen
	gameloop:
#		jal clean_screen
		
		
		#Limpa passaro e cacto
		lw $a0, x_pos 
		lw $a1, y_pos 
		li $a2, 0
		jal draw_pixel
		li $t6, 31
		bgt $a1, $t6, exit
		
		li $a3,0
		jal draw_cactus
		
		
		#------ input
		# Verifica se tecla foi pressionada
		li $t0, 0xFFFF0000   # endereço do flag "tecla pronta"
		lb $t1, 0($t0) #vai resolver o ponteiro do teclado
		
		#if keys != null
		# Se chegou aqui, tem tecla
		li $t0, 0xFFFF0004   # endereço da tecla
		lb $t3, 0($t0)       # carrega o valor ASCII da tecla
	
		# Verifica se tecla é ESC (27)
		li $t4, 27
		beq $t3, $t4, exit
		
		beqz $t1, dont_jump
		# verifica se a tecla é ESPAÇO
		li $t4, 32 
		bne $t3, $t4, dont_jump # se ESPACO:
					#     Pula
					# se nao
					#     Passa
		 lw $t5, y_pos
		jump:
			lw $t6, jump_force
			sub $t5, $t5, $t6
			sw $t5, y_pos
			
			j dont_update_gravity
		dont_jump:
			lw $t5, y_pos
			addi $t5, $t5, 1
			sw $t5, y_pos
		dont_update_gravity:
		
		
		#------- input
		
		
		#---------

		
		
		lw $a1, y_pos
		lw $a0, x_pos
		li $a2, 1
		jal draw_pixel
		
		jal check_collision
		jal update_cactus_pos
		li $a3,3
		jal draw_cactus
		
		
		
		dont_draw_bird:
		
		li $a1, 66
		jal sleep
		j gameloop
	

exit:

	# motra o pontos 
	la $a0, points_text
	li $v0, 4
	syscall
	lw $a0, points
	li $v0, 1
	syscall
	#sai
	li $a2, 2
	li $a1, 1
	jal clean_screen
	
      	li $v0, 10     # encerra programa
	syscall
# a1 = sleep
sleep:
	addi $v0, $zero, 32  # chamada da função sleep 
	add $a0, $zero, $a1  # espera  ms
	syscall
	jr $ra
	
	
	

# $a0=x $a1=y
calculate_addres:
	li $v0, 0x10040000
	
	#endereco = 0x10040000 + 4x + 4y*32
	sll $t2, $a0, 2 #t2 = 4x
	sll $t3, $a1, 7 #t3 = y*32 *4  := 2⁷
	add $v0, $v0, $t2 # adiciona x no offset do display
	add $v0, $v0, $t3 # adiciona y no offset do display
	
	jr  $ra
	
# $a2 = numero da cor (0-2)
get_color:
	la $t0, colors
	sll $a2, $a2, 2 #multiplica por 4, tamanho da palavra
	add $a2, $a2, $t0 #adiciona o tamanho da cor no endereco base de colors
	lw $v1, 0($a2)
	
	
	jr $ra


# $a0=x $a1=y #a2=indice da cor [0-1]
draw_pixel:
		bltz $a0, done_drawing_dot #se x < 0
		bltz $a1, done_drawing_dot #se y < 0
		bgt $a0,31, done_drawing_dot #se x > 31
		bgt $a1, 31,done_drawing_dot #se y>31
	
		addi $sp, $sp, -4
		sw $ra,0($sp)  #aloca um espaco de 4 na pilha de execução
	 	
		jal calculate_addres
		jal get_color
	
		sw $v1, 0($v0)
	
		lw $ra, 0($sp)
		addi $sp, $sp,4
	
		done_drawing_dot:
			jr $ra
	
#a1 = sleep $a2 = cor
clean_screen:
    		addi $sp, $sp, -12   # aloca espaço na pilha $ra, $s0 (linha), $s1 (col)
    		sw $ra, 8($sp)      # Salva endereço de retorno
    		sw $s0, 4($sp)      
    		sw $s1, 0($sp)      
    		move $t6, $a2
    		move $t5, $a1
    		li $s0, 0           # Inicializa a linha (y) 
clean_screen_row_loop:
   		li $s1, 0           # Inicializa coluna (x)
clean_screen_col_loop:
    		move $a0, $s1       
    		move $a1, $s0       
    		move $a2, $t6
    		jal draw_pixel
    		move $a1,$t5
    		jal sleep
    		addi $s1, $s1, 1    # Incrementa coluna
    		blt $s1, 32, clean_screen_col_loop # se coluna < 32, ccontinua pra prox col

    		addi $s0, $s0, 1    #incrementa
    		blt $s0, 32, clean_screen_row_loop # Se linha < 32, continua pra proxima linha

    		lw $ra, 8($sp)      # Restaura o endereço de retorno
    		lw $s0, 4($sp)     
		lw $s1, 0($sp)     
    		addi $sp, $sp, 12   # Desaloca espaço da pilha
   		jr $ra              # retorno
  

# $a0= x $a1=y1 $a2=y2 $a3=indice da cor
draw_line:
    addi $sp, $sp, -4
    sw $ra, 0($sp)       # salva retorno

    move $s2, $a0
    move $s3, $a1
    move $s4, $a2

loop_y:
    bgt $s3, $s4, exit_loop_y

    move $a0, $s2
    move $a1, $s3
    move $a2, $a3
    jal draw_pixel

    addi $s3, $s3, 1
    j loop_y

exit_loop_y:
    lw $ra, 0($sp)       # restaura retorno
    addi $sp, $sp, 4
    jr $ra

		
		

draw_cactus:
	addi $sp, $sp, -4      # Aloca espaço na pilha
	sw $ra, 0($sp)         # Salva o valor de $ra
	
	lw $t1, x_cactus       # Carrega x do cacto
	move $a0, $t1          # x
	
	li $a1, 0              # y inicial
	lw $a2, y_upper_cactus # y final
	

	bgtz $t1, l
	li $t1, 31
	sw $t1, x_cactus
	#define uma nova altura pro y1
	li $a1, 23
	li $v0, 42 #gera um numero aleatorio
	syscall
	li $t0, 23 #limite superior
	remu $t4,$a0, $t0
	sw $t4, y_upper_cactus 
	move $a2, $t4
#	li $t1, 31
	move $a0, $t1
	
	l:
	jal draw_line          # Chama função que usa jal internamente
		
	lw $t1, x_cactus       # Carrega x do cacto
	move $a0, $t1          # x
	lw $t3,y_upper_cactus
	lw $t4, cactus_gap
	add $t4, $t4, $t3
	sw $t4, y_down_cactus
	move $a1, $t4              # y inicial
	li $a2, 31 # y final
	
	jal draw_line 
	
	
	
	lw $ra, 0($sp)         # Recupera valor original de $ra
	addi $sp, $sp, 4       # Libera espaço da pilha
	jr $ra                 # Retorna corretamente
	

update_cactus_pos:

	lw $t1, x_cactus
	subi $t1, $t1,1
	sw $t1, x_cactus 
	
	jr $ra
	
	
	
check_collision:
	lw $t1, x_pos
	lw $t2, y_pos
	lw $t3, y_upper_cactus
	lw $t4, y_down_cactus
	lw $t5, x_cactus 
	
	beq $t1, $t5, check #se a torre esta no mesmo x ou pasou o pasaro
	jr $ra
	
	check:
		bgt $t2, $t3, check_collision_lower
		#check colliion uper
		j exit
		
		check_collision_lower:
			blt $t2, $t4, no_collision
			j exit
		no_collision:
			#incrementa os pontos
			lw $t6, points 
			addi $t6, $t6, 1
			sw $t6, points 
			jr $ra
		
		
