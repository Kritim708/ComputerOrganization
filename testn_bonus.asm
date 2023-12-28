.data
          barry: .word 2
          array: .word 3 4 5 #This comment must be ignored
.text
.globl main
main:
  #This comment must be ignored
  addi $t0, $0, 100
  addi $t1, $0, 0
  add $a0, $0, $0
  addi $s0, $0, 4

loop: 
    beq $t1, $t0, endloop
    addi $t1, $t1, 1
    mult $t1, $s0
    mflo $s2
    sw $t1, 0($s2)
    jal f
    j loop
endloop:
    j endloop

f:
  lw $t2, 0($s2)
  add $a0, $a0, $t2
  jr $ra