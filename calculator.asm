          .data 
            
          .text 
          .globl main
# Simple test - basic arithmetic, one negative immediate
main:

    
    # $t1                 first_operand
    # $t2                 operand
    # $t3                 second_operand
    # $t4                 result
    # $t5                 closed_bracket_ascci
    # $t6                 temp_result
    # $t7                 enter_ascii

    # $s0                  add_ascii
    # $s1                  sub_ascii
    # $s2                  mult_ascii
    # $s3                  div_ascii
    # $s4                  calculation_completed
    # $s5                  close_parenthesis_ascii
    # $s6                  "_" ascii c

    # $a0                 prev_value



    addi $t0, $0, 0
    addi $t4, $0, 0
    addi $t5, $0, 41
    addi $t7, $0, 10

    addi $sp, $sp, -4           #This should be where the result eventually be

    addi $s0, $0, 43
    addi $s1, $0, 45
    addi $s2, $0, 42
    addi $s3, $0, 47
    addi $s4, $0, 0
    addi $s6, $0, 95

loop_input:
    bne $s4, $0, end

    lw $v0, -240($0)                        # 0xFFFFFF10 = keyboard ready
    beq $v0, $0, loop_input 

    addi $v0, $0, 5                         # Calls for integer
    syscall

    beq $v1, $0, getchar                    # Was no integer
    
    addi $sp, $sp, -4                       # Stores to memory if integer
    sw $v0, 0($sp)
    
    j loop_input                            # asks for another input


getchar:                                    
    addi $v0, $0, 12                        # Gets the char as not integer
    syscall

    beq $v0, $t5, calculate                 # When the operand is closed bracket

    beq $v0, $t7, last_calculation          # when the q is written (one more operand remaining)

    addi $sp, $sp, -4                       # Stores the char in memory if it isn't special characters
    sw $v0, 0($sp)
    j loop_input

last_calculation:
    addi $s4, $0, 1


calculate:
    lw $t3, 0($sp)
    lw $t2, 4($sp)
    lw $t1, 8($sp)
    addi $sp, $sp, 12

    #fffbffd start checking there

    #if either t1 or t3 is _ deal with it here (code causes issues)
    bne $t1, $s6, check2 
    addi $t1, $a0, 0
check2:
    bne $t3, $s6, solve
    addi $t3, $a0, 0

solve:
    beq $t2, $s0, _add
    beq $t2, $s1, _sub
    beq $t2, $s2, _mult
    beq $t2, $s3, _div

_add:
    add $t6, $t1, $t3
    sw $t6, 0($sp)
    j loop_input

_sub:
    sub $t6, $t1, $t3
    sw $t6, 0($sp)
    j loop_input

_mult:
    mult $t1, $t3
    mflo $t6
    sw $t6, 0($sp)
    j loop_input

_div:
    div $t1, $t3
    mflo $t6
    sw $t6, 0($sp)
    j loop_input



end:
    addi $v0, $0, 13                       # clears the screen
    syscall
    
    lw $a0, 0($sp)
    addi $v0, $0, 1
    syscall

    addi $s4, $0, 0
    j loop_input

close_application:
    addi $sp, $sp, 4

    addi $v0, $0, 10
    syscall