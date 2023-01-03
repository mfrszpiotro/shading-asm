        	.data
input_start: 	.string "\nIn the following steps you need to put the RGB colors for three vertices of the triangle. This message will be followed by three consecutive messages.\n"
input_vertice: 	.string "->Please enter the pixel value: "
err:		.string "\nWrong argument!   "
buf:		.space	2
v1:		.space	4
v2:		.space	4
v3:		.space	4
bmp: 		.space 	220854		# size till the triangle end scanline
triangle_end:	.space 	  9600		# empty space after the triangle drawing
fout:   	.asciz 	"shading.bmp"   # filename for output
        	.text

#################################################################      	
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
	
#################################################################
  # Open (for writing) a file that does not exist
	li	a7, 1024     	# system call for open file
  	la  	a0, fout     	# output file name
  	li  	a1, 1        	# Open for writing (flags are 0: read, 1: write)
  	ecall                	# open a file (file descriptor returned in a0)
  	mv  	s11, a0      	# save the file descriptor
 
#Execution of the function:
#################################################################
	li	s1, 97		# Y3 - height point where the rhs of the triangle should "break"
	la 	s0, bmp		#header offset saved
	mv	a0, s0 		#arg 1
	addi	s0, s0, 54	#R2  G2  B2 	R3  G3  B3	R1  G1  B1
	jal	shade		#fs4 fs3 fs2	fs7 fs6 fs5	fs10 fs9 fs8

shade:
	jal 	set_header	#a0 i/o arg - memory address of the file
#################################################################
#Phong shading method variables:
	li	t1, 489 	#Xa
	li	t2, 492		#Xb
	mv	t3, t1 		#Xp
	sub	a6, t2, t1	#length of consecutive scanline
	li	t6, 20 	#Ys - for every scan line, the Ys (t6) is incremented
	
print_lines_lop:
	mv	t3, t1
	mv	a0, s0
	add	a0, a0, t1
	li	t0, 960
	mul	t0, t0, t6 	#new line distance from header
	add	a0, a0, t0	#a0 is now pointing to new line
	la	t0, triangle_end
	bge	a0, t0, write_contents
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
	
	addi	t3, t3, 1
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

write_contents:
  ###############################################################
  # Write contents to opened file
  	li	a7, 64       # system call for write to file
  	mv	a0, s11       # file descriptor
  	la	a1, bmp		# address of buffer from which to write
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

		.include "setbmpheader.asm"
		.include "shadinglib.asm"
