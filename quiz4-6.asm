.data
#n: .word 4
#v: .word 3, 10, 8, 2
#k: .word 2
n: .word 21
v: .word 10, 3, 7, 21, 20, 15, 14, 24, 9, 5, 1, 22, 16, 13, 12, 18, 4, 6, 19, 17, 2
k: .word 12

.text
.globl main

main:
la $t0, n
la $t1, k

add $a0, $zero, $zero			# variable: f : (0 .. n-1) 0
lw $a1, 0($t0) # a1 = n			# variable: l : (0 .. n-1) n-1
addi $a1, $a1, -1 #a1 = n-1
lw $a2, 0($t1) #a2 = k			# variable: k : (0 .. n-1) 1st, 2nd,... minumum number

add $t9, $zero, $zero 			# counter t9 = 0

jal qselect

jr $ra

swap:                           # swap entry point
    sll $t1, $a0, 2             # t1 = i*4
    sll $t2, $a1, 2             # t2 = j*4
    la $t3, v                   # t3 = adress of v
    add $t1, $t3, $t1           # t1 = v + i*4
    add $t2, $t3, $t2           # t2 = v + j*4
    lw $t3, 0($t1)              # t3 = v[i]
    lw $t4, 0($t2)              # t4 = v[j]
    sw $t3, 0($t2)              # v[j] = t3
    sw $t4, 0($t1)              # v[i] = t4
    jr      $ra                 # return to caller


partition:
    addi $sp, $sp, -20 		    # adjust stack for 5 items
    sw $ra, 16($sp)             # save return address
    sw $a0, 12($sp)
    sw $a1, 8($sp)
    
    la $t1, v                   # t1 = v
    sll $t2, $a1, 2             # t2 = l*4
    add $t2, $t1, $t2           # t2 = v + l*4
    lw $t8, 0($t2)              # t8 = v[l]
    
    add $t3, $a0, $zero         # t3 = f = i
    
    add $t4, $a0, $zero         # t4 = f =j
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
                            
    add $a0, $t3, $zero         # a0 = t3
    lw $a1, 8($sp)		        # a1 = l
    jal swap
    
    lw $ra, 16($sp)             # restore
    lw $a0, 12($sp)
    lw $a1, 8($sp)
    lw $t3, 0($sp)
    addi $sp, $sp, 20
        
    add $v0, $t3, $zero
    
    jr      $ra


qselect:
        #a2 = k
        #a0 = f
        #a1 = l
        
        addi $t9, $t9, 1

        addi $sp, $sp, -20                    # adjust stack for 5 items
        sw $ra, 16($sp)
        sw $a0, 12($sp)
        sw $a1, 8($sp)
        sw $a2, 4($sp)

        slt $t0, $a0, $a1                     # if  f not < l
        beq $t0, $zero,  end_if1              # branch to end_if1

        #no adjusting the parameters needed
        jal partition
        add $t0, $zero, $v0                   # t0 = v0 = p

        sub, $t1, $t0, $a0                    # t1 = t0 - a0
        bne $t1, $a2, end_if2                 # if t1 != a2 branch to end_if2

            la $t4, v                         # t4 = v
            sll $t5, $t0, 2                   # t5 = p*4
            add $t5, $t4, $t5                 # t5 = v + p*4
            lw $v0, 0($t5)                    # v0 = v[p]

            j end_qselect
        end_if2:

        slt $t3, $a2, $t1                    # if a2 not < t1
        beq $t3, $zero, end_if3              # branch to end_if3


            #save to stack a0, a1, a2, ra, t0(p)
#            sw $ra, 16($sp)
#            sw $a0, 12($sp)
#            sw $a1, 8($sp)
#            sw $a2, 4($sp)
            sw $t0, 0($sp)

            #a0 and a2 stays the same
            addi $a1, $t0, -1           # a1 = p-1 = t0 - 1
            jal qselect

            j end_qselect

        end_if3:

            # restore ra, a1, t0
            lw $ra, 16($sp)
            lw $a1, 8($sp)
            lw $t0, 0($sp)


            add $a2, $a2, $a0                   # a2 = a2 + a0
            sub $a2, $a2, $t0                   # a2 = a2 - t0
            addi $a2, $a2, -1                   # a2 = a2 - 1
            addi $a0, $t0, 1                   # a0 = t0 - 1

            jal qselect
	    j end_qselect

        end_if1:

            #restore ra, a0, a1, a2
            lw $ra, 16($sp)
            lw $a0, 12($sp)
            lw $a1, 8($sp)
            lw $a2, 4($sp)

            # v0 = v[f]
            la $t4, v                         # t4 = v
            sll $t5, $a0, 2                   # t5 = f*4
            add $t5, $t4, $t5                 # t5 = v + f*4
            lw $v0, 0($t5)                    # v0 = v[f]

      end_qselect:
      	    #restore ra, a0, a1, a2
            lw $ra, 16($sp)
            lw $a0, 12($sp)
            lw $a1, 8($sp)
            lw $a2, 4($sp)
	
            addi $sp, $sp, 20
            jr      $ra
