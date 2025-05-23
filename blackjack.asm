.data

availaible_cards:	.word 		4,4,4,4,4,4,4,4,4,4,4,4,4
player_wins:		.word 		0
dealer_wins:		;word		0
cards_in_play		:word		0

initial_greeting:	.string		"Bem vindo ao Blackjack!\n"
total_cards:		.string 	"\nTotal de cartas: "
dealer_points:		.string		"	Dealer: "
player_points:		.string		"	Jogador: "
ask_start_round:	.string		"\nDeseja Jogar? (1 - Sim, 2 - Não): "

.text

round_in_play:

	



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

check_total_cards:

	la t0, total_cards
	lw t1, 0(total_cards)
	li t2, 40
	ble t1, t2, reset_cards_pile # maybe change how this work(because possible conflict with jals in sequence), but the idea is to reset if total_cards is equal/less than 40
	ret
	
print_initial_greeting:
	la t0, initial_greeting
	li a7, 4
	ecall
	
	ret
	
start_game:
	jal print_initial_greeting
	jal print_game_stats
	jal start_round # returns a value in a6, if 1 start a round, if 0 ends the game
	


finish_game:
	li a7,10
	ecall


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
	


add_win_player:
	
	la,t0, player_wins
	li t1, 1
	sw t1, 0(t0)
	
	ret

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
	add t1,t1,t2
	
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
	

reset_cards_pile:
	
	li t1, 4
	la t0, availaible_cards
	
	sw t1, 0(t0)
	sw t1, 4(t0)
	sw t1, 8(t0)
	sw t1, 12(t0)
	
	sw t1, 16(t0)
	sw t1, 20(t0)
	sw t1, 24(t0)
	sw t1, 28(t0)
	
	sw t1, 32(t0)
	sw t1, 36(t0)
	sw t1, 40(t0)
	sw t1, 44(t0)
	
	sw t1, 48(t0)
	
	ret
	