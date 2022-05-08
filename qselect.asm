.data

n:    .word    21
v:    .word    10, 3, 7, 21, 20, 15, 14, 24, 9, 5, 1, 22, 16, 13, 12, 18, 4, 6, 19, 17, 2
k:    .word    12

.text

main:
    li    $a0, 0            #$a0 init

    la    $t0, n            #$a1 init
    lw    $a1, 0($t0)
    li    $t0, 1
    sub    $a1, $a1, $t0

    la    $t0, k            #$a2 init
    lw    $a2, 0($t0)

    jal    qselect

    move    $v1, $v0        #$v1 output of qselect

    li    $v0, 10
    syscall


swap:                   # swap entry point
    # a0 = i
    # a1  = j

    # temp = v[i]
    la $t0, v           # load address of v
    sll $t1, $a0, 2       # t1 = 4*i
    add $t2, $t0, $t1   # t2 = address of v[i]
    lw $t1, 0($t2)      # t1 = v[i]

    # v[i] = v[j]
    sll $t3, $a1, 2     # t3 = 4*j
    add $t3, $t3, $t0   # t3 = address of v[j]
    lw $t4, 0($t3)      # t4 = v[j]
    sw $t4, 0($t2)      # save v[j] to address of v[i]

    # v[j] = temp
    sw $t1, 0($t3)      #save v[i] to address of v[j]

    jr $ra

partition:                      #partition entry point
    # a0 = f
    # a1 = l

    #save parameters and ra to stack
    addi $sp, $sp, -24 		    # adjust stack for 3 items
    sw $ra, 16($sp)             # save return address
    sw $a0, 12($sp)             # f --> sp + 4
    sw $a1, 8($sp)              # l --> sp

    #int pivot = v[l]
    la $t0, v                   # t0 = address of v
    sll $t1, $a1, 2             # t1 = l*4
    add $t1, $t1, $t0           # t1 = address of v[l]
    lw $t2, 0($t1)              # t2 = v[l]

    #int i = f
    move $t0, $a0               # t0 = f

    #int j = f
    move $t1, $a0               # t1 = f

for_partition: 
    #if !(j<l) goto end_for_partition
    slt $t3, $t1, $t0           # if !(t1 < t0): t3 = 0
    beq $t3, $zero, end_for_partition   # if t3 ==0 branch to end_for_partition

    #if !(v[j] < pivot) goto for_partition
    la $t3, v                   # t3 = address of v
    sll $t4, $t1, 2             # t4 = 4*j
    add $t4, $t3, $t4           # t4 = address of v[j]
    lw $t4, 0($t4)              # t4 = v[j]

    slt $t3, $t4, $t2           # if !(t4 < t2): t3 = 0
    beq $t3, $zero, end_if      # if t3==0: branch to end_if

    #swap(i++,j)
    move $a0, $t0               # a0 = i
    move $a1, $t1               # a1 = j

    #store i and j and pivot
    sw $t0, 4($sp)              # t0 --> sp +4
    sw $t1, 0($sp)              # t1 --> sp +0
    sw $t2, 20($sp)             # t2 --> sp +20

    jal swap

    #restore
    sw $t2, 20($sp)             # t2 --> sp +20
    lw $t1, 0($sp)
    lw $t0, 4($sp)
    lw $ra, 16($sp)

end_if:

    #j++
    addi $t1, $t1, 1

    #goto for_partition
    j for_partition

end_for_partition:

    #swap(i, l)
    move $v0, $t0                # result is (i)
    move $a0, $t0                # a0 = i
    lw $a1, 12($sp)              # a1 = l

    lw $ra, 16($sp)              # restore return address
    addi $sp, $sp, 20            # restore stack pointer
    
   jr $ra                        # return to caller



qselect:
    # a0 = f
    # a1 = l
    # a2 = k

    #adjust stack for 1 item
    addi $sp, $sp, -4
    sw $ra, 0($sp)

if_1_qselect:
    #if !(f < 1+l) goto end_if_qselect
    addi $t0, $a1, 1                    # t0 = l + 1
    slt $t0, $a0, $t0                   # if !(f < l + 1): t0 = 0
    beq $t0, $zero, end_if_1_qselect    # if t0 == 0: branch to end_if_1_qselect

    # int p = partition(f, l)
    # a0(f) and a1(l) remain the same
    jal partition                       # v0 = p
    lw $ra, 0($sp)                      # restore ra

if_2_qselect:
    #if !(p == k) goto else_if_2_qselect
    bne $v0, $a2, else_if_2_qselect

    #return v[k]
    la $t0, v                           # t0 = address of v
    sll $t1, $a2, 2                     # t1 = 4*k
    add $t1, $t0, $t1                   # t1 = address of v[k]
    lw $v0, 0($t1)                      # t0 = v[k]

    j end_qselect

else_if_2_qselect:
    #if !(k < p) goto else_2_qselect
    slt $t0, $a2, $v0                   # if !(k < p): t0 = 0
    beq $t0, $zero, else_2_qselect      # if t0 == 0: branch to else_2_qselect

    #l = p - 1
    addi $a1, $v0, -1                   # a1(l) = v0(p) - 1 

    #return qselect(f, l, k)
    jal qselect
    lw $ra, 0($sp)                      # restore ra

    j end_qselect


else_2_qselect:
    #f = p + 1
    addi $a0, $v0, 1                    # a0(f) = v0(p) + 1

    #return qselect(f, l, k)
    jal qselect
    lw $ra, 0($sp)                      # restore ra

    j end_qselect

end_if_1_qselect:
    #return v[f]
    la $t0, v                           # t0 = address of v
    sll $t1, $a0, 2                     # t1 = 4*a0(f)
    add $t0, $t0, $t1                   # t0 = address of v[f]
    lw $v0, 0($t0)                      # v0 = v[f]

    j end_qselect

end_qselect:
    addi $sp, $sp, 4                    # restore stack pointer

    jr $ra                              # return to caller
