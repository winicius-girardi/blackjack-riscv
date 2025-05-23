.data

availaible_cards:	.word 		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
player_wins:		.word 		0
dealer_wins:		.word		0
cards_in_play:		.word		0

dealer_cards:		.word		0, 0, 0, 0, 0, 0, 0, 0, 0, 0
index_cards_dealer:	.word		0
player_cards:		.word		0, 0, 0, 0, 0, 0, 0, 0, 0, 0  
index_cards_player:	.word		0


initial_greeting:	.string		"Bem vindo ao Blackjack!\n"
total_cards:		.string 	"\nTotal de cartas: "
dealer_points:		.string		"	Dealer: "
player_points:		.string		"	Jogador: "
ask_start_round:	.string		"\nDeseja Jogar? (1 - Sim, 0 - Não): "

.text



######################################################################################################################

#CREATE A RANDON INT BEETWEEN [1-13]
#RETURN GENERATED NUMBER IN A6
create_int_in_1_13:
	li a0, 1
	li a1, 13
	li a7, 42
	
	ecall
	add a6,zero,a0
	
	ret

	
	
######################################################################################################################
	
#RETURN A CARD FROM STACK IN REGISTER A6,
draw_card_from_pile:
	
	addi sp, sp, -4 
	sw ra, 0(sp) 
	
	la t1, availaible_cards
	
loop_draw_card:

	jal create_int_in_1_13	  	#A6 HAS THE NUMBER
	add t2, zero, a6
	slli a6,a6,2			#GET THE VALUE OF DISPLACEMENT BASED ON INDEX
		
	la t0, a6(t1)
	beq t0, zero, loop_draw_card	#IF EQUAL MEANS THAT THE CARD GENERATED HAS NO QUANTITY IN THE PILE 
	
	sub t0,t0,1			#DECREASE THE AVAILABLE CARD FROM PILE
	sw t0, a6(t1)
	
	add a6, zero, t2		#SET A6 WITH RETURN VALUE (VALID CARD NUMBER LIKE 1,2,3, ETC)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	
	ret	


######################################################################################################################



##DRAW CARD TO PLAYER, DEALER, PLAYER, DEALER
##SETUP THE MECANIC FOR HIT AND STAY

round_in_play:
	addi sp, sp, -4 
	sw ra, 0(sp) 
	
	jal draw_card_from_pile:
	slli t0, a6, 2 			# GET DISPLACEMENT


	


######################################################################################################################

start_round:

	# print asking the player if he wants to play a round or another round
	la a0, ask_start_round
	li a7, 4
	ecall 
	
	li a7, 5
	ecall 
	beq zero, a0, finish_game
	
	# guarda endereco p/ retorno
	addi sp, sp, -4 
	sw ra, 0(sp) 
	
	jal round_in_play
	
	# reescreve ra com endereco de retorno
	lw ra, 0(sp)
	addi, sp, sp, 4
	
	ret

######################################################################################################################



check_total_cards:
	
	la a0, total_cards
	li a1, 52
	li a2, 4
	
	lw t1, 0(a0)
	li t2, 40
	
	ble t1, t2, set_int_vector_by_value #write 4 in each index of vector  total_cards
	
	ret
	
	
######################################################################################################################
	
	
print_initial_greeting:
	la t0, initial_greeting
	li a7, 4
	ecall
	
	ret
	
	
	
######################################################################################################################


#GAME "CONTROLLER"
start_game:
	jal print_initial_greeting
	jal print_game_stats
	jal start_round # start a new round or end the match.
	


######################################################################################################################


finish_game:
	li a7,10
	ecall

######################################################################################################################


print_game_stats:
	
	la a0, total_cards
	li a7, 4
	ecall # exibe msg total de cartas
	
	la a0, cards_in_play 
	li a7, 1
	ecall  # exibe cartas disponiveis
	
	la a0, dealer_points
	li a7, 4
	ecall #exibe msg dealer
	
	la a0, dealer_wins
	li a7, 1
	ecall #exibe qtd vitorias dealer
	
	la a0, player_points
	li a7, 4
	ecall #exibe msg player
	
	la a0, player_wins
	li, a7, 1
	ecall #exibe qtd wins player
	
	ret
	
######################################################################################################################



add_win_player:
	
	la,t0, player_wins
	li t1, 1
	sw t1, 0(t0)
	
	ret
######################################################################################################################

#REFACTOR THAT 
caculate_availaible_cards:
	
	la t0, cards_in_play
	li t1, 0 # temp cards count	
	li t2, 0
	
	lw t2, 0(t0)
	add t1, t1, t2
	
	lw t2, 4(t0)
	add t1, t1, t2
	
	lw t2, 8(t0)
	add t1, t1, t2
	
	lw t2, 12(t0)
	add t1, t1, t2
	
	lw t2, 16(t0)
	add t1, t1, t2
	
	lw t2, 20(t0)
	add t1, t1, t2
	
	lw t2, 24(t0)
	add t1, t1, t2
	
	lw t2, 28(t0)
	add t1, t1, t2
	
	lw t2, 32(t0)
	add t1, t1, t2
	
	lw t2, 36(t0)
	add t1, t1, t2
	
	lw t2, 40(t0)
	add t1, t1, t2
	
	lw t2, 44(t0)
	add t1, t1, t2
	
	lw t2, 48(t0)
	add t1, t1, t2
	
	la t0, cards_in_play
	sw t1, 0(t0)
	
	ret
	
######################################################################################################################


# index_cards_player player_cards index_cards_dealer dealer_cards
reset_card_hands:

	addi sp, sp, -4 
	sw ra, 0(sp) 
	li a2, 0
	
	#RESET PLAYER HAND
	la a0, player_cards
	la a1, index_cards_player
	slli t2,t2,2
	jal set_int_vector_by_value
	
	#RESET DEALER HAND
	la a0,dealer_cards
	la a1, index_cards_dealer
	slli t2,t2,2
	jal set_int_vector_by_value
	 
	 
	#RESET INDEX OF CARDS FOR DEALER AND PLAYER
	la t1, index_cards_player
	sw zero, 0(t1)
	la t1, index_cards_dealer
	sw zero, 0(t1)
	
	lw ra, 0(sp)
	addi, sp, sp, 4
	
	ret 

 ######################################################################################################################	 
	
#RECEIVE IN 
#A0 A ADDRESS ( INITIAL )
#A1 THE DISPLACEMENT
#A2 THE VALUE TO BE WRITTEN
set_int_vector_by_value:

	li t0, 0
	
loop_set_vector:
	
	beq t0,a1, return_set_vector
	sw a2,t0 (a0)
	addi t0, t0, 4
	j loop_set_vector

return_set_vector:
	ret
		

######################################################################################################################

#CHANGE THAT TO USE SET_INT_VECTOR_BY_VALUE BECAUSE IN THE SAME THING
#reset_cards_pile:
	
#	li t1, 4
#	la t0, availaible_cards
	
#	sw t1, 0(t0)
#	sw t1, 4(t0)
#	sw t1, 8(t0)
#	sw t1, 12(t0)
#	
#	sw t1, 16(t0)
#	sw t1, 20(t0)
#	sw t1, 24(t0)
#	sw t1, 28(t0)
#	
#	sw t1, 32(t0)
#	sw t1, 36(t0)
#	sw t1, 40(t0)
#	sw t1, 44(t0)
#	
#	sw t1, 48(t0)
#	
#	ret
	
