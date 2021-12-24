.text
.global  set_batt_from_ports
     
##Madelyn Ogorek's hand-coded assembly battery functions
##ogore014
## ENTRY POINT FOR REQUIRED FUNCTION
set_batt_from_ports:
        ## assembly instructions here
	## rdi holds the pointer to the batt_t struct
	movw	BATT_VOLTAGE_PORT(%rip), %dx	#copy global var to reg dx (16-bit word)
	cmpw	$0, %dx		#if BATT_VOLTAGE_PORT--> %dx is less than 0 condition flag is 1, 0 if greater than
	jl	.VOLTERROR	#if BATT_VOLTAGE_PORT less than 0 (indicates error), jumps
	movw	%dx, 0(%rdi)	#the same as batt->volts = BATT_VOLTAGE_PORT;
	cmpw	$3800, %dx	#if BATT_VOLTAGE_PORT--> %dx is less than 3800 condition flag is 1, 0 if greater than
	jg	.VOLTHIGH	#preventing a percent of greater than 100
	jmp	.AFTER1

.VOLTHIGH:
	movb	$100, 2(%rdi)	#moving 100 into batt_percent
	jmp	.PASTPERCENT	#so that we don't reset percent to be invalid number

.AFTER1:
	cmpw	$3000, %dx	#if BATT_VOLTAGE_PORT--> %dx is less than or equal to 3000 condition flag is 1, 0 if greater than
	jle	.VOLTLOW	#preventing a negative percent
	jmp	.AFTER2		#going back to main flow of program if volts aren't too low

.VOLTLOW:
	movb	$0, 2(%rdi)	#moving 0 into batt_percent
	jmp	.PASTPERCENT	#so that we don't reset percent to be invalid number

.AFTER2:
	movw	$3000, %cx	#moving 3000 into 16 bit register to prepare for subtraction
	subw	%cx, %dx	#subtracting cx from dx (3000 from BATT_VOLT_PORT) save result in dx
	sarw	$3, %dx		#uses bit shifting to divide dx by 8 (2^3)
	movb	%dl, 2(%rdi)	#moving result of computation into batt_percent

##can jump to if percent was out of bounds
.PASTPERCENT:
	movb	BATT_STATUS_PORT(%rip), %cl	#copy global var to reg cl (8 bit byte)
	testb	$0x1, %cl	#the same as 0x1 & BATT_STATUS_PORT, if truthy (nonzero)
	jne	.MODEONE	#jump to set batt->mode = 1
	jmp	.AFTER3

.MODEONE:
	movb	$1, 3(%rdi)	#moving 1 into batt_mode

.AFTER3:
	je	.MODEZERO	#jump to set batt->mode = 0
	jmp	.AFTER4

.MODEZERO:
	movb	$0, 3(%rdi)	#moving 0 into batt_mode

.AFTER4:
	movl	$0, %eax	#moving 0 into return register (l for 32 bit)
	ret			#returning function (end of function


	

.VOLTERROR:
	movl	$1, %eax	#moving 1 into return register (l for 32 bit)
	ret			#returning function

       

### Data area associated with the next function
.section .data
	   array:                          # an array of 10 ints, array contains bit masks
		   .int 0b0111111              # array[0] = 
		   .int 0b0000011              # array[1] = 
		   .int 0b1101101              # array[2] = 
		   .int 0b1100111              # array[3] = 
		   .int 0b1010011              # array[4] = 
		   .int 0b1110110              # array[5] = 
		   .int 0b1111110              # array[6] = 
		   .int 0b0100011              # array[7] = 
		   .int 0b1111111              # array[8] = 
		   .int 0b1110111             # array[9] = 
	   const:
		   .int 17                 # special constant didn't end up using, not really sure what its for
	    

.text
.global  set_display_from_batt

## ENTRY POINT FOR REQUIRED FUNCTION
set_display_from_batt:  
        ## assembly instructions here
	
     	movq	%rdi, %rcx	#moving the batt_t struct into rdx to preserve as we may alter rdi
	shr	$24, %rdi	#shifting rdi right by 24 to access batt.mode bits (shr is for unsigned)
	movq	$0, %r10	#will eventually put the whole bitstring in here
	pushq	%r12		#pushing registers because we will use them
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	$0, %r12	#zeroing registers for safety
	movq	$0, %r13
	movq	$0, %r14
	movq	$0, %r15
	cmpq	$0, %rdi	#checking if batt.mode == 0
	je	.VOLTMODE	#jumping to do volt stuff
	jmp	.PERCENTMODE	#else jumping to do percent stuff

.VOLTMODE:
#check all these assignments
##we are using 16bit regs and commands so that we can look at just the batt.volts in the struct which is the first 2 bytes
	movq	$0, %rdi	#zeroing out rdi
	movq	%rcx, %rdi	#reseting the batt struct in rdi
	movq	%rcx, %rax	#putting the batt struct in rax so it can be used for division
	movw    $10,%r8w	#r8w now has 10 in it
	cqto                    # prep for division
	idivw   %r8w		#does ax / r8w (batt.volts / 10), puts it in ax and the remainder in dx
	movw	%dx, %r12w	#r12w now holds the rounding_digit
	cqto                    # prep for division
	idivw	%r8w		#does ax / r8w (batt.volts / 100), puts it in ax and the remainder in dx
	movw	%dx, %r13w	#r13w now holds the right_digit
	cqto                    # prep for division
	idivw	%r8w		#does ax / r8w (batt.volts / 1000), puts it in ax and the remainder in dx
	movw	%dx, %r14w	#r14w now holds the middle_digit
	movw	%ax, %r15w	#r15w now holds the left digit
	cmpw	$5, %r12w	#checking if the rounding_digit is greater than or equal to 5
	jge	.ROUNDUP
	jmp	.AFTER5		#rounding_digit is less than 5 so you don't need to round

.ROUNDUP:
	addq	$1, %r13	#rounding up the right_digit
	jmp	.AFTER5

.PERCENTMODE:

	##now we want to look at batt.percent which will require bit shifting rdi by 16
	##batt.percent is only 1 byte big so we want to use 1 byte regs to access just the percent bits --> use %dil
	movq	$0, %rdi	#zeroing out rdi
	movq	%rcx, %rdi	#reseting the batt struct in rdi
	shr	$16, %rdi	#shifting rdi right by 16 to access batt.percent bits (shr is for unsigned)
	movq	$0, %r8
	movw	$0b11111111, %r8w	#to be used as a mask
	andq	%r8, %rdi	#so that the only set bits in rdi will be the percent bits
	movw	%di, %ax	#ax holds the actual percent
	cmpw	$100, %ax	#if percent is 100 we wanna do something special
	je	.PERCENTMANUAL	#set digits manually
	movw    $10,%r8w	#r8b now has 10 in it
	cwtl
	cltq
	cqto                    # prep for division
	idivw	%r8w		#does ax / r8w (batt.percent / 10), puts it in ax and the remainder in dx
	movw	%dx, %r13w	#r13w now holds the right_digit
	movw	%ax, %r14w	#r14w now holds the middle_digit
	movw	$1, %r15w	#r15w now holds the left_digit (just in case we need it)
	movq	$0, %rdi	#zeroing out rdi
	movq	%rcx, %rdi	#reseting the batt struct in rdi
	jmp	.AFTER5
	#done with percent specific stuff, moving on to .AFTER5

.PERCENTMANUAL:
	movw	$0, %r13w	#r13w now holds the right_digit
	movw	$0, %r14w	#r14w now holds the middle_digit
	movw	$1, %r15w	#r15w now holds the left_digit (just in case we need it)
	movq	$0, %rdi	#zeroing out rdi
	movq	%rcx, %rdi	#reseting the batt struct in rdi
	movl	$0,%r10d	#zero r10d
	leaq	array(%rip),%r8    	# r8 points to array, rip used to enable relocation
	movl	(%r8,%r15,4),%r10d	# r10d = array[left_digit], note 32-bit movl and dest reg	
	shl	$14, %r10d		#shifting digit_holder left by 14 for correct alignment	
	jmp	.AFTER6

.AFTER5:
	shr	$24, %rdi	#shifting rdi right by 24 to access batt.mode bits (shr is for unsigned)
	cmpq	$0, %rdi	#checking if batt.mode == 0
	leaq	array(%rip),%r8    	# r8 points to array, rip used to enable relocation
	je	.SETLEFTDIGIT	#set digits if mode is volts
	jmp	.AFTER6		#else skip setting left digit

.SETLEFTDIGIT:
	#remember, r15 holds the left_digit
	#r10d is gonna act as our digit_holder and r8 points to our array
	movq	$0, %rdi	#zeroing out rdi
	movq	%rcx, %rdi	#reseting the batt struct in rdi
	movl	$0,%r10d	#zero r10d
	movl	(%r8,%r15,4),%r10d	# r10d = array[left_digit], note 32-bit movl and dest reg	
	shl	$14, %r10d		#shifting digit_holder left by 14 for correct alignment	

.AFTER6:
	movq	$0, %rdi	#zeroing out rdi
	movq	%rcx, %rdi	#reseting the batt struct in rdi
	shr	$24, %rdi	#shifting rdi right by 24 to access batt.mode bits (shr is for unsigned)
	cmpq	$0, %rdi	#checking if batt.mode == 0
	je	.SETMIDDLEDIGIT	#set middle digit if in volt mode
	movq	$0, %rdi	#zeroing out rdi
	movq	%rcx, %rdi	#reseting the batt struct in rdi
	shr	$16, %rdi	#shifting rdi right by 16 to access batt.percent bits (shr is for unsigned)
	movq	$0, %r9
	movw	$0b11111111, %r9w	#to be used as a mask
	andq	%r9, %rdi	#so that the only set bits in rdi will be the percent bits
	movw	%di, %ax	#ax holds the actual percent
	cmpw	$10, %ax	#checking if batt.percent >=10
	jge	.SETMIDDLEDIGIT	#set middle digit if percent is greater than or equal to 10
	jmp	.AFTER7		#else jump 

.SETMIDDLEDIGIT:
	#remember, r14 holds the middle_digit
	#r10d is our digit_holder and r8 points to our array
	movq	$0, %rdi	#zeroing out rdi
	movq	%rcx, %rdi	#reseting the batt struct in rdi
	movq	$0, %r15		#zeroing out r15
	movl	(%r8,%r14,4),%r15d	# r15d = array[middle_digit], note 32-bit movl and dest reg	
	shl	$7, %r15d		#shifting temp reg left by 7 for correct alignment
	orl	%r15d, %r10d		#digit_holder = digit_holder | r15d (the temp reg with our bit mask)
	movq	$0, %rdi	#zeroing out rdi
	movq	%rcx, %rdi	#reseting the batt struct in rdi
	
.AFTER7:
	## we have to set the right digit no matter what
	#remember r13 holds our right_digit
	movq	$0, %r15		#zeroing out r15	
	movl	(%r8,%r13,4),%r15d	# r15d = array[right_digit], note 32-bit movl and dest reg	
	orl	%r15d, %r10d		#digit_holder = digit_holder | r15d (the temp reg with our bit mask) 
	movq	$0, %rdi	#zeroing out rdi
	movq	%rcx, %rdi	#reseting the batt struct in rdi
	shr	$24, %rdi	#shifting rdi right by 24 to access batt.mode bits (shr is for unsigned) 
	cmpq	$0, %rdi	#checking if batt.mode == 0
	je	.SETV		#turn on the V
	##else display % instead
	movq	$0, %r15		#zeroing out r15
	movl	$0b1, %r15d		#temp mask
	shl	$23, %r15d		#moving bits to correct alignment
	orl	%r15d, %r10d		#digit_holder = digit_holder | r15d (the temp reg with our bit mask) 
	jmp	.AFTER8

.SETV:
	movq	$0, %r15		#zeroing out r15
	movl	$0b11, %r15d		#temp mask
	shl	$21, %r15d		#moving bits to correct alignment
	orl	%r15d, %r10d		#digit_holder = digit_holder | r15d (the temp reg with our bit mask) 

.AFTER8:
	##moving on to set battery meter display
	movq	$0, %rdi	#zeroing out rdi
	movq	%rcx, %rdi	#reseting the batt struct in rdi
	shr	$16, %rdi	#shifting rdi right by 16 to access batt.percent bits (shr is for unsigned)
	movq	$0, %r9
	movw	$0b11111111, %r9w	#to be used as a mask
	andq	%r9, %rdi	#so that the only set bits in rdi will be the percent bits
	movw	%di, %ax	#ax holds the actual percent
	cmpw	$90, %ax	#checking if batt.percent >= 90
	jge	.NINETYUP
	cmpw	$70, %ax	#else checking if batt.percent >= 70
	jge	.SEVENTYUP
	cmpw	$50, %ax	#else checking if batt.percent >= 50
	jge	.FIFTYUP
	cmpw	$30, %ax	#else checking if batt.percent >= 30
	jge	.THIRTYUP
	cmpw	$5, %ax	#else checking if batt.percent >= 5
	jge	.FIVEUP
	jmp	.ENDY		#dont turn on any of the battery display bits

.NINETYUP:
	movq	$0, %r15		#zeroing out r15
	movl	$0b11111, %r15d		#temp mask
	shl	$24, %r15d		#moving bits to correct alignment
	orl	%r15d, %r10d		#digit_holder = digit_holder | r15d (the temp reg with our bit mask) 
	jmp	.ENDY

.SEVENTYUP:
	movq	$0, %r15		#zeroing out r15
	movl	$0b1111, %r15d		#temp mask
	shl	$25, %r15d		#moving bits to correct alignment
	orl	%r15d, %r10d		#digit_holder = digit_holder | r15d (the temp reg with our bit mask) 
	jmp	.ENDY

.FIFTYUP:
	movq	$0, %r15		#zeroing out r15
	movl	$0b111, %r15d		#temp mask
	shl	$26, %r15d		#moving bits to correct alignment
	orl	%r15d, %r10d		#digit_holder = digit_holder | r15d (the temp reg with our bit mask) 
	jmp	.ENDY

.THIRTYUP:
	movq	$0, %r15		#zeroing out r15
	movl	$0b11, %r15d		#temp mask
	shl	$27, %r15d		#moving bits to correct alignment
	orl	%r15d, %r10d		#digit_holder = digit_holder | r15d (the temp reg with our bit mask) 
	jmp	.ENDY

.FIVEUP:
	movq	$0, %r15		#zeroing out r15
	movl	$0b1, %r15d		#temp mask
	shl	$28, %r15d		#moving bits to correct alignment
	orl	%r15d, %r10d		#digit_holder = digit_holder | r15d (the temp reg with our bit mask) 
	jmp	.ENDY

.ENDY:
	popq	%r15		#restoring registers
	popq	%r14
	popq	%r13
	popq	%r12
	#remember rsi holds the int pointer and r10 holds the digit_holder
	movl	%r10d, (%rsi)	#*display = digit_holder;
	movq	$0, %rax	#returning 0, indicates no errors
	ret		#end of this function

	   


.text
.global batt_update
        
## ENTRY POINT FOR REQUIRED FUNCTION
batt_update:
	## assembly instructions here
	pushq	%rdx	#push any 64-bit register onto the stack to make room on the stack
	movq	$0, %rax	#zeroing out the rax register
	movw	$-100, 4(%rsp)	#4(%rsp) is the beginning of the struct on the stack
	movb	$-1, 6(%rsp)	#the struct starts at 4 because we need the previous stack space to create mydisplay
	movb	$-1, 7(%rsp)	#mydisplay is a temp display
	leaq	4(%rsp), %rdi	#putting the struct in rdi to be used in the function call (1st argument)
	call	set_batt_from_ports	#return value of function put into eax
	cmpl	$1, %eax		#1 indicates an error
	je	.BIGERROR	#will jmp out and not update display
	movq	$0, %rax	#zeroing out return value
	movl	4(%rsp), %edi	#putting the struct in rdi to be used in the function call;; 1st argument
	movl	$0, (%rsp)	#same as int mydisplay = 0;; 2nd argument
	movq	%rsp, %rsi	#this and the previous call act to dereference the pointer
	call	set_display_from_batt	#return value put in eax
	cmpl	$1, %eax		#1 indicates an error in eax
	je	.BIGERROR	#won't update display
	leaq	BATT_DISPLAY_PORT(%rip), %rsi	#2nd argument for following function call is the real display
	movl	4(%rsp), %edi	#struct to call the function with
	call	set_display_from_batt
	popq	%rdx		#popping off the 64 bit register
	movl	$0, %eax	#returning 0 indicating no error
	ret
	

.BIGERROR:
	#eax is already equal to 1 so no need to set it to 1
	popq	%rdx	#deleting the space we made on the stack
	ret












