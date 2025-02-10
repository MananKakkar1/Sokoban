# Sokoban Risc V Assembly-Edition - Manan Kakkar
#--------------------------------------------------------------------------------------------------------------
# Algorithm used for psuedorandom generation: LCG or Linear Congruential Generator + modified notrand provided (Implemented at lines 1229-1260). 
# Citation: Derrick Henry Lehmer. Linear Congruential Generator. https://en.wikipedia.org/wiki/Linear_congruential_generator 
#--------------------------------------------------------------------------------------------------------------
# Enhancement 1: Multiplayer (Implemented at lines 110-271.)
# 						- Added clear_leaderboard functionality to the restart and quit buttons a clean new run of the game
# 						- Added a button functionality of 'z', which effectively resets the board for the player and costs them +1 move for the laederboard
# 						- Added a leadboard that essentially stores the least number of moves corresponding to a specific player to the greatest number of moves also corresponding to a certain 
# 						  player. Every entry in the leaderboard has a player id and number of moves associated with it.
# 						- Changed a few labels and lines in other areas of code such that the implementation of replay works as well.
#						- I have also made a save_current_board function as well as a load_og_positions functions which store the original positions of each object on 
#						  the board that were psuedorandomly generated and then load those positions back into the static data to load the board to its original state.
#						- This enhancement is implemented by the following:
#							- We first store the number of players that the user inputs
# 							- Then, we start a loop in the initialize_players label
# 							- This loop will run until its each player has been able to play the game
#							- We load the original positions of the board, reset the move_counter for the next player as well as send that player into the game_loop
#							- After each player has played their game, we store their move_count and player_id in the leaderboard heaps and let the users know that it is the next player's turn.
# 							- This loop is run until every player has finished playing their game. When this is the case, we print the leaderboard with all of the information of each of the players
#							  in it and offer the user 3 options including restart game, quit game, and replay game (see enhancement 2).
#--------------------------------------------------------------------------------------------------------------
# Enhancement 2: Multiplayer Extension (Replay) (Implemented at lines 278-405.)
#						- Added clear_store_heap functionality that clears the heap which stores all of the player moves in it to have a clear transititon into a new game.
# 						- Added a button 'p' which allows the user to select a player for replay. This option is only prompted after the leaderboard has been printed. After the user
# 						enters a valid player from the leaderboard, the game replays that specific player's moves from start to end. The player's have this option indefinately until they would like to
# 						to either restart or quit the game.
#						- Changed a few labels and lines in other areas of code such that the implementation of replay works as well.
#						- This enhancement is implemented by the following:
#							- Every move is stored into a heap in memory at 0x30000000
# 							- Store it at every word in the heap that contains 0xaaaaaaaa
# 							- The print system starts when the game ends:
#								- It starts by loading each heap I have used so far, 0x30000000 for storing moves, 0x50000000 for storing player ids, 0x70000000 for storing number of moves 
# 								  associated with a specific player id.
#								- Then, it waits for valid user input for a valid player id. The code then goes ahead and stores the player id of the selected player as well as their number of
# 								  moves. 
# 								- Now, we enter another loop where we gather the number of moves we must skip in the heap to get to the moves for the specific player id. The way that moves are 
# 								  stored.
# 								  in the moves heap is as the following: 
#									- As each player enters valid input to move the character, that move is stored into the heap as an ascii number to be extracted later in order of player ids from 
# 									  1,2,3,4,5,...,n where n represents the user input for the number of players that are on the leaderboard.
# 								- We then, go ahead and skip those moves that are not needed in the heap for a specific player id and start printing moves from there. This effectively allows us to 
#								  store and print the moves that player made during their turn, in the exact order they occured in the first place. Effectively creating the replay.
# 								- Each time a move is extracted, we print it to console and move the character on the board accordingly and print the updated moves, until the player has no more 
# 								  moves left.
#								- To make this possible, I have also made a save_current_board function as well as a load_og_positions functions which store the original positions of each object on 
#								  the board that were psuedorandomly generated and then load those positions back into the static data to load the board to its original state.
#--------------------------------------------------------------------------------------------------------------
.data
move_count: .word 0
num_players: .word 0
seed: .word 0
array: .byte 0, 0, 0, 0, 0, 0
gridsize:   .byte 8,8
character:  .byte 0,0
box:    .byte 0,0
target:     .byte 0,0
char:       .string "X"
box_symbol: .string "O"
target_symbol: .string "~"
wall_symbol: .string "8"
newline_symbol: .string "\n"
empty: .string " "
user_instruction_message: .string "Controls: Use 'w' for up, 'a' for left, 's' for down, 'd' for right.\nPress 'r' to restart and 'q' to quit.\nPress 'z' to reset the board with a move penalty!.\n"
restart_quit_message: .string "\nPress 'r' to restart and 'q' to quit.\nPress 'p' to view a replay."
win_message: .string "Congratulations! You have moved the box to the target. Press 'r' to restart or 'q' to quit.\n"
replay_win_message: .string "Congratulations! You have moved the box to the target. Press 'r' to restart or 'q' to quit.\nYou can also press 'p' to view a replay of a player.\n"
replay_win_message_2: .string "Congratulations! You have moved the box to the target. Press 'r' to restart or 'q' to quit.\nYou can also press 'p' to view a replay of a player again.\n"
starting_message: .string "Welcome to Sokoban!"
num_players_message: .string "How many players would like to play?"
next_player_message: .string "Next Player's Turn"
leaderboard_message: .string "\n\n\n\n\nLeaderboard!\n"
player_id_message: .string "Player ID: "
move_message: .string "Moves: "
replay_message: .string "Choose a player to view a replay: "
replay_instruction_message: .string "Controls: Use 'w' for up, 'a' for left, 's' for down, 'd' for right."
get_row_size: .string "Enter a positive number for the number of rows in the grid: "
get_col_size: .string "Enter a positive number for the number of columns in the grid: "
player_number_indicator_1: .string "Player "
player_number_indicator_2: .string "'s Turn!"
.text
.globl _start

_start:
    # TODO: Generate locations for the character, box, and target. Static
    # locations in memory have been provided for the (x, y) coordinates 
    # of each of these elements.
    # 
    # There is a notrand function that you can use to start with. It's 
    # really not very good; you will replace it with your own rand function
    # later. Regardless of the source of your "random" locations, make 
    # sure that none of the items are on top of each other and that the 
    # board is solvable.
	li x26, 1
	beq x26, x27, restart_game
	jal clear_leaderboard
	li a7, 4
	la a0, newline_symbol
	ecall
	ecall
	ecall
	ecall
	ecall
	ecall
	la a0, starting_message
	ecall
	la a0, newline_symbol
	ecall
	jal generate_random_pos
	jal save_current_board
	la t0, num_players
	WHILE:
		li a7, 4
		la a0, num_players_message
		ecall
		li a7, 5
		ecall
		bge a0, x0, CONTINUE
		DEFAULT_1:
			li a0, 1
			j CONTINUE
		j WHILE
	CONTINUE:
		beq a0, x0, DEFAULT_1
		sw a0, 0(t0)
		li s8, 0 # Counter Starting 0
		lw s9, num_players
		la a0, move_count
		sw x0, 0(a0)
		j initialize_players
    # TODO: Now, print the gameboard. Select symbols to represent the walls,
    # character, box, and target. Write a function that uses the location of
    # the various elements (in memory) to construct a gameboard and that 
    # prints that board one character at a time.
    # HINT: You may wish to construct the string that represents the board
    # and then print that string with a single syscall. If you do this, 
    # consider whether you want to place this string in static memory or 
    # on the stack. 

    # TODO: Enter a loop and wait for user input. Whenever user input is
    # received, update the gameboard state with the new location of the 
    # player (and if applicable, box and target). Print a message if the 
    # input received is invalid or if it results in no change to the game 
    # state. Otherwise, print the updated game state. 
    #
    # You will also need to restart the game if the user requests it and 
    # indicate when the box is located in the same position as the target.
    # For the former, it may be useful for this loop to exist in a function,
    # to make it cleaner to exit the game loop.

    # TODO: That's the base game! Now, pick a pair of enhancements and  
    # consider how to implement them.
		
initialize_players:
	jal load_og_positions
	la a0, move_count
	sw x0, 0(a0)
	beq s8, s9, leaderboard_print
	blt s8, s9, game_loop
	increment:
		addi s8, s8, 1
		jal leaderboard_storage
		addi s8, s8, 1
		bge s8, s9, skip_print_curr_player
		print_curr_player_indicator:
			li a7, 4
			la a0, newline_symbol
			ecall
			la a0, player_number_indicator_1
			ecall
			li a7, 1
			mv a0, s8
			ecall
			li a7, 4
			la a0, player_number_indicator_2
			ecall
			la a0, newline_symbol
			ecall
			ecall
			j jump_back
		skip_print_curr_player:
			beq s8, s9, print_curr_player_indicator
		jump_back:
			addi s8, s8, -1
			j initialize_players
		
clear_leaderboard:
	li a3, 0x50000000  
    li a4, 0x70000000 
	li t3, 0xaaaaaaaa  
	mv t1, a3
	mv t2, a4
	li t6, 0
	clear_loop:
		beq t6, s9, end_clear
		lw t4, 0(t1)
		lw t5, 0(t2)
		beq t4, t3, next_heap_loc
		sw t3, 0(t1)
		beq t5, t3, next_heap_loc
		sw t3, 0(t2)
	next_heap_loc:
		addi t1, t1, 4
		addi t2, t2, 4
		addi t6, t6, 1
		j clear_loop
	end_clear:
		jr ra
		
leaderboard_storage:
    lw a1, move_count
    mv a0, s8
    li a3, 0x50000000  
    li a4, 0x70000000  
    
    mv t0, a3
    mv t1, a4
    addi t0, t0, -4
    addi t1, t1, -4
    li t3, 0xaaaaaaaa
        
    insert_loop:
        addi t0, t0, 4
        addi t1, t1, 4
        lw t4, 0(t0)
        beq t4, t3, continue_next
        j check_curr_scores
        
    check_curr_scores:
        lw t4, 0(t1)
        blt t4, a1, insert_loop
        
    next:
        lw t4, 0(t0)
        lw t5, 0(t1)
        
        sw a0, 0(t0)
        sw a1, 0(t1)
        
        mv a0, t4
        mv a1, t5
        
        addi t0, t0, 4
        addi t1, t1, 4
        
        lw t4, 0(t0)
        beq t4, t3, continue_next
        bne t4, t3, next
        j end_insert_loop
        
    continue_next:
        sw a0, 0(t0)
        sw a1, 0(t1)
        
    end_insert_loop:
          jr ra
		
leaderboard_print:
	li a7, 4
	la a0, leaderboard_message
	ecall
	
	li a3, 0x50000000
	li a4, 0x70000000
	
	mv t5, a3
	mv t6, a4
	
	lw t0, num_players
	li t1, 0
	li a5, 0
	
	leaderboard_loop:
		beq t1, t0, end_print_loop
		lw t2, 0(t5)
		lw t3, 0(t6)
		lw t4, -4(t6)
		
		
		beq t4, t3, skip_rank_addition
		addi a5, a5, 1
		
		skip_rank_addition:
			mv a0, a5
			li a7, 1
			ecall

			li a7, 4
			la a0, empty
			ecall
			la a0, player_id_message
			ecall

			mv a0, t2
			li a7, 1
			ecall

			li a7, 4
			la a0, empty
			ecall
			la a0, move_message
			ecall

			mv a0, t3
			li a7, 1
			ecall

			li a7, 4
			la a0, newline_symbol
			ecall

			addi t5, t5, 4
			addi t6, t6, 4
			addi t1, t1, 1
			j leaderboard_loop
		
	end_print_loop:
		j restart_message_print
		
replay:
	jal load_og_positions
	li x27, 1
	li a3, 0x30000000
	
	li a4, 0x50000000
	li a5, 0x70000000
	
	li a7, 4
	la a0, newline_symbol
	ecall
	la a0, replay_message
	ecall
	la a0, newline_symbol
	ecall
	li a7, 5
	ecall
	blt a0, s9, continue
	beq a0, s9, continue
	li t1, 1
	WHILE_REPLAY:
		li a7, 4
		la a0, newline_symbol
		ecall
		la a0, replay_message
		ecall
		la a0, newline_symbol
		ecall
		li a7, 5
		ecall
		blt a0, s9, continue
		j WHILE_REPLAY
	continue:
		beq a0, t1, continue_2
		blt a0, t1, continue_2
		j WHILE_REPLAY
	continue_2:
		mv t2, a4
		mv t3, a5
		mv t1, a0
	LOOP_REPLAY:
		lw t4, 0(t2)
		lw t5, 0(t3)
		beq t4, t1, next_loop_replay_init
		addi t2, t2, 4
		addi t3, t3, 4
		j LOOP_REPLAY
	next_loop_replay_init:
		mv x23, t4
		mv x26, t5
		mv t2, a4
		mv t3, a5
		li t6, 0
		li s3, 0
	next_loop_replay:
		beq t6, s9, quit_loop_replay
		lw t4, 0(t2)
		lw t5, 0(t3)
		addi t2, t2, 4
		addi t3, t3, 4
		addi t6, t6, 1
		bge t4, x23, next_loop_replay
		add s3, s3, t5
		j next_loop_replay
	quit_loop_replay:
		li s2, 0 
		mv x23, a3
	SKIP_LOOP:
		beq s2, s3, end_skip_loop
		addi x23, x23, 4
		addi s2, s2, 1
		j SKIP_LOOP
	end_skip_loop:
		li s2, 0
		mv s4, x26
		j print_board
		
	print_replay:
		beq s2, s4, restart_message_print
		lw s3, 0(x23)
		addi x23, x23, 4
		
		li a7, 4
		la a0, replay_instruction_message
		ecall
		la a0, newline_symbol
		ecall
		
		li a7, 11
		mv a0, s3
		ecall
		
		li a7, 4
		la a0, newline_symbol
		ecall
		
		li t1, 'w'
		beq s3, t1, move_up

		li t1, 's'
		beq s3, t1, move_down

		li t1, 'a'
		beq s3, t1, move_left

		li t1, 'd'
		beq s3, t1, move_right
		
		li t1, 'z'
		beq s3, t1, reset_board
		
		
print_replay_board:
	addi s2, s2, 1
	j print_board
	
store_move:
	li a3, 0x30000000
	mv t1, a3
	li t3, 0xaaaaaaaa
	WHILE_STORE:
		lw t4, 0(t1)
		beq t3, t4, store
		addi t1, t1, 4
		j WHILE_STORE
	store:
		sw t0, 0(t1)
		jr ra

clear_store_heap:
	li a3, 0x30000000
	li a4, 0x70000000
	mv t1, a4
	li t6, 0
	li t3, 0
	li t4, 0xaaaaaaaa
	CLEAR_COUNT_LOOP:
		beq t3, s9, exit_clear_count
		lw t2, 0(t1)
		beq t2, t4, end_store_clear
		addi t1, t1, 4
		add t6, t6, t2
		addi t3, t3, 1
		j CLEAR_COUNT_LOOP
	exit_clear_count:
		li t3, 0xaaaaaaaa
		mv t1, a3
		li t4, 0
	clear_store_loop:
		beq t4, t6, end_store_clear
		lw t5, 0(t1)
		beq t5, t3, next_store_heap_loc
		sw t3, 0(t1)
	next_store_heap_loc:
		addi t1, t1, 4
		addi t4, t4, 1
		j clear_store_loop
	end_store_clear:
		jr ra
		
load_og_positions:
	la t2, array
	lb t3, 0(t2)
	lb t4, 1(t2)
	la t1, character
	sb t3, 0(t1)
	sb t4, 1(t1)
	
	lb t3, 2(t2)
	lb t4, 3(t2)
	la t1, box
	sb t3, 0(t1)
	sb t4, 1(t1)
	
	lb t3, 4(t2)
	lb t4, 5(t2)
	la t1, target
	sb t3, 0(t1)
	sb t4, 1(t1)
	
	ret
	
save_current_board:
	la t3, array 
    la t0, character      
    lb t1, 0(t0)          
    lb t2, 1(t0)          
    sb t1, 0(t3)          
    sb t2, 1(t3)          

    
    la t0, box            
    lb t1, 0(t0)         
    lb t2, 1(t0)          
    sb t1, 2(t3)          
    sb t2, 3(t3)          

    
    la t0, target         
    lb t1, 0(t0)          
    lb t2, 1(t0)          
    sb t1, 4(t3)          
    sb t2, 5(t3)          

    ret                   
check_col_1_box:
	beq t6, x23, generate_box_pos
	j check_col_n_box
	
check_col_n_box:
	beq t6, x29, generate_box_pos
	j end_box_gen

check_win_condition:
	la t1, box
    lb t2, 0(t1)        
    lb t3, 1(t1)       

    la t4, target
    lb t5, 0(t4)        
    lb t6, 1(t4)     
	
	beq t2, t5, check_col_win
	j game_loop
	
check_col_win:
	beq t3, t6, win_message_print
	j game_loop
	
win_message_print:
	j print_board
	win_message_1:
		li a7, 4
		la a0, win_message
		ecall
		j increment
print_replay_win_message:
	li x26, 1
	beq x26, x27, continue_replay_win_print
	j continue_restart_message_print
	continue_replay_win_print:
		li a7, 4
		la a0, replay_win_message
		ecall
		j continue_restart_input
	
restart_message_print:
	j print_replay_win_message
	
	continue_restart_message_print:
		li x26, 1
		beq x26, x27, restart_replay_again
		li a7, 4
		la a0, restart_quit_message
		ecall
		j continue_restart_input
		
		restart_replay_again:
			li a7, 4
			la a0, replay_win_message_2
			ecall
			
	continue_restart_input:
		li a7, 12
		ecall
		mv t0, a0

		li t1, 'p'
		beq t0, t1, replay

		li t1, 'r'
		beq t0, t1, restart_game

		li t1, 'q'
		beq t0, t1, quit_game

    j restart_message_print
	
reset_board:
	li x26, 1
	beq x27, x26, continue_reset
	RESET_STORE:
		jal store_move
	continue_reset:
		jal load_og_positions
		lw s6, move_count
		addi s6, s6, 1
		la s5, move_count
		sw s6, 0(s5)
		li x26, 1
		beq x26, x27, print_replay_board
		j game_loop
	
game_loop:
	j print_board 
	g_loop:
		li a7, 4
		la a0, user_instruction_message
		ecall

		li a7, 12
		ecall
		mv t0, a0
		
		li a7, 4
		la a0, newline_symbol
		ecall
		ecall
		ecall
		ecall
		ecall
		ecall
		ecall
		ecall

		li t1, 'w'
		beq t0, t1, move_up

		li t1, 's'
		beq t0, t1, move_down

		li t1, 'a'
		beq t0, t1, move_left

		li t1, 'd'
		beq t0, t1, move_right

		li t1, 'r'
		beq t0, t1, restart_game

		li t1, 'q'
		beq t0, t1, quit_game
		
		li t1, 'z'
		beq t0, t1, reset_board

		j game_loop
	move_up:
		li x26, 1
		beq x26, x27, continue_up
		UP_MOVE_STORE:
			jal store_move
		continue_up:
			la t1, character
			lb t2, 0(t1)
			blt t2, x0, game_loop
			addi t2, t2, -1
			beq t2, x0, game_loop
			sb t2, 0(t1)
			lw s6, move_count
			addi s6, s6, 1
			la s5, move_count
			sw s6, 0(s5)
			j check_box_move
	move_down:
		li x26, 1
		beq x26, x27, continue_down
		DOWN_MOVE_STORE:
			jal store_move
		continue_down:
			la t1, gridsize
			lb t3, 0(t1)
			addi t3, t3, 1
			la t1, character
			lb t2, 0(t1)
			bge t2, t3, game_loop
			addi t2, t2, 1
			beq  t2, t3, game_loop
			sb t2, 0(t1)
			lw s6, move_count
			addi s6, s6, 1
			la s5, move_count
			sw s6, 0(s5)
			j check_box_move
	move_left:
		li x26, 1
		beq x26, x27, continue_left
		LEFT_MOVE_STORE:
			jal store_move
		continue_left:
			la t1, character
			lb t2, 1(t1)
			beq t2, x0, game_loop
			addi t2, t2, -1
			beq t2, x0, game_loop
			sb t2, 1(t1)
			lw s6, move_count
			addi s6, s6, 1
			la s5, move_count
			sw s6, 0(s5)
			j check_box_move
			
	move_right:
		li x26, 1
		beq x26, x27, continue_right
		RIGHT_MOVE_STORE:
			jal store_move
		continue_right:
			la t1, gridsize
			lb t3, 1(t1)
			addi t3, t3, 1
			la t1, character
			lb t2, 1(t1)
			bge t2, t3, game_loop
			addi t2, t2, 1
			beq t2, t3, game_loop
			sb t2, 1(t1)
			lw s6, move_count
			addi s6, s6, 1
			la s5, move_count
			sw s6, 0(s5)
			j check_box_move
		
	check_box_move:
		la t1, character
		lb t2, 0(t1)
		lb t3, 1(t1)
		
		la t4, box
		lb t5, 0(t4)
		lb t6, 1(t4)
		
		beq t2, t5, check_box_y
		li x26, 1
		beq x26, x27, print_replay_board
		j game_loop
	
	check_box_y:
		li x26, 1
		beq x26, x27, check_replay_box_move
		beq t3, t6, move_box
		li x26, 1
		beq x26, x27, print_replay_board
		j game_loop
	
	check_replay_box_move:
		beq t3, t6, move_replay_box
		j print_replay_board
		
	move_replay_box:
		li t1, 'w'
		beq s3, t1, move_box_up

		li t1, 's'
		beq s3, t1, move_box_down

		li t1, 'a'
		beq s3, t1, move_box_left

		li t1, 'd'
		beq s3, t1, move_box_right
		
	move_box:
		li t1, 'w'
		beq t0, t1, move_box_up

		li t1, 's'
		beq t0, t1, move_box_down

		li t1, 'a'
		beq t0, t1, move_box_left

		li t1, 'd'
		beq t0, t1, move_box_right

	move_box_up:
		la t1, box
		lb t5, 0(t1)
		addi t5, t5, -1
		beq t5, x0, no_x_move_up
		sb t5, 0(t1)
		li x26, 1
		beq x26, x27, print_replay_board
		j check_win_condition
	no_x_move_up:
		la t1, character
		lb t5, 0(t1)
		addi t5, t5, 1
		sb t5, 0(t1)
		li x26, 1
		beq x26, x27, print_replay_board
		j check_win_condition
	move_box_down:
		la t1, box
		lb t5, 0(t1)
		la x15, gridsize
		lb x16, 0(x15)
		addi x16, x16, 1
		addi t5, t5, 1
		beq t5, x16, no_x_move_down
		sb t5, 0(t4)
		li x26, 1
		beq x26, x27, print_replay_board
		j check_win_condition
	no_x_move_down:
		la t1, character
		lb t5, 0(t1)
		addi t5, t5, -1
		sb t5, 0(t1)
		li x26, 1
		beq x26, x27, print_replay_board
		j check_win_condition
	move_box_left:
		la t1, box
		lb t6, 1(t1)
		addi t6, t6, -1
		beq t6, x0, no_y_move_left
		sb t6, 1(t1)
		li x26, 1
		beq x26, x27, print_replay_board
		j check_win_condition
	no_y_move_left:
		la t1, character
		lb t6, 1(t1)
		addi t6, t6, 1
		sb t6, 1(t1)
		li x26, 1
		beq x26, x27, print_replay_board
		j check_win_condition
	move_box_right:
		la t1, box
		lb t6, 1(t1)
		la x15, gridsize
		lb x16, 1(x15)
		addi x16, x16, 1
		addi t6, t6, 1
		beq t6, x16, no_y_move_right
		sb t6, 1(t1)
		li x26, 1
		beq x26, x27, print_replay_board
		j check_win_condition
	no_y_move_right:
		la t1, character
		lb t6, 1(t1)
		addi t6, t6, -1
		sb t6, 1(t1)
		li x26, 1
		beq x26, x27, print_replay_board
		j check_win_condition
		
	restart_game:
		li x27, 0
		jal clear_store_heap
		jal clear_leaderboard
		j _start
	quit_game:
		li x27, 0
		jal clear_store_heap
		jal clear_leaderboard
		j exit

generate_random_pos:
	addi sp, sp, -12
	sw ra, 0(sp)
	sw t0, 4(sp)
	sw t1, 8(sp)
	
	la a0, gridsize
	lb x14, 0(a0)
	lb x12, 1(a0)
	li x13, 1
	
	generate_box_pos:
		reset_row_box:
			beq x14, x13, row_coords
			li t5, 0
			jal notrand
			mv a1, x14
			la a6, seed
    		sw a0, 0(a6)
			jal LCG
			mv t5, a0
			beq t5, x0, reset_row_box
			j reset_col_box
		row_coords:
			li t5, 1
		reset_col_box:
			beq x12, x13, col_coords
			li t6, 0
			jal notrand
			mv a1, x12
			la a6, seed
    		sw a0, 0(a6)
			jal LCG			
			mv t6, a0
			beq t6, x0, reset_col_box
			j check_first_corner_row
		col_coords:
			li t6, 1
			
		check_first_corner_row:
			beq t5, x13, check_first_corner_col
			j check_second_corner_row
		check_first_corner_col:
			beq t6, x13, reset_row_box
			j check_second_corner_row
		check_second_corner_row:
			beq t5, x13, check_second_corner_col
			j check_third_corner_row
		check_second_corner_col:
			beq t6, x12, reset_row_box
			j check_third_corner_row
		check_third_corner_row:
			beq t5, x14, check_third_corner_col
			j check_fourth_corner_row
		check_third_corner_col:
			beq t6, x13, reset_row_box
			j check_fourth_corner_col
		check_fourth_corner_row:
			beq t5, x14, check_fourth_corner_col
			j end_box_gen
		check_fourth_corner_col:
			beq t6, x12, reset_row_box
			j end_box_gen
			
		end_box_gen:
			la t1, box
			sb t5, 0(t1)
			sb t6, 1(t1)
			
	
	generate_target_pos:
		get_box:
			la t1, box
			lb t2, 0(t1)
			lb t3, 1(t1)
		reset_row_target:
			beq x14, x13, target_row_1
			li t5, 0
			jal notrand
			mv a1, x14
			la a6, seed
    		sw a0, 0(a6)
			mv a6, t3
			jal LCG
			mv t3, a6
			mv t5, a0
			beq t5, x0, reset_row_target
			j reset_col_target
		target_row_1:
			li t5, 1
			
		reset_col_target:
			beq x12, x13, target_col_1
			li t6, 0
			jal notrand
			mv a1, x12
			la a6, seed
    		sw a0, 0(a6)
			mv a6, t3
			jal LCG
			mv t3, a6
			mv t6, a0
			beq t6, x0, reset_col_target
			j check_row_overlap
		target_col_1:
			li t6, 1
			
		check_row_overlap:
			bne t2, t5, check_box_1_col
			bne t3, t6, check_box_1_col
			j reset_row_target
		
			
		check_box_1_col:
			beq t3, x13, gen_target_col_1
			j check_box_n_col
		gen_target_col_1:
			la t1, target
			beq t2, t5, reset_row_target
			sb t5, 0(t1)
			sb t3, 1(t1)
			j generate_character_pos
			
		check_box_n_col:
			beq t3, x12, gen_target_col_n
			j check_box_1_row
		gen_target_col_n:
			la t1, target
			beq t2, t5, reset_row_target
			sb t5, 0(t1)
			sb x12, 1(t1)
			j generate_character_pos
			
		check_box_1_row:
			beq t2, x13, gen_target_row_1
			j check_box_n_row
		gen_target_row_1:
			la t1, target
			sb x13, 0(t1)
			beq t3, t6, reset_col_target
			sb t6, 1(t1)
			j generate_character_pos
			
		check_box_n_row:
			beq t2, x14, gen_target_row_n
			j anything_else
		gen_target_row_n:
			la t1, target
			sb x14, 0(t1)
			beq t3, t6, reset_col_target
			sb t6, 1(t1)
			j generate_character_pos
			
		anything_else:
			la t1, target
			sb t5, 0(t1)
			sb t6, 1(t1)
		
	generate_character_pos:
		get_box_c:
			la t1, box
			lb t2, 0(t1)
			lb t3, 1(t1)
		get_target_c:
			la t4, target
			lb x15, 0(t4)
			lb x16, 1(t4)
		reset_row_character:
			beq x14, x13, character_row_1
			li t5, 0
			jal notrand
			mv a1, x14
			la t0, seed
    		sw a0, 0(t0)
			jal LCG
			la t1, box
			lb t2, 0(t1)
			lb t3, 1(t1)
			mv t5, a0
			beq t5, x0, reset_row_character
			j reset_col_character
		character_row_1:
			li t5, 1
		reset_col_character:
			beq x12, x13, character_col_1
			li t6, 0
			jal notrand
			mv a1, x12
			la t0, seed
    		sw a0, 0(t0)
			jal LCG
			la t1, box
			lb t2, 0(t1)
			lb t3, 1(t1)
			mv t6, a0
			beq t6, x0, reset_col_character
			j check_row_box_char_overlap
		character_col_1:
			li t6, 1
			
		check_row_box_char_overlap:
			beq t2, t5, check_col_box_char_overlap
			j check_row_target_char_overlap
		check_col_box_char_overlap:
			beq t3, t6, reset_row_character
			j check_row_target_char_overlap
		check_row_target_char_overlap:
			beq x15, t5, check_col_target_char_overlap
			j check_y1
		check_col_target_char_overlap:
			beq x16, t6, reset_row_character
			j check_y1
			
		check_y1:
			bne x12, x13, check_box_pos
			blt t2, x15, check_char_y1_between
			j check_char_y2_between
		check_char_y1_between:
			blt t5, t2, end_char_gen
			j reset_row_character
		check_char_y2_between:
			bge t5, t2, end_char_gen
			j reset_row_character
			
		check_box_pos:
			bne x14, x13, end_char_gen
			bge t3, x16, check_char_1_between
			j check_char_2_between
		check_char_1_between:
			bge t6, t3, end_char_gen
			j reset_row_character
		check_char_2_between:
			blt t6, t3, end_char_gen
			j reset_row_character
			
		end_char_gen:
			la t1, character
			sb t5, 0(t1)
			sb t6, 1(t1)
			
	lw t1, 8(sp)
	lw t0, 4(sp)
	lw ra, 0(sp)
	addi sp, sp, 12
	ret
	
print_board:
	la x1, gridsize
	lb x8, 0(x1)
	lb x9, 1(x1)
	addi x9, x9, 2
	addi x8, x8, 1
	addi x14, x9, -1
	li x12, 0 #row counter
	li x13, 0
	j inner_loop
	
print_board_end:
	la t1, box
	lb t2, 0(t1)
	lb t3, 1(t1)
	
	la t4, target
	lb t5, 0(t4)
	lb t6, 1(t4)
	li x26, 1
	beq x26, x27, print_replay
	beq t2, t5, check_win_col_print
	j go_to_g_loop1
	check_win_col_print:
		beq t3, t6, win_message_1
		j g_loop
	go_to_g_loop1:
		j g_loop
	
	
add_newline:
	li a7, 4
	la a0, newline_symbol
	ecall
		
outer_loop:
	bge x12, x8, print_board_end
	li x13, 0 #reset column counter
	addi x12, x12, 1
	j inner_loop
	
print_mid_wall:
	li a7, 4
	la a0, wall_symbol
	ecall
	j finish_loop
		
inner_loop:
	beq x13, x9, add_newline
	bge x13, x9, outer_loop
	beq x12, x0, print_wall
	beq x12, x8, print_wall
	beq x13, x0, print_mid_wall
	beq x14, x13, print_mid_wall
	
	check_char:
		la t1, character
		lb t2, 0(t1)          
		lb t3, 1(t1)          
		bne x12, t2, check_box
		bne x13, t3, check_box
		li a7, 4
		la a0, char
		ecall
		j finish_loop
		
	check_box:
		la t1, box
		lb t2, 0(t1)          
		lb t3, 1(t1)          
		bne x12, t2, check_target
		bne x13, t3, check_target
		li a7, 4
		la a0, box_symbol
		ecall
		j finish_loop
		
	check_target:	
		la t1, target
		lb t2, 0(t1)          
		lb t3, 1(t1)          
		bne x12, t2, empty_case
		bne x13, t3, empty_case
		li a7, 4
		la a0, target_symbol
		ecall
		j finish_loop
		
	empty_case:
		li a7, 4
		la a0, empty
		ecall
		
	finish_loop:
		addi x13, x13, 1
		j inner_loop
	
print_wall:
	li a7, 4
	la a0, wall_symbol
	ecall
	j finish_loop
	
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use, modify, or add to them however you see fit.
     
# Arguments: an integer MAX in a0
# Return: A number from 0 (inclusive) to MAX (exclusive)
notrand:
    mv t0, a0
    li a7, 30
    ecall             # time syscall (returns milliseconds)
    jr ra

# Argument: an integer MAX in a1
# Return: A number from 1(inclusive) to MAX (inclusive)
# Citation: Derrick Henry Lehmer. Linear Congruential Generator. https://en.wikipedia.org/wiki/Linear_congruential_generator 
LCG:
	li t0, 3326489
	li t1, 4393139
	li t3, 0xeffffff
    la a0, seed
	lw a0, 0(a0)
    mul a0, a0, t0
    add a0, a0, t1
    rem a0, a0, t3
    rem a0, a0, a1
	mv t6, ra
    jal abs
	mv ra, t6
	addi a0, a0, 1
    jr ra
	
abs:
	bge a0, x0, POSITIVE
	NEGATIVE:
		li t0, -1
		mul a0, a0, t0
		jr ra
	POSITIVE:
		jr ra