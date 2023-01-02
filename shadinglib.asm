read_vertice:
	mv t1, a0
	mv t3, a0
	addi t3, t3, 3 #end of loop
	li t5, 255 #for comparing with max pixel width
lop:
	li a7, 4 #code print string
	la a0, input_vertice
	ecall
	li a7, 5 #code read int
	la a0, buf
	ecall
	#check if proper pixel value and store it if ok
	bgt a0, t5, error
	bltz a0, error
	sb  a0, (t1)
	addi t1, t1, 1
	blt t1, t3, lop
	
	mv a0, t1
ret

get_Ia: #args: ft10 as I1 and ft11 as I2. Returns at fa0.
	#t6			#Ys - Y2 = Ys
	li	a1, 240		#Y1 - Y2 = 240
	fcvt.s.w fa1, a1	#(a1 = 240)
	fcvt.s.w fa2, t6
	fdiv.s  fa2, fa2, fa1	#... = res1 
	fmul.s  fa2, fa2, ft10	#res1 * I1
	#
	sub	a3, a1, t6	#Y1 - Ys
	fcvt.s.w fa3, a3
	fdiv.s 	fa3, fa3, fa1	#... = res2
	fmul.s 	fa3, fa3, ft11	#res2 * I2
	#
	fadd.s 	fa2, fa2, fa3
	fmv.s	fa0, fa2
ret

#Y1 = 240
#Y2 = 0
#Y3 = 0
#Y1 - Y2 = 240
#Y1 - Y3 = 400 or 240

get_Ib: #args: ft10 as I1 and ft11 as I2. Returns at fa0
	mv 	a2, t6 		#Ys - Y3
	li	a1, 240		#Y1 - Y3
	fcvt.s.w fa1, a1
	fcvt.s.w fa2, a2
	fdiv.s  fa2, fa2, fa1	#... = res1 
	fmul.s  fa2, fa2, ft10	#res1 * I1
	#
	sub	a3, a1, t6	#Y1 - Ys
	fcvt.s.w fa3, a3
	fdiv.s 	fa3, fa3, fa1	#... = res2
	fmul.s 	fa3, fa3, ft11	#res2 * I3
	#
	fadd.s 	fa2, fa2, fa3
	fmv.s	fa0, fa2
ret

print_shaded_color:
	sub 	a2, s9, s8 	#Xb - Xp
	sub	a1, s9, s10	#Xb - Xa
	fcvt.s.w fa1, a1
	fcvt.s.w fa2, a2
	fdiv.s  fa2, fa2, fa1	#... = res1 
	fmul.s  fa2, fa2, fa6	#res1 * Ia
	#
	sub	a3, s8, s10	#Xp - Xa
	fcvt.s.w fa3, a3
	fdiv.s 	fa3, fa3, fa1	#... = res2
	fmul.s 	fa3, fa3, fa7	#res2 * Ib
	#
	fadd.s 	fa2, fa2, fa3
	fcvt.w.s a2, fa2
	sb	a2, (a0)
	addi	a0, a0, 1
ret