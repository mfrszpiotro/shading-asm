
        	.data
input_start: 	.string "\nIn the following steps you need to put the RGB colors for three vertices of the triangle. This message will be followed by three consecutive messages.\n"
input_vertice: 	.string "->Please enter the pixel value: "
err:		.string "\nWrong argument!   "
buf:		.space	2
v1:		.space	4
v2:		.space	4
v3:		.space	4
bmp: 		.space 	230454		# the bmp file size
fout:   	.asciz 	"shading.bmp"   # filename for output
        	.text
        	
#input (R1,G1,B1), (R2,G2,B2), (R3,G3,B3)      	
	li a7, 4
	la a0, input_start
	ecall
	
	la a0, v1
	jal read_vertice
	la a0, v2
	jal read_vertice
	la a0, v3
	jal read_vertice
	
#################################################################
  # Open (for writing) a file that does not exist
	li	a7, 1024     # system call for open file
  	la  	a0, fout     # output file name
  	li  	a1, 1        # Open for writing (flags are 0: read, 1: write)
  	ecall                # open a file (file descriptor returned in a0)
  	mv  	s11, a0       # save the file descriptor
  	
	la	a0, bmp
	jal 	set_header
	
	la	t2, v1
	lbu	a2, (t2)
	fcvt.s.w fs2, a2 	#store left I_a_Blue as float
	
	addi	t2, t2, 1
	lbu	a2, (t2)
	fcvt.s.w fs3, a2	#store left I_a_Green as float
	
	addi	t2, t2, 1
	lbu	a2, (t2)
	fcvt.s.w fs4, a2	#store left I_a_Red as float
	
	la	t2, v2
	lbu	a2, (t2)
	fcvt.s.w fs5, a2	#store right I_b_Blue as float
	
	addi	t2, t2, 1
	lbu	a2, (t2)
	fcvt.s.w fs6, a2	#store right I_b_Green as float
	
	addi	t2, t2, 1
	lbu	a2, (t2)
	fcvt.s.w fs7, a2	#store right I_b_Red as float
	
	la	t2, v3
	lbu	a2, (t2)
	fcvt.s.w fs8, a2	#store top I_b_Blue as float
	
	addi	t2, t2, 1
	lbu	a2, (t2)
	fcvt.s.w fs9, a2	#store top I_b_Green as float
	
	addi	t2, t2, 1
	lbu	a2, (t2)
	fcvt.s.w fs10, a2	#store top I_b_Red as float
	
##########################################################
#REQUIRED FOR CALULATIONS
##########################################################
	li	s10, 0 	#Xa
	li	s9, 719	#Xb
	li	s8, 0	#Xp
	mv	a6, s9	#length of consecutive scanline - to be decremented
	li	t6, 0 	#Ys - for every scan line, the Ys (t6) is incremented
	#R2  G2  B2 	R3  G3  B3	R1  G1  B1
	#fs4 fs3 fs2	fs7 fs6 fs5	fs10 fs9 fs8
	
print_lines_lop:
	la	a0, bmp
	addi	a0, a0, 54
	li	t0, 960
	mul	t0, t0, t6 	#new line distance from header
	add	a0, a0, t0	#a0 is now pointing to new line
	la	t0, fout
	bge	a0, t0, write_header
	mv	a7, a0
	
print_line_lop:
	#argument fa0
	fmv.s	ft10, fs8 #
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
	
	sub	a5, a0, a7
	ble 	a5, a6, print_line_lop
	
	addi	a6, a6, -3	#decrement distance for the last pixel of the next scanline
	addi 	t6, t6, 1 	#increment Ys
	j	print_lines_lop

write_header:
  ###############################################################
  # Write header to file just opened
  	li	a7, 64       # system call for write to file
  	mv	a0, s11       # file descriptor
  	la	t1, bmp
  	mv	a1, t1   # address of buffer from which to write
  	li  	a2, 230454       # hardcoded buffer length
  	ecall             # write to file
  ###############################################################
  # Close the file
  	li	a7, 57       # system call for close file
  	mv   	a0, s11       # file descriptor to close
  	ecall             # close file
#################################################################
  
exit:
	li a7, 10
	ecall
	
error:
 	li  	a7, 4     # service 4 is print string
    	la 	a0, err   # load desired value into argument register a0, using pseudo-op
   	ecall


#################################################################
# FUNCTIONS #
#################################################################

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
