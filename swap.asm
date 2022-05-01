.data
v: .word 1,3,5,8
n: 4
k: 2

.text
global main

main: 
#code 
#code
jal qselect
#exit


swap:

#$a0 = i
#$a1 = j
la $t1, v           # t1 = address of v
sll $t0, $a0, 2     # t0 = a0 *4
add $t3, $t0, $t1      # t3 = address of v[i]
lw $t2, 0($t1)          # t2 = v[i]

sll $t0, $a1, 2     # t0 = a1 *4
add $t0, $t0, $t1      # t4 = address of v[j]
lw $t4, 0($t0)
sw $t4, 0($t3)          #    v[i] = v[j];

sw $t2, 0($t0)

jr $ra

swap:                   # swap entry point
    # a0 = i
    # a1  = j

    # temp = v[i]
    la $t0, v           # load address of v
    sll $t1, $a0, 2     # t1 = 4*i
    add $t2, $t0, $t1   # t2 = address of v[i]
    lw $t1, 0($t2)      # t1 = v[i]

    # v[i] = v[j]
    sll $t3, $a1, 2     # t3 = 4*j
    add $t3, $t3, $t0   # t3 = address of v[j]
    lw $t4, 0($t3)      # t4 = v[j]
    sw $t4, 0($t2)      # save v[j] to address of v[i]

    # v[j] = temp
    sw $t1, 0($t3)      # save v[i] to address of v[j]

    jr $ra               # return to caller