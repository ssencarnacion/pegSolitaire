# CS 21 22.1 - Lab 1 -- S1 AY 2022-2023
# Stephen Mary S. Encarnacion -- 11/07/2022
# cs21project1B.asm

###############################################
.eqv end_index, $s6
.eqv board, $s7	
		
.macro exit #ends the program
	li 	$v0, 10
	syscall
.end_macro

.macro newline #prints a newline
	li 	$a0, 0xA
	li 	$v0, 11
	syscall
.end_macro

.macro read_str # reads input 
	li $v0, 8
	la $a0, line
	li $a1, 9
	syscall
.end_macro	

.macro print_char(%n)
	addi 	$a0, %n, 0
	li	$v0, 11
	syscall
.end_macro

.macro print_int(%n)
	addi 	$a0, %n, 0
	li	$v0, 1
	syscall
.end_macro

.macro printmsg1
	li $v0, 4
	la $a0, msg1
	syscall
.end_macro

.macro printmsg2
	li $v0, 4
	la $a0, msg2
	syscall
.end_macro

.macro printmsg3
	li $v0, 4
	la $a0, msg3
	syscall
.end_macro

.macro printmsg4
	li $v0, 4
	la $a0, msg4
	syscall
.end_macro

.macro printYES
	li $v0, 4
	la $a0, msg5
	syscall
.end_macro

.macro printNO
	li $v0, 4
	la $a0, msg6
	syscall
.end_macro
###############################################

.text
main:
	la board, game_board #set the address of our array
	move $t0, board
	
	#7 lines of input, build the board
	jal input
	jal input
	jal input
	jal input
	jal input
	jal input
	jal input
	
	jal solver	
	
	
	beq $v1, 1, yes
	printNO
	exit
	
	yes:
	printYES
	exit
	
solver:
	addi $sp, $sp, -20
	sw $a1, 0($sp) #number of pegs
	sw $s0, 4($sp) #i
	sw $s1, 8($sp) #j
	sw $s2, 12($sp) #board[i][j]
	sw $ra, 16($sp)
	
	jal counter #we have the number of pegs now, stored in $a1
	beq $a1, 1, base_case #if we have only 1 peg, check if it's in the end_index
	
check_movements:
	li $s0, 0 #i
	forr1:
	li $s1, 0 #j
	forr2:
	beq $s1, 7, check_outerr
	
	#check board[i][j]
	mul $s2, $s0, 7
	add $s2, $s2, $s1
	mul $s2, $s2, 4	
	
	add $s2, $s2, board
	lw $s2, ($s2)	
	
	beq $s2, 111, peg_detected #the character 'o' is found at board[i][j]
	j increment_indexx #if current character is not a peg, increment index
		
	peg_detected:
	check_up:
	jal moveUp
	beq $a2, 1, up #check if we can move up
	j check_down #if we cant go up, check if we can go down
	
	up:
	li $a2, 0
	jal tryMoveUp 
	beq $v1, 1, solver_end
	
	
	check_down:
	jal moveDown
	beq $a2, 1, down #check if we can move up
	j check_left #if we cant go down, check left
	
	down:
	li $a2, 0
	jal tryMoveDown 
	beq $v1, 1, solver_end
		
	check_left:
	jal moveLeft
	beq $a2, 1, left #check if we can move left
	j check_right #if we cant go left, check_right
	
	left:
	li $a2, 0
	jal tryMoveLeft
	beq $v1, 1, solver_end
	
	check_right:
	jal moveRight
	beq $a2, 1, right #check if we can move right
	j increment_indexx #no more possible movements, increment index
	
	right:
	li $a2, 0
	jal tryMoveRight
	beq $v1, 1, solver_end
												
	increment_indexx:
	addi $s1, $s1, 1
	j forr2
	
	check_outerr:
	addi $s0, $s0, 1
	beq $s0, 7, solver_end
	j forr1

tryMoveUp:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	mul $s2, $s0, 7
	add $s2, $s2, $s1
	mul $s2, $s2, 4
	add $s2, $s2, board	
	
	li $t1, 46
	sw $t1, ($s2) #grid[i][j] = '.'
	
	addi $s2, $s2, -28
	sw $t1, ($s2) #grid[i-1][j] = '.'
	
	addi $s2, $s2, -28
	li $t1, 111
	sw $t1, ($s2) #grid[i-2][j] = 'o'
		
	jal solver #if solver(), return True
	beq $v1, 1, movedUp 
	
	#else we undo the movement
	li $t1, 46
	sw $t1, ($s2) #grid[i-2][j] = '.'
	
	li $t1, 111
	addi $s2, $s2, 28
	sw $t1, ($s2) #grid[i-1][j] = 'o'
	
	addi $s2, $s2, 28
	sw $t1, ($s2) #grid[i][j] = 'o'	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	movedUp:
	#printmsg1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
moveUp:	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	blt $s0, 2, moveUp_end
	
	mul $s2, $s0, 7
	add $s2, $s2, $s1
	mul $s2, $s2, 4
	
	add $s2, $s2, board
	addi $s2, $s2, -28
	move $t1, $s2
	lw $s2, ($s2) #board[i-1][j]
	
	beq $s2, 111, upCondition1 #if #board[i-1][j] = 'o'
	
	moveUp_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	upCondition1:
	addi $t0, $0, 1
	addi $t1, $t1, -28
	lw $t1, ($t1) #board[i-2][j]		
	beq $t1, 46, upCondition2 #if #board[i-2][j] = '.'
	j moveUp_end
	
	upCondition2:
	li $a2, 1
	j moveUp_end

tryMoveDown:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	mul $s2, $s0, 7
	add $s2, $s2, $s1
	mul $s2, $s2, 4
	add $s2, $s2, board	
	
	li $t1, 46
	sw $t1, ($s2) #grid[i][j] = '.'
	
	addi $s2, $s2, 28
	sw $t1, ($s2) #grid[i+1][j] = '.'
	
	addi $s2, $s2, 28
	li $t1, 111
	sw $t1, ($s2) #grid[i+2][j] = 'o'
		
	jal solver #if solver(), return True
	beq $v1, 1, movedDown 
	
	#else we undo the movement
	li $t1, 46
	sw $t1, ($s2) #grid[i+2][j] = '.'
	
	li $t1, 111
	addi $s2, $s2, -28
	sw $t1, ($s2) #grid[i+1][j] = 'o'
	
	addi $s2, $s2, -28
	sw $t1, ($s2) #grid[i][j] = 'o'	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra	
	
	movedDown:
	#printmsg2
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

moveDown:	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	bgt $s0, 4, moveDown_end
	
	mul $s2, $s0, 7
	add $s2, $s2, $s1
	mul $s2, $s2, 4
	
	add $s2, $s2, board
	addi $s2, $s2, 28
	move $t1, $s2
	lw $s2, ($s2) #board[i+1][j]
	
	beq $s2, 111, downCondition1 #if #board[i+1][j] = 'o'
	
	moveDown_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	downCondition1:
	addi $t0, $0, 1
	addi $t1, $t1, 28
	lw $t1, ($t1) #board[i+2][j]		
	beq $t1, 46, downCondition2 #if #board[i+2][j] = '.'
	j moveDown_end
	
	downCondition2:
	li $a2, 1
	j moveDown_end
	
tryMoveLeft:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	mul $s2, $s0, 7
	add $s2, $s2, $s1
	mul $s2, $s2, 4
	add $s2, $s2, board	
	
	li $t1, 46
	sw $t1, ($s2) #grid[i][j] = '.'
	
	addi $s2, $s2, -4
	sw $t1, ($s2) #grid[i][j-1] = '.'
	
	addi $s2, $s2, -4
	li $t1, 111
	sw $t1, ($s2) #grid[i][j-2] = 'o'
		
	jal solver #if solver(), return True
	beq $v1, 1, movedLeft
	
	#else we undo the movement
	li $t1, 46
	sw $t1, ($s2) #grid[i][j-2] = '.'
	
	li $t1, 111
	addi $s2, $s2, 4
	sw $t1, ($s2) #grid[i][j-1] = 'o'
	
	addi $s2, $s2, 4
	sw $t1, ($s2) #grid[i][j] = 'o'	

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra	
	
	movedLeft:
	#printmsg3
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

moveLeft:	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	blt $s1, 2, moveLeft_end
	
	mul $s2, $s0, 7
	add $s2, $s2, $s1
	mul $s2, $s2, 4
	
	add $s2, $s2, board
	addi $s2, $s2, -4
	move $t1, $s2
	lw $s2, ($s2) #board[i][j-1]
	
	beq $s2, 111, leftCondition1 #if #board[i][j-1] = 'o'
	
	moveLeft_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	leftCondition1:
	addi $t0, $0, 1
	addi $t1, $t1, -4
	lw $t1, ($t1) #board[i][j-2]		
	beq $t1, 46, leftCondition2 #if #board[i][j-2] = '.'
	j moveLeft_end
	
	leftCondition2:
	li $a2, 1
	j moveLeft_end

tryMoveRight:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	mul $s2, $s0, 7
	add $s2, $s2, $s1
	mul $s2, $s2, 4
	add $s2, $s2, board	
	
	li $t1, 46
	sw $t1, ($s2) #grid[i][j] = '.'
	
	addi $s2, $s2, 4
	sw $t1, ($s2) #grid[i][j+1] = '.'
	
	addi $s2, $s2, 4
	li $t1, 111
	sw $t1, ($s2) #grid[i][j+2] = 'o'
		
	jal solver #if solver(), return True
	beq $v1, 1, movedRight
	
	#else we undo the movement
	li $t1, 46
	sw $t1, ($s2) #grid[i][j+2] = '.'
	
	li $t1, 111
	addi $s2, $s2, -4
	sw $t1, ($s2) #grid[i][j+1] = 'o'
	
	addi $s2, $s2, -4
	sw $t1, ($s2) #grid[i][j] = 'o'	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra	
	
	movedRight:
	#printmsg4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

moveRight:	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	bgt $s1, 4, moveRight_end
	
	mul $s2, $s0, 7
	add $s2, $s2, $s1
	mul $s2, $s2, 4
	
	add $s2, $s2, board
	addi $s2, $s2, 4
	move $t1, $s2
	lw $s2, ($s2) #board[i][j+1]
	
	beq $s2, 111, rightCondition1 #if #board[i][j+1] = 'o'
	
	moveRight_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	rightCondition1:
	addi $t0, $0, 1
	addi $t1, $t1, 4
	lw $t1, ($t1) #board[i][j+2]		
	beq $t1, 46, rightCondition2 #if #board[i][j+2] = '.'
	j moveRight_end
	
	rightCondition2:
	li $a2, 1
	j moveRight_end
					
base_case: #only 1 peg left
	lw $t0, 0(end_index)
	beq $t0, 111, base_case_met 
	j solver_end #not met
	
base_case_met:
	li $v1, 1
	j solver_end
	
solver_end:
	lw $a1, 0($sp) #number of pegs
	lw $s0, 4($sp) #i
	lw $s1, 8($sp) #j
	lw $s2, 12($sp) #board[i][j]	
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra

#count number of pegs
counter:
	addi $sp, $sp, -20
	sw $s0, 0($sp) #i
	sw $s1, 4($sp) #j
	sw $s2, 8($sp) #board[i][j]
	sw $s3, 12($sp) #number of pegs
	sw $ra, 16($sp)
	
	li $s3, 0 #count of pegs
	li $s0, 0 #i
	
	for1:
	li $s1, 0 #j
	
	for2:
	beq $s1, 7, check_outer
	
	#check board[i][j]
	mul $s2, $s0, 7
	add $s2, $s2, $s1
	mul $s2, $s2, 4
	
	add $s2, $s2, board
	lw $s2, ($s2)
	
	beq $s2, 111, increment_count
	j increment_index
	
	increment_count:
	addi $s3, $s3, 1
	
	increment_index:
	addi $s1, $s1, 1
	j for2
	
	check_outer:
	addi $s0, $s0, 1
	beq $s0, 7, counting_end
	j for1

	counting_end:
	move $a1, $s3 #keep track of count of pegs
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra	
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																															
input:
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	read_str
	loop_store:
	beq $s0, 7, end_input 
	#$s1 contains a character
	lb $s1, line($s0)
	
	beq $s1, 69, found_E
	beq $s1, 79, found_O
	
	return:
	sw $s1, ($t0)
	addi $t0, $t0, 4
	addi $s0, $s0, 1
	j loop_store
	
	end_input:
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 8
	jr $ra
	
	found_E: #we store the address of E, and change 'E' to '.'
	la end_index, ($t0)
	li $s1, 46 #ASCII of "."
	j return 
	
	found_O: #we store the address of O, and change 'O' to 'o'
	la end_index, ($t0)
	li $s1, 111 #ASCII of "o"
	j return 
		
.data
	line: .space 9
	game_board: .word 0:49 #initialize the game board, 7 rows with 7 columns
	msg1: .asciiz "up "
	msg2: .asciiz "down "
	msg3: .asciiz "left "
	msg4: .asciiz "right "
	msg5: .asciiz "YES"
	msg6: .asciiz "NO"
