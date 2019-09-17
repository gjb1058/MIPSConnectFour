# FILE:         logic.asm
# AUTHOR:       Grant J. Bierly, RIT 2019
#
# EMAIL:	gjb1058@g.rit.edu
# CONTRIBUTORS:
#		
#
# DESCRIPTION:
#	This file contains the logic functions to run ConnectFour
TERMINATE_PRGM = 10
#Global definitions
.text
.globl	grabVal
.globl	checkCol
.globl	placeInCol
.globl	placeVal
.globl	checkIfFull
.globl	checkLeftDiagonal
.globl  checkRightDiagonal
# FUNCTION: checkCol
# 
# DESC: Checks if the given Col number is able to take an item.
#
# PARAM:
# $a0	Col Number
# 
# RETURNS:
# 0	if false (Cannot take an item)
# 1	if true (Can take an item)

checkCol:
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
	
	li	$s1, 0		#Row Index
	move	$s2, $a0	#Col Number

	move	$a1, $s1	#Load in Row
	move	$a2, $s2	#Load in Col
	jal grabVal
	move	$s5,$v0		#Get the value at the top
	li	$t1,32		#Load in the space character
	
	#If you want to print the grabVal value
	#li	$v0,1
	#move	$a0,$s5
	#syscall



	#If the space is not equal to 32, we know the top of the
	#col is taken. Therefore, the Col is full.
	bne	$s5,$t1,isOccupied


	#Else, it's a space. Return True
	li	$v0,1
	j restoreStack2

isOccupied:
	#The Col is occupied. Return False
	li	$v0,0
	j restoreStack2

# FUNCTION: checkCol
# 
# DESC: Checks if the given Col number is able to take an item.
#
# PARAM:
# $a0	CharCode
# $a1	ColNum
# RETURNS:
# Nothing

placeInCol:
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
		
	move	$s0,$a0		#Load in the Char Code
	li	$s1,0		#Load in our row Index
	move	$s2,$a1		#Load in the Col Number.
	li	$s3,6		#numRows
	j placeColLoop		#Jump into our Loop

placeColLoop:
	slt	$t0, $s1, $s3	#If rowIndex<numRows, $t0 == 1

	beq	$t0, $zero, preparePlaceVal #if $t1==1, we hit bottom

	move	$a1, $s1	#Load in our Row number
	move	$a2, $s2	#Load in our Col number
	
	jal grabVal		#Grab the value

	move	$s5, $v0	#Load that value into $s5

	#If you want to print the contents
	#li	$v0,1
	#move	$a0,$s5
	#syscall

	li	$t1, 32		#Load in the code for an empty space


	#If the spot isn't equal to 32, we know the spot above
	#is the last empty spot, so jump to preparePlaceVal
	bne	$s5, $t1, preparePlaceVal 

	addi	$s1, $s1, 1	#Otherwise, add one and continue
	j placeColLoop

preparePlaceVal:
	move 	$a0, $s0	#Load in our Char Code
	addi	$s1, $s1, -1	#Row above, which is clear.
	move	$a1, $s1	#Load in our Row number
	move	$a2, $s2	#Load in our Col number
	jal	placeVal	#Call place value
	j 	restoreStack2	#restore the stack

# FUNCTION: checkIfFull
# 
# DESC: Checks if all top slots are taken.
#
# PARAM:
# None
#
# RETURNS:
# 0 if False
# 1 if True

checkIfFull:
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
	
	li	$s1,0		#Row
	li	$s2,0		#Col
	li	$s3,7		#numCols
	li	$s4,32		#32 = space code

	j	checkFullLoop	#Jump to our loop

checkFullLoop:
	slt	$t0, $s2, $s3	#if Col<numCols, $t0==1

	#If $t0==0, we've hit the end of the board and it is Full.
	beq	$t0, $zero, boardFull

	move	$a1, $s1	#Load Row
	move	$a2, $s2	#Load Col
	
	jal	grabVal		#Grab Value at Location

	move	$s5,$v0		#Load value

	#If the value is equal to 32, it is a space. Which means
	#there is room to continue.
	beq	$s5,$s4, boardNotFull
	
	#Else, the current spot was taken. Increase and continue loop.
	addi	$s2, $s2, 1
	j 	checkFullLoop

boardFull:
	li	$v0, 1
	j	restoreStack2

boardNotFull:
	li	$v0, 0
	j	restoreStack2

# FUNCTION: checkVertical
# 
# DESC: Checks all verticals.
#	Formula: Increase the row by one.
#	Only need to check up to row 2
#	Check: [row,col],[row+1,col],[row+2,col],[row+3,col]
#
# PARAM:
# None
#
# RETURNS:
# 0 if False
# Char Code if Win

checkVertical:
		
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
	
	li	$s0, 0
	li	$s1, 0
	li	$s2, 3	#numRows for vertical
	li	$s3, 7	#numCols for Horizonal

	j checkVertRows

checkVertRows:
	slt	$t0, $s0, $s2	#If our index is less than max, set 1

	#Otherwise, we've reached the limit.
	beq	$t0, $zero, checkVertFalse
	
	j	checkVertCols	#Jump into the Cols loop.

checkVertCols:

	slt	$t0, $s1, $s3	#If our index is less than max, set 1
	
	#Otherwise, we've reached the limit
	beq	$t0, $zero, checkVertRowsP2
	
	move	$a1, $s0	#Load row
	move	$a2, $s1	#Load col
	jal	grabVal		#grabVal

	move	$s4, $v0	#Get Result
	li	$t7, 32

	#Check if it is a space. If it is, skip the rest.
	beq	$s4, $t7, checkVertColsP2

	addi	$t5, $s0, 1	#Increment row

	move	$a1, $t5	#Load row+1
	move	$a2, $s1	#Load col
	jal 	grabVal		#grabVal

	move	$s5, $v0	#Get Result
	li	$t7, 32
	beq	$s5, $t7, checkVertColsP2

	addi	$t5, $s0, 2

	move	$a1, $t5	#Load row+2
	move	$a2, $s1	#Load col
	jal	grabVal

	move	$s6, $v0
	li	$t7, 32
	beq	$s6, $t7, checkVertColsP2

	addi	$t5, $s0, 3	#Increment Row

	move	$a1, $t5	#Load row+3
	move	$a2, $s1	#Load col
	jal	grabVal

	move	$s7, $v0
	
	#Now I have four values. I and them all together, to ensure they
	#all match eachother. If any doesn't match at the end, clearly
	#that is not a win.
	and	$t4, $s4, $s5
	and	$t5, $s5, $s6
	and	$t6, $s6, $s7
	and	$t7, $s4, $s7

	bne	$t4, $s4, checkVertColsP2
	bne	$t5, $s4, checkVertColsP2
	bne	$t6, $s4, checkVertColsP2
	bne	$t7, $s4, checkVertColsP2

	#Either way, let's grab the Char Code just in case it is a win.
	move	$a1, $s0
	move	$a2, $s1
	jal 	grabVal
	move	$a0, $v0
	
	#with the bne statements, we've established they all match.
	#Jump into the checkVertWin, to return a win code.
	beq	$t4, $s4, checkVertWin

	j checkVertColsP2	#Just in case.

checkVertColsP2:
	
	addi	$s1, $s1, 1	#Increment the Col index
	
	j 	checkVertCols	#Continue the loop.

checkVertRowsP2:
	addi	$s0, $s0, 1	#Increment the Row index
	li	$s1, 0		#Set the Col Index to zero
	j checkVertRows		#Continue the Row Loop

checkVertFalse:		
	li	$v0, 0		#No matches detected. Return a 0.
	j	restoreStack2	#Restore the stack.

checkVertWin:
	move	$v0, $a0	#Match detected. Load in winner
	j	restoreStack2	#Restore the stack


# FUNCTION: checkHorizontal
# 
# DESC: Checks all Horizontals.
#	Only need to check up to col 3
#	Formula: Increase col by one
#	Check [row,col],[row,col+1],[row,col+2],[row,col+3]
# PARAM:
# None
#
# RETURNS:
# 0 if False
# Char Code if Win


#NOTE: The rest of the logic checks are basically just
#checkVertical but slightly altered. (different numRows,
#numCols, and increments. I'll highlight differences
#between the various checks, but the same items will not
#be repeatedly commented.


checkHorizontal:
		
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
	
	li	$s0, 0
	li	$s1, 0
	li	$s2, 6	#numRows for vertical
	li	$s3, 4	#numCols for Horizonal

	j checkHorizRows

checkHorizRows:
	slt	$t0, $s0, $s2
	beq	$t0, $zero, checkVertFalse
	
	j	checkHorizCols

checkHorizCols:
	slt	$t0, $s1, $s3
	beq	$t0, $zero, checkHorizRowsP2
	
	move	$a1, $s0
	move	$a2, $s1
	jal	grabVal

	move	$s4, $v0
	li	$t7, 32
	beq	$s4, $t7, checkHorizColsP2
	addi	$t5, $s1, 1	#Increment Col by 1

	move	$a1, $s0
	move	$a2, $t5
	jal 	grabVal

	move	$s5, $v0
	li	$t7, 32
	beq	$s5, $t7, checkHorizColsP2

	addi	$t5, $s1, 2	#Increment Col by 2

	move	$a1, $s0
	move	$a2, $t5
	jal	grabVal

	move	$s6, $v0
	li	$t7, 32
	beq	$s6, $t7, checkHorizColsP2

	addi	$t5, $s1, 3	#Increment Col by 3

	move	$a1, $s0
	move	$a2, $t5
	jal	grabVal

	move	$s7, $v0
	
	and	$t4, $s4, $s5
	and	$t5, $s5, $s6
	and	$t6, $s6, $s7
	and	$t7, $s4, $s7

	bne	$t4, $s4, checkHorizColsP2
	bne	$t5, $s4, checkHorizColsP2
	bne	$t6, $s4, checkHorizColsP2
	bne	$t7, $s4, checkHorizColsP2

	move	$a1, $s0
	move	$a2, $s1
	jal 	grabVal
	move	$a0, $v0
	
	beq	$t4, $s4, checkHorizWin
	j checkHorizColsP2
	#else
checkHorizColsP2:
	addi	$s1, $s1, 1
	j 	checkHorizCols
checkHorizRowsP2:
	addi	$s0, $s0, 1
	li	$s1, 0
	j checkHorizRows

checkHorizFalse:
	li	$v0, 0
	j	restoreStack2

checkHorizWin:
	move	$v0, $a0
	j	restoreStack2


# FUNCTION: checkLeftDiagonal
# 
# DESC: Checks all Left Diagonals (\).
#	Function: Add col and row by one.
#	Only have to check rows 0-2, cols 0-3
#	Check: [row,col],[row+1,col+1],[row+2,col+2],[row+3,col+3]
# PARAM:
# None
#
# RETURNS:
# 0 if False
# Char Code if Win


checkLeftDiagonal:
		
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
	
	li	$s0, 0
	li	$s1, 0
	li	$s2, 3	#numRows for vertical
	li	$s3, 4	#numCols for Horizonal

	j checkLDiagRows

checkLDiagRows:
	slt	$t0, $s0, $s2
	beq	$t0, $zero, checkLDiagFalse
	
	j	checkLDiagCols

checkLDiagCols:
	slt	$t0, $s1, $s3
	beq	$t0, $zero, checkLDiagRowsP2
	
	move	$a1, $s0
	move	$a2, $s1
	jal	grabVal

	move	$s4, $v0
	li	$t7, 32
	beq	$s4, $t7, checkLDiagColsP2

	addi	$t5, $s0, 1	#Increase row
	addi	$t6, $s1, 1	#Increase col

	move	$a1, $t5
	move	$a2, $t6
	jal 	grabVal

	move	$s5, $v0
	li	$t7, 32
	beq	$s5, $t7, checkLDiagColsP2

	addi	$t5, $s0, 2	#Increase Row
	addi	$t6, $s1, 2	#Increase Col

	move	$a1, $t5
	move	$a2, $t6
	jal	grabVal

	move	$s6, $v0
	li	$t7, 32
	beq	$s6, $t7, checkLDiagColsP2

	addi	$t5, $s0, 3	#Increase Row
	addi	$t6, $s1, 3	#Increase Col

	move	$a1, $t5
	move	$a2, $t6
	jal	grabVal

	move	$s7, $v0
	
	#And it all together, check.
	and	$t4, $s4, $s5
	and	$t5, $s5, $s6
	and	$t6, $s6, $s7
	and	$t7, $s4, $s7

	bne	$t4, $s4, checkLDiagColsP2
	bne	$t5, $s4, checkLDiagColsP2
	bne	$t6, $s4, checkLDiagColsP2
	bne	$t7, $s4, checkLDiagColsP2

	move	$a1, $s0
	move	$a2, $s1
	jal 	grabVal
	move	$a0, $v0
	
	beq	$t4, $s4, checkLDiagWin

	j	checkLDiagColsP2
	
	#else
checkLDiagColsP2:
	addi	$s1, $s1, 1
	j 	checkLDiagCols
checkLDiagRowsP2:
	addi	$s0, $s0, 1
	li	$s1, 0
	j	 checkLDiagRows

checkLDiagFalse:
	li	$v0, 0
	j	restoreStack2

checkLDiagWin:
	move	$v0, $a0
	j	restoreStack2


# FUNCTION: checkRightDiagonal
# 
# DESC: Checks all Right Diagonals (/).
#	Function: Decrease row by 1, increase col by 1
#	Only need to check rows 3-5, cols 0-4
#	Check: [row,col],[row-1,col+1],[row-2,col+2],[row-3,col+3]
#
# PARAM:
# None
#
# RETURNS:
# 0 if False
# Char Code if Win


checkRightDiagonal:
		
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
	
	li	$s0, 3	#Start at row 3
	li	$s1, 0
	li	$s2, 6	#numRows for vertical
	li	$s3, 4	#numCols for Horizonal

	j checkRDiagRows

checkRDiagRows:
	slt	$t0, $s0, $s2
	beq	$t0, $zero, checkRDiagFalse
	
	j	checkRDiagCols

checkRDiagCols:
	slt	$t0, $s1, $s3
	beq	$t0, $zero, checkRDiagRowsP2
	
	move	$a1, $s0
	move	$a2, $s1
	jal	grabVal
	
	move	$s4, $v0
	li	$t7, 32
	beq	$s4, $t7, checkRDiagColsP2

	addi	$t5, $s0, -1	#Decrease row by one
	addi	$t6, $s1, 1	#Increase col

	move	$a1, $t5
	move	$a2, $t6
	jal 	grabVal


	move	$s5, $v0
	li	$t7, 32
	beq	$s5, $t7, checkRDiagColsP2

	addi	$t5, $s0, -2	#Decrease row by two
	addi	$t6, $s1, 2	#Increase col

	move	$a1, $t5
	move	$a2, $t6
	jal	grabVal

	move	$s6, $v0
	li	$t7, 32
	beq	$s6, $t7, checkRDiagColsP2

	addi	$t5, $s0, -3	#Decrease row by 3
	addi	$t6, $s1, 3	#Increase col

	move	$a1, $t5
	move	$a2, $t6
	jal	grabVal

	move	$s7, $v0

	#Again, use the and check like previously
	and	$t4, $s4, $s5
	and	$t5, $s5, $s6
	and	$t6, $s6, $s7
	and	$t7, $s4, $s7

	bne	$t4, $s4, checkRDiagColsP2
	bne	$t5, $s4, checkRDiagColsP2
	bne	$t6, $s4, checkRDiagColsP2
	bne	$t7, $s4, checkRDiagColsP2

	move	$a1, $s0
	move	$a2, $s1
	jal 	grabVal
	move	$a0, $v0
	
	beq	$t4, $s4, checkRDiagWin
	j checkRDiagColsP2
	#else
checkRDiagColsP2:
	addi	$s1, $s1, 1
	j 	checkRDiagCols
checkRDiagRowsP2:
	addi	$s0, $s0, 1
	li	$s1, 0
	j	 checkRDiagRows

checkRDiagFalse:
	li	$v0, 0
	j	restoreStack2

checkRDiagWin:
	move	$v0, $a0
	j	restoreStack2


#Restore Stack function.
restoreStack2:
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


