# FILE:         terminal.asm
# AUTHOR:       Grant J. Bierly, RIT 2019
#               
# EMAIL:	gjb1058@g.rit.edu
# 
# CONTRIBUTORS:
#		
#
# DESCRIPTION:
#	This file contains all printing functions of ConnectFour
#


PRINT_INT = 1
PRINT_STR = 4
READ_INT  = 5

numRows=6
numCols=7

.data
welcome:	.ascii 	"   ************************\n"
		.ascii 	"   **    Connect Four    **\n"
		.asciiz	"   ************************\n"

numbers:	.asciiz	"   0   1   2   3   4   5   6\n"
border:		.asciiz	"+-----------------------------+\n"
gridrow:	.asciiz "|+---+---+---+---+---+---+---+|\n"
gridrowstart: 	.asciiz "|| "
gridrowmid:	.asciiz " | "
gridrowend:	.asciiz " ||\n"
newline:	.asciiz "\n"
player1:	.asciiz	"X"
player2:	.asciiz	"O"
unclaimed:	.asciiz	" "
ERROR:		.asciiz	"?"
Player1Prompt:	.asciiz	"Player 1: select a row to place your coin (0-6 or -1 to quit):"
Player2Prompt:	.asciiz	"Player 2: select a row to place your coin (0-6 or -1 to quit):"
invalidRow:	.asciiz "Illegal column number.\n"
rowFull:	.asciiz "Illegal move, no more room in that column.\n"
tieGame:	.asciiz "The game ends in a tie.\n\n"
P1Win:		.asciiz "Player 1 wins!\n"
P2Win:		.asciiz "Player 2 wins!\n"
P1Quit:		.asciiz "Player 1 quit.\n"
P2Quit:		.asciiz "Player 2 quit.\n"

.align 2
.text

.globl 	main
.globl	board
.globl	printWelcome
.globl	generateBoard
.globl 	WIDTH
.globl 	grabVal
.globl	printSection
.globl	promptPrint
.globl 	printError
.globl  grabInput
.globl  gameOver
.globl  endProgram
# FUNCTION: printWelcome
# 
# DESC: Prints the Welcome message
#
# PARAM:
# Nothing
# 
# RETURNS:
# Nothing
printWelcome:
	li	$v0, PRINT_STR
	la	$a0, welcome
	syscall
	
	jr	$ra

# FUNCTION: printVal
# 
# DESC: Prints a value. ' ' for 0, 'X' for 1, and 'O' for 2
#
# PARAM:
# $a0: A number that's 0, 1, or 2
# 
# RETURNS:
# Nothing
printVal:

	addi	$sp, $sp, -40	# allocate stackframe
        sw      $ra, 32($sp)    # store the ra & s reg's on the stack
        sw      $s7, 28($sp)
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)
	
	li	$v0, PRINT_STR
	move	$s0, $a0
	li	$t1, 88
	li	$t2, 79
	li	$t3, 32
	bne	$a0, $t3, occupied	#branch if space is not empty
	la	$a0, unclaimed		#Otherwise, load the space
	syscall				#Print
	j	restoreStack		#Restore stack

occupied: 
	bne	$a0, $t1, p2		#If it is not 88, it's player 2
	la	$a0, player1		#Load player1 char
	syscall				#Print
	j	restoreStack		#Restore stack

p2:
	bne	$a0, $t2, unknown	#If not 79, unrecognized char
	la	$a0, player2		#Load player 2 char
	syscall				#print
	j 	restoreStack		#Restore stack

unknown:
	la	$a0, ERROR		#Load the ? char
	syscall				#print
	j 	restoreStack		#Restore stack
	
# FUNCTION: printBoard
# 
# DESC: Prints the Board given to it.
#
# PARAM:
# $a0: Address of the board
# 
# RETURNS:
# Nothing
printBoard:
	addi	$sp, $sp, -40	# allocate stackframe
        sw      $ra, 32($sp)    # store the ra & s reg's on the stack
        sw      $s7, 28($sp)
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)
	#jal 	generateBoard
	#move	$s7, $a0	#Save the board!
	#Print the upper borders
	la	$v0, PRINT_STR
	la	$a0, newline
	syscall
	
	la	$a0, numbers
	syscall

	la	$a0, border
	syscall

	la	$a0, gridrow
	syscall

	#Iterate though and print everything.
	li	$s0, 0		#Row Index
	li	$s1, 0		#Col Index
	li	$s2, numRows
	#li	$t8, 6
	li	$s3, numCols
	#li	$t9, 6
	#Go in
	j rowLoop

#Done, print bottom of board.
finishBoard:

	la	$a0, border
	syscall

	la	$a0, numbers
	syscall
	
	la	$a0, newline
	syscall

	j	restoreStack

#Iterate though all rows
rowLoop:
	
	slt	$t0, $s0, $s2
	beq	$t0, $zero, finishBoard
	
	la	$a0, gridrowstart
	syscall

	j	colLoop

#When finished with row, move to next.
rowLoopPt2:
	la	$a0, gridrowend
	syscall

	la	$a0, gridrow
	syscall

	addi	$s0, $s0, 1
	li	$s1, 0
	j rowLoop

#Iterate though all cols
colLoop:
	
	#If we're at the numCols, move on to next row.
	slt	$t0, $s1, $s3
	beq	$t0, $zero, rowLoopPt2
	
	move	$a1, $s0
	move	$a2, $s1

	jal	grabVal		#Grab vlaue
	
	move	$s3, $v0	#Load it in.
	move	$a0, $s3
	li	$v0, PRINT_STR
	jal	printVal	#Print it!
	

	li	$v0, PRINT_STR
	addi	$s1, $s1, 1

	slt	$t0, $s2, $s1
	bne	$t0, $zero, rowLoopPt2

	la	$a0, gridrowmid	#Print separator
	syscall

	j colLoop


# FUNCTION: printError
#
# DESC: Prints an error message from a given error code
#
# PARAM:
# $a0: Error Code
#
#	1 = Invalid Row Number
# 	2 = Full Row

printError:
	li	$t0,1
	beq	$a0,$t0,invalidSlot
	li	$t0,2
	beq	$a0,$t0,selectionFull
	j	printSection

invalidSlot:

	li	$v0,PRINT_STR
	la	$a0,invalidRow
	syscall
	j 	promptPrint

selectionFull:
	li	$v0,PRINT_STR
	la	$a0,rowFull
	syscall
	j	promptPrint

# FUNCTION: printPrompt
# 
# DESC: Prints the prompt for the player given to it.
#
# PARAM:
# $a0: Player Number (1 for Xs, 2 for Os)
# 
# RETURNS:
# Nothing

printPrompt:
	addi	$sp, $sp, -40	# allocate stackframe
        sw      $ra, 32($sp)    # store the ra & s reg's on the stack
        sw      $s7, 28($sp)
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)

	move	$t0,$a0
	li	$t1,1
	li	$t2,2
	beq	$t0,$t1,printPlayer1	#It's a player 1 prompt.
	
	li	$v0, PRINT_STR
	la	$a0, Player2Prompt	#It's a player 2 prompt
	
	syscall				#Print

	j restoreStack			#restore stack.

printPlayer1:
	li	$v0, PRINT_STR		
	la	$a0, Player1Prompt	#Print player 1 prompt
	
	syscall
	
	j restoreStack			#restore stack.


# FUNCTION: gameOver
# 
# DESC: Game over detected, prints appropriate matching message.
#
# PARAM:
# $a0: gameOver code.
# 
# RETURNS:
# Nothing


gameOver:
	
	move	$s0, $a0
	li	$t1, 1
	beq	$s0, $t1, Player1Quit	#Player 1 quit, print that!
	li	$t1, 2
	beq	$s0, $t1, Player2Quit	#Player 2 quit, print that!

	#Otherwise, this was a win/full board
	jal	printBoard		#Print the board

	li	$t1, 0			#If it is a zero, the game was a tie.
	beq	$s0, $t1, gameTie	#Print the game tie message.

	li	$t1, 88			#If it's a P1 char code, P1 wins.
	beq	$s0, $t1, Player1Win	#Print Player 1 Win message

	li	$t1, 79			#If it's a P2 char code, P2 wins.
	beq	$s0, $t1, Player2Win	#Print Player 2 Win message

	j	endProgram		#End game.

#Print game tie message
gameTie:

	li	$v0, PRINT_STR
	la	$a0, tieGame
	syscall
	j 	endProgram

#Print player 1 win
Player1Win:
	li	$v0, PRINT_STR
	la	$a0, P1Win
	syscall
	j 	endProgram

#Print player 2 win
Player2Win:
	li	$v0, PRINT_STR
	la	$a0, P2Win
	syscall
	j 	endProgram

#Print player 1 quit
Player1Quit:
	li	$v0, PRINT_STR
	la	$a0, P1Quit
	syscall
	j 	endProgram

#Print player 2 quit
Player2Quit:
	li	$v0, PRINT_STR
	la	$a0, P2Quit
	syscall
	j 	endProgram

#Restore stack
restoreStack:
	#Clean up, restore, and exit!
	lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
        lw      $s7, 28($sp)
        lw      $s6, 24($sp)
        lw      $s5, 20($sp)
        lw      $s4, 16($sp)
        lw      $s3, 12($sp)
        lw      $s2, 8($sp)
        lw      $s1, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp, $sp, 40     # clean up stack
	jr	$ra

