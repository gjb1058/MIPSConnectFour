# FILE:         board.asm
# AUTHOR:       Grant J. Bierly, RIT 2019
#               
# CONTRIBUTORS:
#		
#
# EMAIL:	gjb1058@g.rit.edu
#
# DESCRIPTION:
#	This file contains functions that maintain the board.
#	Has getters, generators, etc.
#	My Board uses ROW-MAJOR order
#
.data

#We use this string to store the board values.
#We use ROW MAJOR order
playerboard: .ascii "                                          "  

.align 2
numRows =6	#The width of our connect four board is constant
numCols =7
#0s are for no player.
#1s are for player 1 (X)
#2s are for player 2 (O)
.text
.globl	board


# FUNCTION: grabVal
#
# DESC: Grabs a value. Think board[row][col] and returns.
#
# PARAM:
# $a0: Address of the board
# $a1: Row number
# $a2: Col Num
#
# RETURNS:
# $v0: 0,1, or 2 for the array
grabVal:	
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
	
	la	$s0, playerboard	#Load the address of the board
	move	$s1, $a1	#Load the Row Number
	move	$s2, $a2	#Load the Col Number

	#Calculate the True Index (SIZE of a Byte is 1)
	#FORMULA: Base Address + ((row*numCols)+colIndex * SIZE)
	mul	$s3, $s1, numCols
	add	$s3, $s3, $s2
	#Now we have our index. Get the value
	add	$s3, $s3, $s0
	
	move	$t0, $a0
	lb	$v0, 0($s3)

	#Copied from Ex5 :)
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

# FUNCTION: placeVal
#
# DESC: Places a value in the designated board slot
#
# PARAM:
# $a0: charCode
# $a1: Row number
# $a2: Col Num
#
# RETURNS:
# Nothing

placeVal:
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
	
	la	$s0, playerboard	#Load the address of the board
	move	$s1, $a1	#Load the Row Number
	move	$s2, $a2	#Load the Col Number
	
	#Calculate the True Index
	#FORMULA: Base Address + ((row*HEIGHT)+colIndex * 4)
	mul	$s3, $s1, numCols
	add	$s3, $s3, $s2
	#Now we have our index. Get the value
	add	$s3, $s3, $s0
	
	move	$t0, $a0
	sb	$a0, 0($s3)

	#Copied from Ex5 :)
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
