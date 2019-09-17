# FILE:         connect4.asm
# AUTHOR:       Grant J. Bierly, RIT 2019
#
# EMAIL:	gjb1058@g.rit.edu
# CONTRIBUTORS:
#		
#
# DESCRIPTION:
#	This file contains the main function to run ConnectFour
TERMINATE_PRGM = 10
READ_INPUT = 5
PRINT_STR = 4
.data
spacer: .asciiz	"\n"
#Global definitions
.text
.globl	connect4
.globl 	board
.globl  terminalgui
.globl  logic
.globl	printWelcome
.globl  printBoard
.globl	printPrompt
.globl	printSection
.globl	promptPrint
.globl 	printError
.globl	checkCol
.globl	placeInCol
.globl	checkIfFull
.globl  checkVertical
.globl	checkHorizontal
.globl	checkLeftDiagonal
.globl  checkRightDiagonal
.globl	gameOver
.globl	endProgram

# FUNCTION: main.asm
#
# DESC: Runs the game, chaining functions and loops together
# that calls printing and logic functions.
#
# PARAM:
# None
#
# RETURNS:
# Nothing
main:
	jal 	printWelcome
	li	$s0, 1
	j printSection

#Print the board, and load the player number
printSection:
	jal	printBoard
	move	$a0,$s0
	j	promptPrint

#Print the prompt.
promptPrint:
	move	$a0,$s0
	jal	printPrompt
	j	grabInput

#Grab the input, then test if valid.
grabInput:
	li	$v0,READ_INPUT
	syscall

#	li	$v0,PRINT_STR
#	la	$a0, spacer
#	syscall

	move	$s6, $v0
	slt	$t1, $v0, $zero
	li	$t2, 1
	li	$t3, -1
	li	$t6, 6
	move	$s6, $v0		#If -1
	beq	$s6, $t3, playerLeft	#The current player left.
	
	li	$a0, 1
	beq	$t1, $t2, LOAD_ERROR	#Out of bounds.
	slt	$t1, $t6, $v0
	li	$a0, 1
	beq	$t1, $t2, LOAD_ERROR	#Out of bounds.
	li	$a0, 0
	j	prepareInput

#Jumps to our error function.
LOAD_ERROR:
	j 	printError

#Check if the Col has room, then get ready to place.
prepareInput:

	
	move	$a0, $s6
	jal	checkCol
	
	# 0 = no room, load an error code 2
	move	$s5, $v0
	li	$a0, 2
	beq	$s5, $zero, LOAD_ERROR
	
	j	getCharCode

#Where we do the input, then check everything.
placeInput:

	#First, load in the selection and place it in.
	move	$a0, $v0
	move	$a1, $s6
	jal	placeInCol

	#After placement, check for Vertical wins
	jal	checkVertical
	move	$t3, $v0
	move	$a0, $t3	#Get the result of the check
	
	#0 = No win
	bne	$t3, $zero, printGameOver

	#After placement, check for Horizontal wins
	jal	checkHorizontal
	move	$t3, $v0
	move	$a0, $t3	#Get the result of the check
	
	#0 = No Win
	bne	$t3, $zero, printGameOver
	
	#After placement, check for Left Diagonal wins \
	jal	checkLeftDiagonal
	move	$t3, $v0
	move	$a0, $t3	#Get the result of the check
	
	#0 = No win
	bne	$t3, $zero, printGameOver

	#After placement, check for Right Diagonal wins /
	jal	checkRightDiagonal
	move	$t3, $v0
	move	$a0, $t3	#Get the result of the check
	
	#0 = No win
	bne	$t3, $zero, printGameOver
	
	#Then, we check if the board is full.
	jal	checkIfFull
	li	$t1, 1
	li	$a0, 0	
	beq	$v0, $t1, printGameOver

	#If we pass all checks, we switch players.
	j	switchPlayer

#A win has been detected.
printGameOver:
	j 	gameOver	#Jump to game over

#Somebody left the game
playerLeft:
	move	$a0, $s0	#Load the player that quit.
	j 	gameOver	#Jump to game over

#Get the character code (ASCII).
getCharCode:
	li	$t1, 2
	beq	$s0,$t1,setPlayer2
	li	$v0, 88
	j	placeInput

#Get player 2 char code
setPlayer2:
	li	$v0, 79
	j	placeInput

#Switch the player to the next one.
switchPlayer:
	li	$t1, 1
	beq	$s0, $t1, switchToTwo
	li	$s0, 1
	j	printSection

switchToTwo:
	li	$s0, 2
	j	printSection

#End the program via termination.
endProgram:
	li	$v0, TERMINATE_PRGM
	syscall
