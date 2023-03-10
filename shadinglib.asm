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

shade:
	mv	s10, ra
	jal 	set_header	#a0 i/o arg - memory address of the file
#################################################################
#Phong shading method variables:
	li	t1, 492 	#Xa
	li	t2, 492		#Xb
	sub	a6, t2, t1	#length of consecutive scanline
	li	t6, 20 		#Ys - for every scan line, the Ys (t6) is incremented
	add	a3, t2,	t2	#arg for phong eq. fix
print_lines_lop:
	li	t3, 98
	mv	a4, t2
	bge	t6, t3, skip_fix
	jal	fix_phong	#arg inp a3, arg out a3
	mv	a4, a3
skip_fix:
	mv	t3, t1		#Xp
	mv	a0, s0
	add	a0, a0, t1
	li	t0, 960
	mul	t0, t0, t6 	#new line distance from header
	add	a0, a0, t0	#a0 is now pointing to new line
	la	t0, triangle_end
	bge	a0, t0, finish
	mv	a7, a0
	
print_line_lop:
	#argument fa0
	fmv.s	ft10, fs8
	fmv.s	ft11, fs2
	jal 	get_Ia
	fmv.s	fa6, fa0
	fmv.s	ft10, fs8
	fmv.s	ft11, fs5
	jal	get_Ib
	fmv.s	fa7, fa0
	jal	print_shaded_color
	
	#argument fa0
	fmv.s	ft10, fs9
	fmv.s	ft11, fs3
	jal 	get_Ia
	fmv.s	fa6, fa0
	fmv.s	ft10, fs9
	fmv.s	ft11, fs6
	jal	get_Ib
	fmv.s	fa7, fa0
	jal	print_shaded_color
	
	#argument fa0
	fmv.s	ft10, fs10
	fmv.s	ft11, fs4
	jal 	get_Ia
	fmv.s	fa6, fa0
	fmv.s	ft10, fs10
	fmv.s	ft11, fs7
	jal	get_Ib
	fmv.s	fa7, fa0 
	jal	print_shaded_color
	
	addi	t3, t3, 3
	sub	a5, a0, a7
	ble 	a5, a6, print_line_lop
	
###################################################################
#triangle lhs calculations
	li	t5, 3
	addi 	t4, t4, 1
	ble	t4, t5, lhs_pass
	li	t4, 0
	sub	t1, t1, t5	#Xa decrement after every 3 iterations
lhs_pass:

###################################################################
#triangle rhs calculations
	ble	t6, s1, rhs_pass#a coefficient of rhs is switched
	li	t5, -3
rhs_pass:
	add	t2, t2, t5	#Xb
	
###################################################################

	sub	a6, t2, t1	#length of consecutive scanline
	addi 	t6, t6, 1 	#increment Ys
	j	print_lines_lop

finish:
	addi	ra, ra, -516	#return to shade execution address
	ret


get_Ia: #args: ft10 as I1 and ft11 as I2. Returns at fa0.
	li  	t5, 20			#Y2
	li	a1, 210			#Y1 - Y2
	sub 	a2, t6, t5		#Ys - Y2
	fcvt.s.w fa1, a1		
	fcvt.s.w fa2, a2
	fdiv.s  fa2, fa2, fa1	#... = res1 
	fmul.s  fa2, fa2, ft10	#res1 * I1
	#
	li 	t5, 230
	sub	t5, t5, t6	#Y1 - Ys
	fcvt.s.w fa3, t5
	fdiv.s 	fa3, fa3, fa1	#... = res2
	fmul.s 	fa3, fa3, ft11	#res2 * I2
	#
	fadd.s 	fa2, fa2, fa3
	fmv.s	fa0, fa2
ret

#Y1 = 230
#Y2 = 20 
#Y3 = 97 = s1
#Y1 - Y2 = 210
#Y1 - Y3 = 133

get_Ib: #args: ft10 as I1 and ft11 as I2. Returns at fa0
	li 	t5, 230		#Y1
	sub 	a2, t6, s1	#Ys - Y3
	li	a1, 133		#Y1 - Y3
	fcvt.s.w fa1, a1
	fcvt.s.w fa2, a2
	fdiv.s  fa2, fa2, fa1	#... = res1 
	fmul.s  fa2, fa2, ft10	#res1 * I1
	#
	sub	t5, t5, t6	#Y1 - Ys
	fcvt.s.w fa3, t5
	fdiv.s 	fa3, fa3, fa1	#... = res2
	fmul.s 	fa3, fa3, ft11	#res2 * I3
	#
	fadd.s 	fa2, fa2, fa3
	fmv.s	fa0, fa2
ret

print_shaded_color: #arg a4 as Xb which should be change dynamically with respect to Ys position		#previous Xb	
	sub 	a2, a4, t3 	#Xb - Xp
	sub	a1, a4, t1	#Xb - Xa
	fcvt.s.w fa1, a1
	fcvt.s.w fa2, a2
	fdiv.s  fa2, fa2, fa1	#... = res1 
	fmul.s  fa2, fa2, fa6	#res1 * Ia
	#
	sub	t5, t3, t1	#Xp - Xa
	fcvt.s.w fa3, t5
	fdiv.s 	fa3, fa3, fa1	#... = res2
	fmul.s 	fa3, fa3, fa7	#res2 * Ib
	#
	fadd.s 	fa2, fa2, fa3
	fcvt.w.s a2, fa2
	sb	a2, (a0)
	addi	a0, a0, 1
ret

fix_phong:
	# a4 is Xb from previous iterations (starts as Xb+492)
	# the change depends on Ys t6 - 20 counter
	addi 	a1, t6, -20
	li 	t5, 27 
	ble	a1, t5, zero_phase
	li 	t5, 44
	ble	a1, t5, first_phase
	li 	t5, 60
	ble	a1, t5, second_phase
	li 	t5, 70
	ble	a1, t5, third_phase
	addi	a3, a3, -2
third_phase:
	addi	a3, a3, 2
second_phase:
	addi	a3, a3, 3
first_phase:
	addi	a3, a3, -6
zero_phase:
	addi	a3, a3, -1

ret #returning a4
