#This is starter code, so that you know the basic format of this file.
#Use _ in your system labels to decrease the chance that labels in the "main"
#program will conflict

.data
.text
_syscallStart_:
    beq $v0, $0, _syscall0 #jump to syscall 0
    addi $k1, $0, 1
    beq $v0, $k1, _syscall1 #jump to syscall 1
    addi $k1, $0, 5
    beq $v0, $k1, _syscall5 #jump to syscall 5
    addi $k1, $0, 9
    beq $v0, $k1, _syscall9 #jump to syscall 9
    addi $k1, $0, 10
    beq $v0, $k1, _syscall10 #jump to syscall 10
    addi $k1, $0, 11
    beq $v0, $k1, _syscall11 #jump to syscall 11
    addi $k1, $0, 12
    beq $v0, $k1, _syscall12 #jump to syscall 12
    addi $k1, $0, 13
    beq $v0, $k1, _syscall13 #jump to syscall 13
    addi $k1, $0, 15
    beq $v0, $k1, _syscall15 #jump to syscall 15
    addi $k1, $0, 16
    beq $v0, $k1, _syscall16 #jump to syscall 16
    addi $k1, $0, 17
    beq $v0, $k1, _syscall17 #jump to syscall 17
    addi $k1, $0, 18
    beq $v0, $k1, _syscall18 #jump to syscall 18
    addi $k1, $0, 19
    beq $v0, $k1, _syscall19 #jump to syscall 19
    addi $k1, $0, 20
    beq $v0, $k1, _syscall20 #jump to syscall 20
    addi $k1, $0, 21
    beq $v0, $k1, _syscall21 #jump to syscall 21
    addi $k1, $0, 22
    beq $v0, $k1, _syscall22 #jump to syscall 22

    #Error state - this should never happen - treat it like an end program
    j _syscall10


#=========================================
#Do init stuff
#=========================================
_syscall0:
    # Initialization goes here
    addi $sp, $0, -4096
    la $k1, _END_OF_STATIC_MEMORY_
    
    # specific address chosen to store heap pointer
    # Approved by Dr. Dollak
    sw $k1, -260($0)
    
    j _syscallEnd_


#=========================================
#Print Integer
#=========================================
_syscall1:
    # Print Integer code goes here


    # Stack pointer
    addi $sp, $sp, -20
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)

    addi $t0, $a0, 0
    addi $t3, $0, 10
    addi $t4, $0, 10


    #If it's negative
    slt $t1, $t0, 0
    beq $t1, $0, syscall_1_loop1

    addi $t1, $0, 45
    sw $t1, -256($0)

    addi $t1, $0, -1
    mult $t1, $t0
    mflo $t0


syscall_1_loop1:
    div $t0, $t4
    mflo $t1                            #qotient
    beq $t1, $0, end_syscall_1_loop1
    mult $t4, $t3
    mflo $t4
    j syscall_1_loop1 

end_syscall_1_loop1:

    div $t4, $t3
    mflo $t4

syscall_1_loop2:
    div $t0, $t4
    mflo $t1
    addi $t1, $t1, 48
    sw $t1, -256($0)
    mfhi $t0
    div $t4, $t3
    mflo $t4
    beq $t4, $0, end_syscall_1_loop2

    j syscall_1_loop2

end_syscall_1_loop2:

    #Putting values back from stack pointer
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    addi $sp, $sp, 20


    jr $k0
#=========================================
#       READ INTEGER
#=========================================
_syscall5:
    # Read Integer code goes here
    lw $k1, -240($0)                        #0xFFFFFF10 = keyboard ready
    beq $k1, $0, _syscall5                 #if no keypress, loop

    # Stack pointer
    addi $sp, $sp, -20
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)

    addi $t0, $0, 10
    addi $t2, $0, 48
    addi $t3, $0, 58

    addi $v0, $0, 0
    addi $v1, $0, 0                 # Approved by Dr. Dollak

syscall_5_loop:
    
    lw $t1, -236($0) 

    slt $t4, $t1, $t2
    bne $t4, $0, end_syscall_5_loop

    slt $t4, $t1, $t3
    beq $t4, $0, end_syscall_5_loop

    addi $v1, $0, 1                 # Approved by Dr. Dollak
    
    sw $t1, -240($0)

    mult $v0, $t0
    mflo $v0
    add $v0, $v0, $t1
    addi $v0, $v0, -48

    j syscall_5_loop

end_syscall_5_loop:

    #Putting values back from stack pointer
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    addi $sp, $sp, 20


    jr $k0

#=========================================
#       HEAP ALLOCATION
#=========================================
_syscall9:
    # Heap allocation code goes here

    lw $v0, -260($0)
    add $k1, $v0, $a0
    sw $k1, -260($0)

    jr $k0


#=========================================
#       TERMINATE PROGRAM
#=========================================
_syscall10:
    j _syscall10



#=========================================
#       PRINT CHARACTER
#=========================================
_syscall11:

    # print character code goes here
    sw $a0, -256($0)
    jr $k0


#=========================================
#       READ CHARACTER
#=========================================
_syscall12:
    # read character code goes here
    
    lw $k1, -240($0)                        #0xFFFFFF10 = keyboard ready
    beq $k1, $0, _syscall11                 #if no keypress, loop
    lw $v0, -236($0)
    sw $k1, -240($0)   

    jr $k0
    

#extra credit syscalls go here?

#=========================================
#       CLEARS SCREEN
#=========================================
_syscall13:
    # print character code goes here
    lw $k1, -252($0)
    jr $k0


#=====================================
#       RED LIGHT
#=====================================
_syscall15:
    #a0 == 0 to turn the redlight off and 1 to turn it on
    sw $a0, -208($0)
    jr $k0


#=====================================
#       RGB LIGHT BLINKER
#=====================================
_syscall16:
    #a0 == ascii value of 'r', 'g' or 'b' to turn light red, green or blue respectively
    sw $a0, -192($0)
    jr $k0

#=====================================
#       JoyStick Controller
#=====================================
_syscall17:
    #a0 == -176 for x and a1 == -172 for y
    lw $v0, 0($a0)
    jr $k0


#=====================================
#       Button Controller
#=====================================
_syscall18:
    # returns value of button in $v0
    lw $v0, -160($0)
    jr $k0

#=====================================
#       Switch Controller (YET TO BE DONE)
#=====================================
_syscall19:
    # $a1 == 0 to get value from switch
    # $a1 == 1 to put value in switch

    beq $a1, $0, store_value
    sw $a0, -140($0)
    jr $k0

store_value:
    lw $v0, -144($0)                # returns value of button in $v0
    jr $k0


#=====================================
#       SLIDER Controller 
#=====================================
_syscall20:
    # returns value of SLIDER in $v0
    lw $v0, -112($0)
    jr $k0

#=====================================
#       Buzzer Controller 
#=====================================
_syscall21:
    # $a0 = value to be stored
    # $a1 = address to be stored at 
    #       volume      -126
    #       frequency   -128
    #       duty call   -116
    #       switch      -124
    sw $a0, 0($a1)
    jr $k0


_syscallEnd_:

