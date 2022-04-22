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

partition:
    # a0 = f
    # a1 = l

    #int pivot = v[l]
    #int i = f

    #int j = f
for: 
    #if !(j<l) go to end_for

    #if !(v[j] < pivot) goto for
    #swap(i++,j)

    #j++
    #goto for
end_for:

    #swap(i, l)
    
    #return (i)
    jr $ra


qselect:
    # a0 = f
    # a1 = l
    # a2 = k

if_1:
    # int p = partition(f, l)

if_2:
    #if (p - f == k)
        #return v[p]
else_if_2:
    #if (p - f > k)
        #return qselect(f, p - 1, k)
else_2:
    #return qselect(p + 1, l, k - p + f - 1);

end_if_1:
    #return v[f];
