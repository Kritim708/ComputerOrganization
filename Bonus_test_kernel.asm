          .data 
          .text 
          .globl main
# Simple test - basic arithmetic, one negative immediate
main:

    # Turning the LED BULB on 
    addi $a0, $0, 1
    addi $v0, $0, 15
    syscall

    #Turning the LED BULB off
    addi $a0, $0, 0 
    addi $v0, $0, 15
    syscall

#RBG LED

    addi $t0, $0, 5

loop:
    # lw $t0, -240($0) #0xFFFFFF14 = read keyboard character
    # beq $t0, $0, endloop
    # lw $t0, -236($0) #0xFFFFFF14 = read keyboard character
    # sw $t0, -192($0)
    # sw $t0, -240($0)
    beq $t0, $0, endloop
    
    addi $v0, $0, 12
    syscall

    addi $a0, $v0, 0
    addi $v0, $0, 16
    syscall 
    
    addi $t0, $t0, -1
    j loop

endloop:


# JoyStick Controller
    addi $t0, $0, 2
loop2:
    beq $t0, $0, endloop2
    
    addi $a0, $0, -176
    addi $v0, $0, 17
    syscall

    addi $t6, $v0, 0            #Storing x value

    addi $a0, $0, -172
    addi $v0, $0, 17
    syscall

    addi $t7, $v0, 0            # Storing y value

    addi $t0, $t0, -1
    j loop2

endloop2:

#Button Controller
    addi $t0, $0, 2
loop3:
    beq $t0, $0, endloop3
    
    addi $v0, $0, 18
    syscall

    addi $t5, $v0, 0

    addi $t0, $t0, -1

    j loop3
endloop3:




#Slider and Buzzer Controller
    addi $t0, $0, 3
    addi $t1, $0, 0              # volume = max(127)
    addi $t2, $0, 300             # frequency = max(16383)
    addi $t3, $0, 0              # duty call = max(255)
    addi $t4, $0, 1             # swithch = 1
loop5:
    beq $t0, $0, endloop5

    addi $v0, $0, 20
    syscall

    # addi $t1, $t1, 30
    addi $t2, $t2, 200            
    addi $t3, $t3, 40 

    addi $a0, $v0, 0
    addi $a1, $0, -120
    addi $v0, $0, 21         
    syscall

    addi $a0, $t2, 0
    addi $a1, $0, -128
    addi $v0, $0, 21         
    syscall

    addi $a0, $t3, 0
    addi $a1, $0, -116
    addi $v0, $0, 21         
    syscall

    addi $a0, $t4, 0
    addi $a1, $0, -124
    addi $v0, $0, 21         
    syscall

    
    addi $t0, $t0, -1
    j loop5

endloop5:
    sw $t0, -124($0)        # To STOP the sound



#Switch Controller

    
    addi $a0, $0, 1
    addi $a1, $0, 1
    addi $v0, $0, 19
    syscall

    addi $a0, $0, 0
    addi $v0, $0, 19
    syscall

    addi $t8, $v0, 0 

    addi $v0, 0, 10
    syscall





