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

initial_greeting:	.asciz		"Bem vindo ao Blackjack!\n"
total_cards:		.asciz	 	"\nTotal de cartas: "
dealer_points:		.asciz		"	Dealer: "
player_points_msg:	.asciz		"	\n	Jogador: "
ask_start_round:	.asciz		"\nDeseja Jogar? (1 - Sim, 0 - Não): "
player_draw_msg:	.asciz		"\nO jogador comprou a carta: "
dealer_draw_msg:	.asciz		"\nO dealer comprou a carta: "
dealer_hidden_msg:	.asciz		" e uma carta oculta.\n"
comma_space:		.asciz		 ", "
newline:		.asciz		 "\n"
hit_stay_msg:		.asciz		"\nO que você deseja fazer? (1 - Hit, 2 - Stand): "
colon_space: 		.asciz 		" : "
dealer_hit_msg:  	.asciz 		"\nDealer compra uma carta.\n"
dealer_stand_msg: 	.asciz 		"\nDealer decide ficar.\n"
msg_player_wins:   	.asciz 		"\n>>> Jogador venceu o round!\n"
msg_dealer_wins:   	.asciz 		"\n>>> Dealer venceu o round!\n"
msg_draw:          	.asciz 		"\n>>> Empate no round!\n"
wins_msg:		.asciz 		"\nVitorias:\n\n"

.text


######################################################################################################################
#
# ENTRYPOINT OF THE GAME
#
main:

	jal start_game
	
######################################################################################################################
#
# SHOW THE DEALER HAND WHEN HE IS PLAYING (DRAWING CARDS)
#
show_dealer_hand_only:

    addi sp, sp, -4
    sw ra, 0(sp)

    la a0, dealer_points        
    li a7, 4
    ecall

    la t0, dealer_cards
    lw t1, index_cards_dealer
    li t2, 0

show_dealer_loop:

    bge t2, t1, show_dealer_total

    slli t3, t2, 2
    add t4, t0, t3
    lw a0, 0(t4)
    beq a0, zero, skip_zero_d

    li a7, 1
    ecall

    addi t2, t2, 1
    bge t2, t1, skip_comma_d

    la a0, comma_space
    li a7, 4
    ecall

skip_comma_d:

    j show_dealer_loop

skip_zero_d:

    addi t2, t2, 1
    j show_dealer_loop

show_dealer_total:

    la a0, colon_space
    li a7, 4
    ecall

    la a0, dealer_point_r
    lw a0, 0(a0)
    li a7, 1
    ecall

    la a0, newline
    li a7, 4
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    ret


######################################################################################################################
#
# GAME CONTROLLER TO CALL EACH MODULE FOR THE GAME
#
start_game:
	
	jal print_initial_greeting

	jal control_round_game

	jal print_final_score

	j finish_game
	
######################################################################################################################
#
# CLEAR TRASH VALUES IN MEMORY WHEN THE GAME STARTS
#
clear_trash_f_memory:

	addi sp, sp, -4 
	sw ra, 0(sp) 
	li a2, 0
	
	la t1, player_wins
	sw zero, (t1)
	
	la t1, dealer_wins
	sw zero, (t1)
	
	la t1, player_point_r
	sw zero, (t1)
	
	la t1, dealer_point_r
	sw zero, (t1)
	
	la t1, cards_in_play
	sw zero, (t1)
	
	
	la a0, availaible_cards
	li a1, 13
	slli a1,a1,2
	jal set_int_vector_by_value
	
	
	#RESET PLAYER HAND
	la a0, player_cards
	li a1, 13
	slli a1,a1,2
	jal set_int_vector_by_value
	
	#RESET DEALER HAND
	la a0,dealer_cards
	li a1, 13
	slli a1,a1,2
	jal set_int_vector_by_value
	 
	 
	#RESET INDEX OF CARDS FOR DEALER AND PLAYER
	la t1, index_cards_player
	sw zero, 0(t1)
	la t1, index_cards_dealer
	sw zero, 0(t1)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	
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

	la a0, ask_start_round			
	li a7, 4
	ecall 
	
	li a7, 5
	ecall
		  
	beq zero, a0, start_round_ret		
	
	jal round_in_play
	
	j loop_round 			
				
start_round_ret:

	lw ra, 0(sp)
	addi sp, sp, 4
	
	ret

######################################################################################################################
#
# CALCULATE THE VALUE OF A HAND
# RECEIVE IN A3 WHICH PLAYER IS THE "TARGET"
# A3 -> 1 DEALER
# A3 -> 0 PLAYER
# THEN SET THE  THE DEALER_POINT_R  / PLAYER_POINT_R
#
calc_points_hand:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)          # salva s0 porque vai usar

    li t3, 0              # índice da carta
    li t0, 0              # soma total das cartas
    li s0, 0              # contador de ases

    beq a3, zero, set_ad_player
    j set_ad_dealer

loop_calc:

    bge t3, t2, end_calc

    slli t4, t3, 2
    add t5, t1, t4
    lw t6, 0(t5)          # carrega carta em t6

    li t4, 10
    blt t6, t4, not_face_card
    li t6, 10             # cartas > 10 valem 10

not_face_card:

    li t4, 1
    beq t6, t4, is_ace

    add t0, t0, t6
    addi t3, t3, 1
    j loop_calc

is_ace:

    addi t0, t0, 11
    addi t3, t3, 1
    addi s0, s0, 1        # incrementa contador de ases
    j loop_calc

end_calc:


adjust_aces:

    li t4, 21
    ble t0, t4, store_points
    beqz s0, store_points
    addi t0, t0, -10
    addi s0, s0, -1
    j adjust_aces

store_points:

    beq a3, zero, store_p_player
    j store_p_dealer

store_p_player:

    la t1, player_point_r
    sw t0, 0(t1)
    j ret_calc_s

store_p_dealer:

    la t1, dealer_point_r
    sw t0, 0(t1)
    j ret_calc_s

ret_calc_s:

    lw s0, 4(sp)         
    lw ra, 0(sp)
    addi sp, sp, 8
    ret

set_ad_player:

    la t1, player_cards
    lw t2, index_cards_player
    j loop_calc

set_ad_dealer:

    la t1, dealer_cards
    lw t2, index_cards_dealer
    j loop_calc

######################################################################################################################
#
# CALL FUNCTION FOR ALL STEPS TO DRAW A CARD TO DEALER
#
draw_card_dealer:
	
	addi sp, sp, -4 
	sw ra, 0(sp) 
	
	jal draw_card_from_pile
	add a2, a6, zero
	li a3, 1
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
	add a2, a6, zero

	li  a3, 0		
	jal store_card_in_hand
	
	lw ra, 0(sp)
	addi sp, sp, 4

	ret
	
######################################################################################################################
#
# SHOW CARD THAT WAS DRAWN TO DE ALER/PLAYER
# RECEIVE IN A3 WHICH WAS PLAYING 
#	0 -> DEALER
#	1 -> PLAYER
# RECEIVE IN A2 THE CARD TO DISPLAY.
display_card_draw:

	beq zero, a3, dc_draw_dealer
	j dc_draw_player

dc_print_card:
	li a7, 4
	ecall
	
	li a7, 1
	add a0,zero,a2
	ecall
	ret

dc_draw_dealer:

	la a0,dealer_draw_msg
	j dc_print_card
	
dc_draw_player:

	la a0,player_draw_msg
	j dc_print_card

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

	beq zero, a3, sc_player
	j sc_dealer
	
sc_hand_start:

	lw t1, 0(a1) 			
	slli t0, t1, 2 			
	add s1, a0,t0
	sw a2, 0(s1) 			
	j sc_ret

sc_dealer:

	la a0, dealer_cards
	la a1, index_cards_dealer
	j sc_hand_start
	
sc_player:
	
	la a0, player_cards
	la a1, index_cards_player
	j sc_hand_start	
	
sc_ret:

	addi t1, t1, 1
	sw t1, 0(a1)			
	
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
	addi a6, a6, -1
	slli a6, a6, 2			#GET THE VALUE OF DISPLACEMENT BASED ON INDEX
		
	add  s1, a6, t1
	lw   t0, 0 (s1)
	beq  t0, zero, loop_draw_card	#IF EQUAL MEANS THAT THE CARD GENERATED HAS NO QUANTITY IN THE PILE 
	
	addi t0,t0,-1			#DECREASE THE AVAILABLE CARD FROM PILE
	add s1, a6,t1
	sw   t0, 0(s1)
	
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

    addi sp, sp, -8
    sw ra, 0(sp)
    sw t0, 4(sp)          

    li t0, 0               

loop_hit_stay_player:
    beqz t0, skip_show_hand
    jal show_player_hand_only

skip_show_hand:

    li t0, 1               
    sw t0, 4(sp)           

    jal show_hit_stay
    li a7, 5
    ecall

    li t1, 1
    beq a0, t1, do_hit_player

    li a6, 0
    j hit_stay_player_exit

do_hit_player:

    jal draw_card_player
    add a2, a6, zero
    li a3, 1
    jal display_card_draw

    li a3, 0
    jal calc_points_hand

    la a0, player_point_r
    lw t1, 0(a0)
    li t2, 21
    bgt t1, t2, player_busted

    j loop_hit_stay_player

player_busted:

    li a6, 1

hit_stay_player_exit:

    lw t0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8
    ret


######################################################################################################################
#
# SHOW PLAYER HAND ON HIT/STAY
#
show_player_hand_only:

    addi sp, sp, -4
    sw ra, 0(sp)

    la a0, player_points_msg     
    li a7, 4
    ecall

    la t0, player_cards
    lw t1, index_cards_player
    li t2, 0

show_hand_loop:

    bge t2, t1, show_hand_total

    slli t3, t2, 2
    add t4, t0, t3
    lw a0, 0(t4)
    li a7, 1
    ecall

    addi t2, t2, 1
    bge t2, t1, show_hand_total

    la a0, comma_space
    li a7, 4
    ecall
    j show_hand_loop

show_hand_total:

    la a0, colon_space
    li a7, 4
    ecall

    la a0, player_point_r
    lw a0, 0(a0)
    li a7, 1
    ecall

    la a0, newline
    li a7, 4
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    ret


######################################################################################################################
# 
# HIT/STAY FOR DEALER. HE WILL DRAW UNTIL HIS HANDS MATCH THE PLAYER HAND (DRAW OR GREATER) AND WHEN HIS POINTS ARE AT LEAST 17
#
hit_stay_dealer:
    
    addi sp, sp, -4
    sw ra, 0(sp)

    la a0, player_point_r
    lw t2, 0(a0)            
    
loop_hit_dealer:
    
    la a0, dealer_point_r
    lw t1, 0(a0)           

    li t3, 17
    bge t1, t3, check_against_player

    j do_dealer_hit

check_against_player:

    bge t1, t2, dealer_stop

do_dealer_hit:

    jal draw_card_dealer        
    add a2, a6, zero            
    li  a3, 0                   
    jal display_card_draw       

    li  a3, 1                   
    jal calc_points_hand

    jal show_dealer_hand_only

    la a0, dealer_point_r
    lw t1, 0(a0)

    li t3, 21
    bgt t1, t3, dealer_busted

    j loop_hit_dealer

dealer_busted:

    li a6, 1
    j hit_stay_dealer_exit

dealer_stop:

    la a0, dealer_stand_msg        
    li a7, 4
    ecall
    li a6, 0

hit_stay_dealer_exit:

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

######################################################################################################################
#
# CHECK WINNER FOR CURRENT ROUND AND ADD THE POINT TO THE WINNER OF THE CURRENT ROUND
#
check_winner:

    lw t1, dealer_point_r
    lw t2, player_point_r

    li t0, 21
    bgt t1, t0, player_win     
    bgt t2, t0, dealer_win     

    bgt t1, t2, dealer_win     
    blt t1, t2, player_win     

    j draw

draw:

    la a0, msg_draw
    li a7, 4
    ecall
    j round_in_play_ret


######################################################################################################################
#
# SHOW MSG HIDDEN CARD FOR DEALER
#
show_msg_hidden_dealer:
	
	la a0, dealer_hidden_msg
	li a7, 4
	ecall 
	ret
	
########################################################################################################
# 
# SHOW PLAYER AND DEALER HAND AND THEN SHOW THE POINTS FOR LIKE THIS:
# 	Jogador: 2, 5 : 7
# 	Dealer: 10 e uma carta oculta.
#
show_both_hands:
    
    addi sp, sp, -4
    sw ra, 0(sp)

    la a0, player_points_msg     
    li a7, 4
    ecall

    la t0, player_cards
    lw t1, index_cards_player
    li t2, 0                     

print_player_cards:
    
    bge t2, t1, print_colon_total

    slli t3, t2, 2
    add t4, t0, t3
    lw a0, 0(t4)
    beq a0, zero, skip_zero_p    
    
    li a7, 1
    ecall

    addi t2, t2, 1
    bge t2, t1, skip_comma_p

    
    la a0, comma_space
    li a7, 4
    ecall

skip_comma_p:

    j print_player_cards

skip_zero_p:

    addi t2, t2, 1
    j print_player_cards

print_colon_total:
   
    la a0, colon_space
    li a7, 4
    ecall

    la a0, player_point_r
    lw a0, 0(a0)
    li a7, 1
    ecall

    la a0, newline
    li a7, 4
    ecall

    la a0, dealer_points      
    li a7, 4
    ecall

    la t0, dealer_cards
    lw a0, 0(t0)
    beq a0, zero, skip_dealer_card
    li a7, 1
    ecall

skip_dealer_card:

    la a0, dealer_hidden_msg
    li a7, 4
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    ret


######################################################################################################################
#
# SHOW HIT/STAY MSG
#
show_hit_stay:

	addi sp, sp, -4
	sw ra, 0(sp)

	la a0, hit_stay_msg
	li a7, 4
	ecall

	lw ra, 0(sp)
	addi sp, sp, 4
	ret

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

    jal check_and_reset_deck  
    jal calculate_available_cards  
    
    jal print_game_stats           
    jal reset_round_memory

    jal draw_card_player
    add a2, a6, zero
    li a3, 1
    jal display_card_draw

    jal draw_card_dealer
    add a2, a6, zero
    li a3, 0
    jal display_card_draw

    jal draw_card_player
    add a2, a6, zero
    li a3, 1
    jal display_card_draw

    jal draw_card_dealer

    
    li a3, 1
    jal calc_points_hand
    li a3, 0
    jal calc_points_hand

    jal show_both_hands


    jal hit_stay_player         

    bne a6, zero, dealer_win    

    jal show_dealer_hand_only   

    jal hit_stay_dealer         

    bne a6, zero, player_win    

    jal check_winner            

round_in_play_ret:

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

dealer_win:

    la a0, msg_dealer_wins
    li a7, 4
    ecall

    lw t1, dealer_wins
    addi t1, t1, 1
    la t2, dealer_wins
    sw t1, (t2)

    j round_in_play_ret

player_win:
	
    la a0, msg_player_wins
    li a7, 4
    ecall

    lw t1, player_wins
    addi t1, t1, 1
    la t2, player_wins
    sw t1, 0(t2)

    j round_in_play_ret

######################################################################################################################
#	
# INITIAL GREETING FOR THE GAME
#	
print_initial_greeting:
	la a0, initial_greeting
	li a7, 4
	ecall
	
	ret

######################################################################################################################
#
# END PROGRAM EXECUTION
#
finish_game:

	li a7,10
	ecall

######################################################################################################################
#
# PRINT STATS FOR THE GAME IN THE CURRENT MATCH AFTER/START OF A ROUND
#
#
print_game_stats:

    addi sp, sp, -4
    sw ra, 0(sp)
    
    jal calculate_available_cards

    la a0, total_cards
    li a7, 4
    ecall

    la t0, cards_in_play
    lw a0, 0(t0)
    li a7, 1
    ecall


    la a0, newline
    li a7, 4
    ecall

    la a0, wins_msg
    li a7, 4
    ecall
    

    la a0, dealer_points
    li a7, 4
    ecall

    la t0, dealer_wins
    lw a0, 0(t0)
    li a7, 1
    ecall


    la a0, newline
    li a7, 4
    ecall

    la a0, player_points_msg
    li a7, 4
    ecall


    la t0, player_wins
    lw a0, 0(t0)
    li a7, 1
    ecall


    la a0, newline
    li a7, 4
    ecall


    lw ra, 0(sp) 
    addi sp, sp, 4

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
	slli a1,a1,2
	jal set_int_vector_by_value
	
	#RESET DEALER HAND
	la a0,dealer_cards
	la a1, index_cards_dealer
	slli a1,a1,2
	jal set_int_vector_by_value
	 
	 
	#RESET INDEX OF CARDS FOR DEALER AND PLAYER
	la t1, index_cards_player
	sw zero, 0(t1)
	la t1, index_cards_dealer
	sw zero, 0(t1)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	
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
    mv t3, a0             
    
loop_set_vector:

    bge t0, a1, return_set_vector
    add t1, t3, t0
    sw a2, 0(t1)
    addi t0, t0, 4
    j loop_set_vector

return_set_vector:

    ret



#######################################################################################################################	 
#
# RESET MEMORY VALUES THAT ARE USED IN A ROUND (NOT A MATCH)
#
reset_round_memory:

    addi sp, sp, -4
    sw ra, 0(sp)


    la a0, player_cards
    li a1, 48
    li a2, 0
    jal memset_ints

    la a0, dealer_cards
    li a1, 48
    li a2, 0
    jal memset_ints

    la t0, index_cards_player
    sw zero, 0(t0)

    la t0, index_cards_dealer
    sw zero, 0(t0)


    la t0, player_point_r
    sw zero, 0(t0)
    
    la t0, dealer_point_r
    sw zero, 0(t0)


    lw ra, 0(sp)
    addi sp, sp, 4
    ret

memset_ints:

    addi sp, sp, -4
    sw ra, 0(sp)

    li t0, 0              
    
loop_memset:

    bge t0, a1, end_memset
    add t1, a0, t0
    sw a2, 0(t1)
    addi t0, t0, 4
    j loop_memset

end_memset:

    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    
#######################################################################################################################	 
#
# CALCULATE THE QUANTITY OF AVAILABLE_CARDS AND PUT THAT VALUE IN cards_in_play
#
calculate_available_cards:

    la t0, availaible_cards   
    li t1, 0                  
    li t2, 0          

loop_count_cards:

    li t3, 13
    bge t2, t3, save_total  

    slli t4, t2, 2         
    add t5, t0, t4            
    lw t6, 0(t5)              
    add t1, t1, t6            

    addi t2, t2, 1            
    j loop_count_cards

save_total:

    la t0, cards_in_play
    sw t1, 0(t0)
    ret

#######################################################################################################################	 
#
# CHECK IF THE THAT HAS LESS THAN 40 CARDS, IF YES THEN RESET THE AVAILABLE_CARDS
#
check_and_reset_deck:

    addi sp, sp, -4
    sw ra, 0(sp)

    jal calculate_available_cards
   
    la t0, cards_in_play
    lw t1, 0(t0)

    li t2, 40
    bge t1, t2, no_reset_needed       

    la a0, availaible_cards
    li a1, 13              
    slli a1, a1, 2         
    li a2, 4              
    jal set_int_vector_by_value

no_reset_needed:

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

#######################################################################################################################	 
#
# PRINT THE TOTAL OF WINS FOR  PLAYER AND DEALER
#
print_final_score:

    la a0, newline
    li a7, 4
    ecall

    la a0, wins_msg
    li a7, 4
    ecall

    la a0, dealer_points
    li a7, 4
    ecall

    lw a0, dealer_wins
    li a7, 1
    ecall

    la a0, newline
    li a7, 4
    ecall

    la a0, player_points_msg
    li a7, 4
    ecall

    lw a0, player_wins
    li a7, 1
    ecall

    la a0, newline
    li a7, 4
    ecall
    
    la a0, newline
    li a7, 4
    ecall


    ret

