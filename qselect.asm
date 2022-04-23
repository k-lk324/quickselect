.data
v: .word
n: .word
k: .word

.text
#main

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

partition:              #partition entry point
    # a0 = f
    # a1 = l

    #save parameters and ra to stack 

    #int pivot = v[l]
    #int i = f

    #int j = f
for_partition: 
    #if !(j<l) go to end_for_partition

    #if !(v[j] < pivot) goto for_partition
    #swap(i++,j)

    #j++
    #goto for_partition
end_for_partition:

    #swap(i, l)
    
    #return (i)
    jr $ra


qselect:
    # a0 = f
    # a1 = l
    # a2 = k

if_1_qselect:
    # int p = partition(f, l)

if_2_qselect:
    #if (p - f == k)
        #return v[p]
else_if_2_qselect:
    #if (p - f > k)
        #return qselect(f, p - 1, k)
else_2_qselect:
    #return qselect(p + 1, l, k - p + f - 1);

end_if_1_qselect:
    #return v[f];
