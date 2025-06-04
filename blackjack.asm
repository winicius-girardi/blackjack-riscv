.data

availaible_cards:	.word 		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
player_wins:		.word 		0
dealer_wins:		.word		0
cards_in_play:		.word		0

dealer_cards:		.word		0, 0, 0, 0, 0, 0, 0, 0, 0, 0
index_cards_dealer:	.word		0
player_cards:		.word		0, 0, 0, 0, 0, 0, 0, 0, 0, 0  
index_cards_player:	.word		0
player_point_r:		.word 		0 						# STORE POINT OF HAND IN THE ROUND FOR PLAYER
dealer_point_r:		.word		0						# STORE POINT OF HAND IN THE ROUND FOR DEALER

initial_greeting:	.string		"Bem vindo ao Blackjack!\n"
total_cards:		.string 	"\nTotal de cartas: "
dealer_points:		.string		"	Dealer: "
player_points:		.string		"	Jogador: "
ask_start_round:	.string		"\nDeseja Jogar? (1 - Sim, 0 - Não): "

.text


######################################################################################################################
#
# ENTRYPOINT OF THE GAME
#
main:

	jal start_game

######################################################################################################################
#
# CALCULATE THE VALUE OF A HAND
# RECEIVE IN A3 WHICH PLAYER IS THE "TARGER"
# A3 -> 1 DEALER
# A3 -> 0 PLAYER
# THEN SET THE  THE DEALER_POINT_R  / PLAYER_POINT_R
#
calc_points_hand:

	addi sp, sp, -4 
	sw ra, 0(sp) 
	
	li t6, 1					# temp to control if there a a's in the hand -> if t6=0 there no a's else there a a's
	add t0, zero, zero				# temp to store value for the sum of cards
	add t3, zero, zero				# offset for loop
	beq a3,zero, set_ad_player
	j set_ad_dealer
	
loop_calc:

	li t5, 10
	beq t3, t2 ret_calc	
	lw  t4, t3(t1)  				# ADD HERE MECANISM TO CONTROL HOW A WORKS
	beq t6, t4, a_handler				# CHECK IF T4 IS A A'S
	beq t5, t4, g_than_ten_handler

g_than_ten_handler:
	li t4, 10
	j sum_calc	

sum_calc:

	add  t0, t0, t4
	addi t3, t3, 4
	j loop_calc

a_handler:

	addi t4, t4, 10
	li   t6, -1
	j sum_calc


rem_point_a:						# Remove 10 from a6
	li  t5, -1
	bne t6, t5, ret_calc_f				# if not equal mean that there no a's in hand  
	li  t5, 10
	sub a6, a6, t5
 	j   ret_calc_f

	

ret_calc:
	
	add a6, zero, t6
	li t5, 21
	bgt a6, t5, rem_point_a
		
ret_calc_f:

	li t5, 1
	beq a3, t5, store_p_dealer
	j store_p_player

ret_calc_s:
	
	lw ra, 0(sp)
	addi sp, sp, 4
 
	
	ret

store_p_dealer:

	sw a6, dealer_point_r
	j ret_calc_s

store_p_player:

	sw a6, player_point_r
	j ret_calc_s


set_ad_player:
	
	la t1, player_cards
	lw t2, index_cards_player
	slli t3, t2, 2 					# OFFSET TO CONTROL LOOP
	
	j loop_calc

set_ad_dealer:

	la t1, dealer_cards
	lw t2, index_cards_dealer
	slli t3, t2, 2					# OFFSET TO CONTROL LOOP	
	
	j loop_calc

#a_checker


######################################################################################################################
#
# CALL FUNCTION FOR ALL STEPS TO DRAW A CARD TO DEALER
#
draw_card_dealer:

	
	addi sp, sp, -4 
	sw ra, 0(sp) 
	
	
	jal draw_card_from_pile
	add a6, a2, zero
	addi a3, zero, 1		# 
	jal store_card_in_hand
	
	
	lw ra, 0(sp)
	addi sp, sp, 4
 

	ret
######################################################################################################################
#
# CALL FUNCTION FOR ALL STEPS TO DRAW A CARD TO PLAYER
#
draw_card_player:


	addi sp, sp, -4 
	sw ra, 0(sp) 
	
	jal draw_card_from_pile
	add a6, a2, zero
	addi a3, zero, 0		
	jal store_card_in_hand
	
	lw ra, 0(sp)
	addi sp, sp, 4

	ret
	
######################################################################################################################
#
# ADDED A CARD TO A PLAYER HAND 
# RECEIVE IN A3 WHICH PLAYER IN PLAYING
# A3=1 -> DEALER
# A3=0 -> PLAYER
#
# RECEIVE A NUMBER OF A CARD TO ADDED TO THE VECTOR (PLAYER_CARDS OR DEALER_CARDS) IN A2
#
store_card_in_hand:
	
	lw t1, 0(a1) 			# LOAD INDEX
	slli t0, t1, 2 			# GET DISPLACEMENT
	sw a2, a0(t0) 			# STORE CARD IN HAND 

	
	addi t1, t1, 1
	sw t1, 0(a1)			# UPDATE INDEX
	
	ret

######################################################################################################################
#
#CREATE A RANDON INT BEETWEEN [1-13]
#RETURN GENERATED NUMBER IN A6
#
create_int_in_1_13:
	
	li a0, 1
	li a1, 13
	li a7, 42
	ecall
	
	add a6,zero,a0
	
	ret

######################################################################################################################
#	
#RETURN A VALID CARD FROM STACK IN REGISTER A6 (return a  number in range [1-13]),
#
draw_card_from_pile:
	
	addi sp, sp, -4 
	sw   ra, 0(sp) 
	
	la   t1, availaible_cards
	
loop_draw_card:

	jal  create_int_in_1_13	  	#A6 HAS THE NUMBER
	add  t2, zero, a6
	slli a6,a6,2			#GET THE VALUE OF DISPLACEMENT BASED ON INDEX
		
	la   t0, a6(t1)
	beq  t0, zero, loop_draw_card	#IF EQUAL MEANS THAT THE CARD GENERATED HAS NO QUANTITY IN THE PILE 
	
	sub  t0,t0,1			#DECREASE THE AVAILABLE CARD FROM PILE
	sw   t0, a6(t1)
	
	add  a6, zero, t2		#SET A6 WITH RETURN VALUE (VALID CARD NUMBER LIKE 1,2,3, ETC)
	
	lw   ra, 0(sp)
	addi sp, sp, 4
	
	ret	
	
######################################################################################################################
#
# IMPLEMENT HIT/STAY MECANIC FOR A PLAYER
#
# return a flag if the player pass 21 in a6
# if a6 -> 0 no
# if a6 -> 1 yes
#
hit_stay_player:
	
	addi sp, sp, -4 
	sw   ra, 0 (sp) 
	
loop_hit_stay_player:
	
        la   a0, player_point_r
	lw   t1, 0 (a0)
	li   t2, 21
	bge  t1, t2, hit_stay_ret_1
	


hit_stay_ret_1:
	
	bgt t1, t2, set_over_limit_player
	li a6, 0


hit_stay_ret_2:
	
	lw ra, 0(sp)
	addi, sp, sp, 4
	
	ret


set_over_limit_player:

	li a6, 1
	j hit_stay_ret_2
	
######################################################################################################################
#
# CONTROL ASPECT OF THE ROUND IN PLAY
# DRAW CARDS FOR BOTH PLAYERS
# CALL HIT/STAND MECANICS
# WILL HANDLER WHICH WAS THE WINNER (DEALER/PLAYER)
#
round_in_play:

	addi sp, sp, -4 
	sw ra, 0(sp) 
	
	jal draw_card_player
	jal draw_card_dealer
	jal draw_card_player
	jal draw_card_dealer
	
	li  a3, 1
	jal calc_points_hand
	li  a3, 0
	jal calc_points_hand
	

	jal hit_stay_player 			# return a flag of player to check if was greater than 21
	bne a6, zero, dealer_win 		## TODO -> CHECK HOW THIS WILL WORK
	 
	jal hit_stay_dealer			# return a flag of dealer to check if was greater than 21
	bne a6, zero, player_win		## TODO -> CHECK HOW THIS WILL WORK
	
	jal check_winner			# check winner, print stats? att scores, restart round/want to play again

	lw ra, 0(sp)
	addi, sp, sp, 4
	
	ret


######################################################################################################################
#
# CONTROL ROUNDS FOR THE GAME
#  ASK THE PLAYER IF HE WANTS TO PLAY AGAIN
# IF TRUE THEN START A NEW ROUND.
# IF FALSE THEN WILL "START" THE FINISHING STEPS FOR THE GAME (DISPLAY FINAL STATS)
#
control_round_game:

	addi sp, sp, -4 
	sw ra, 0(sp) 

loop_round:

	la a0, ask_start_round			# print asking the player if he wants to play a round or another round
	li a7, 4
	ecall 
	li a7, 5
	ecall
	
	  
	beq zero, a0, start_round_ret		 
	
	
	jal round_in_play
	
	j loop_round 			# check how this will work because we have to display stats after the round finishes
				

	
start_round_ret:

	lw ra, 0(sp)
	addi, sp, sp, 4
	
	ret

######################################################################################################################
#
# COUNT THE CARDS IN THE GAME IS IN THE PILE
# IF LESS THE 40, RESET THE PILE
#
check_total_cards:
	
	la a0, total_cards
	li a1, 52
	li a2, 4
	
	lw t1, 0(a0)
	li t2, 40
	
	ble t1, t2, set_int_vector_by_value #write 4 in each index of vector  total_cards
	
	ret
	
	
######################################################################################################################
#	
# INITIAL GREETING FOR THE GAME
#	
print_initial_greeting:
	la t0, initial_greeting
	li a7, 4
	ecall
	
	ret
	
	
	
######################################################################################################################
#
# GAME CONTROLLER TO CALL EACH MODULE FOR THE GAME
#
start_game:

	jal print_initial_greeting
	jal print_game_stats
	jal control_round_game
	#jal start_round # start a new round or end the match.
			# print the winner of a rounds?	
	
	#jal print_game_stats_final # check this how will work
	
	j finish_game
	

######################################################################################################################
#
# END PROGRAM EXECUTION
#
finish_game:

	li a7,10
	ecall

######################################################################################################################
#
# PRINT STATS FOR THE GAME IN THE CURRENT MATCH AFTER A ROUND? 
# TODO -> CHECK HOW THIS WILL WORK
#
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
# 
# TODO -> TEST THAT
#
add_win_player:
	
	la t1, player_wins
	lw,t0, 0(t1)
	addi t0, t0, 1
	sw t0, 0(t1)
	
	ret
	
######################################################################################################################
#
# REFACTOR THAT 
# COUNT HOW  MANY CARDS IS IN A PILE
#
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
#
# RESET VARIABLES IN MEMORY USED TO CONTROL VALUES IN A ROUND
# VARIABLES RESET: index_cards_player player_cards index_cards_dealer dealer_cards
#
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

#######################################################################################################################	 
#
# FILL A VECTOR WITH A VALUE RECEIVE BY PARAMETER
# RECEIVE IN 
# A0 A ADDRESS OF VECTOR ( INITIAL )
# A1 THE DISPLACEMENT (length)
# A2 THE VALUE TO BE WRITTEN IN THE VECTOR
#
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
#  this code here wont be used
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
	
