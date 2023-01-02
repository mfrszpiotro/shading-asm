set_header:
	mv t1, a0
	addi	t1, t1, 36
	li	t2, 0x0003
	sh	t2, (t1)
	addi 	t1, t1, -2	
	li	t2, 0x8400
	sh	t2, (t1)
	addi 	t1, t1, -6	
	li	t2, 0x0018
	sh	t2, (t1)
	addi 	t1, t1, -2
	li	t2, 0x0001
	sh	t2, (t1)
	addi 	t1, t1, -4
	li	t2, 0x00F0
	sh	t2, (t1)
	addi 	t1, t1, -4	
	li	t2, 0x0140
	sh	t2, (t1)
	addi 	t1, t1, -4	
	li	t2, 0x0028
	sh	t2, (t1)
	addi 	t1, t1, -4
	li	t2, 0x0036
	sh	t2, (t1)
	addi 	t1, t1, -6
	li	t2, 0x0003
	sh	t2, (t1)
	addi 	t1, t1, -2
	li	t2, 0x8436
	sh	t2, (t1)
	addi 	t1, t1, -2
	li	t2, 0x4D42
	sh	t2, (t1)
	
	mv a0, t1
ret