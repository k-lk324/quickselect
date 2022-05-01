.data
n: .word 6
v: .word 3, 10, 8, 2, 13, 1
k: .word 0
#n: .word 21
#v: .word 10, 3, 7, 21, 20, 15, 14, 24, 9, 5, 1, 22, 16, 13, 12, 18, 4, 6, 19, 17, 2
#k: .word 12

.text
.globl main

main:
la $t0, n
la $t1, k

add $a0, $zero, $zero			# variable: f : (0 .. n-1) 0
lw $a1, 0($t0) # a1 = n			# variable: l : (0 .. n-1) n-1
addi $a1, $a1, -1 #a1 = n-1
lw $a2, 0($t1) #a2 = k			# variable: k : (0 .. n-1) 1st, 2nd,... minumum number

jal qselect

move $a0, $v0
addi $v0, $zero, 1
syscall

addi $v0, $zero, 10
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

#partition:              #partition entry point
    # a0 = f
    # a1 = l

    #save parameters and ra to stack
    #sp += 

    #int pivot = v[l]
    #int i = f

    #int j = f
#for_partition: 
    #if !(j<l) go to end_for_partition

    #if !(v[j] < pivot) goto for_partition
    #swap(i++,j)

    #j++
    #goto for_partition
#end_for_partition:

    #swap(i, l)
    
    #return (i)
 #   jr $ra



partition:                      # partition entry point
    addi $sp, $sp, -20 		    # adjust stack for 5 items
    sw $ra, 16($sp)             # save return address
    sw $a0, 12($sp)
    sw $a1, 8($sp)
    
    la $t1, v                   # t1 = v
    sll $t2, $a1, 2             # t2 = l*4
    add $t2, $t1, $t2           # t2 = v + l*4
    lw $t8, 0($t2)              # t8 = v[l]
    
    move $t3, $a0               # t3 = f = i
    
    move $t4, $a0               # t4 = f = j
    start_for:
        slt $t0, $t4, $a1           # if not (t4 < a1)
        beq $t0, $zero, end_for     # branch to end_for
        
        sll $t5, $t4, 2             # t5= t4 * 4
        la $t1, v		            # t1 = address v
        add $t5, $t1, $t5           # t5 = v + t5
    
        lw $t7 0($t5)               # t7 = v[t4]
        
        slt $t0, $t7, $t8           # if not (t7 < t8)
        beq $t0, $zero, end_if      # branch to end_if
        
    
            sw $t4, 4($sp)              #save t3 and t4
            sw $t3, 0($sp)
        
        
            add $a0, $t3, $zero         # a0 = t3
            add $a1, $t4, $zero         # a1 = t4
            jal swap
    
            lw $ra, 16($sp)             # restore
            lw $a0, 12($sp)
            lw $a1, 8($sp)
            lw $t4, 4($sp)
            lw $t3, 0($sp)
            addi $t3, $t3, 1            # t3 = t3 + 1
    
        end_if:
    
    
        addi $t4, $t4, 1            # t4++
        j start_for
    end_for:
      
    sw $t4, 4($sp)
    sw $t3, 0($sp)   
                            
    move $a0, $t3               # a0 = t3
    lw $a1, 8($sp)		        # a1 = l
    jal swap
    
    lw $ra, 16($sp)             # restore ra, parameters and t3
    lw $a0, 12($sp)
    lw $a1, 8($sp)
    lw $t3, 0($sp)
    addi $sp, $sp, 20
        
    move $v0, $t3
    
    jr      $ra

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
    la $t0, v                          # t0 = address of v
    sll $t1, $a0, 2                     # t1 = 4*a0(f)
    add $t0, $t0, $t1                   # t0 = address of v[f]
    lw $v0, 0($t0)                      # v0 = v[f]

    j end_qselect

end_qselect:
    addi $sp, $sp, 4

    jr $ra                              # return
