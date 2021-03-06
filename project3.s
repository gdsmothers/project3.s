.data
    str: .space 1000
    msgempty: .asciiz "Input is empty."
    msginvalid: .asciiz "Invalid base-28 number."
    msglong: .asciiz "Input is too long."
    
.text 
    main: 
    #tells program to expect userinput
    li $v0, 8 
    la $a0, str
    li $a1, 1000
    syscall  
    #intializing registers for input 
    addi $s5, $0, 0
    addi $t2, $0, 0
    addi $s1, $0, 0 
    
    Empty:
    #checks to see if input is empty 
    la $t3, str
    lb $s5, 0($t3)
    beq $s5, 10, EmptyInput
    beq $s5, 0, EmptyInput 
    
    #Making sure program knows base number 
    addi $t4, $0, 0
    addi $s7, $0, 1
    addi $s2, $0, 28 				
    addi $t5, $0, 0
    addi $t6, $0, 0

    LeftSpaces:
    #deletes the left spaces if any in user input
    lb $s5, 0($t3) #character pointer now at t2
    addi $t3, $t3, 1
    addi $t2, $t2, 1
    beq $s5, 32, LeftSpaces #loop if there is space detected
    beq $s5, 10, EmptyInput 
    beq $s5, $0, EmptyInput
    
    One: #looks at first parameter to make sure its valid
    lb $s5, 0($t3)
    addi $t3, $t3, 1
    addi $t2, $t2, 1
    addi $t6, $t6, 1
    beq $s5, 10, StartOver #Returns to start (pointer) if space or another line is found 
    beq $s5, 0, StartOver
    bne $s5, 32 One #ascii for space is 32 and if space not found loops again 
    
    Two: #looks at first parameter for spaces
    lb $s5, 0($t3)
    addi $t3, $t3, 1
    addi $t2, $t2, 1
    addi $t6, $t6, 1
    beq $s5, 10, StartOver
    beq $s5, 0, StartOver
    bne $s5, 10 Error 
    j Two

    StartOver:
    #Makes the pointer go back to the beginning
    sub $t3, $t3, $t2
    la $t2, 0 
    
    Beginning:
    lb $s5, 0($t3)
    addi $t3, $t3, 1
    beq $s5, 32, Beginning #If character found iteration stops
    addi $t3, $t3, -1 #Re-aligned the pointer
    
    CheckLength: #length loop 
    #Checks if the string is too long
    lb $s5, ($t3)
    addi $t3, $t3, 1 
    addi $t2, $t2, 1
    beq $s5, 10, Reset	
    beq $s5, 0, Reset
    beq $s5, 32, Reset
    beq $t2, 5, LongInput #if string is of appropriate length 
    j CheckLength
    
    Reset:
    sub $t3, $t3, $t2
    sub $t2, $t2, $s7
    lb $s5, 0($t3) #loading first byte
    sub $s4, $t2, $s7  
    move $s6, $t2 #save the length of the string  
    
    Power:
    #Finding Power to move counter to 0 
    beq $s4, 0, Recurse
    mult $s7, $s2
    mflo $s7 #trying to get counter to 0
    sub $s4, $s4, 1 #decrement
    j Power
    
    Recurse:
    addi $sp, $sp, -16
    sw $s5, 0($sp)
    sw $t3, 4($sp) #address of the string
    sw $s1, 8($sp)
    sw $s6, 12($sp)
    jal ConvertString
    
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    #Prints
    li $v0, 1 
    syscall 
    #Ends Program 
    li $v0, 10
    syscall
    
    .globl ConvertString #can be accessed from anywhere 
    ConvertString:
    #loading information into registers
    lw $s5 0($sp) #character
    lw $t3 4($sp) #address
    lw $s1, 8($sp) #power
    lw $s6, 12($sp) #length
    addi $sp, $sp, 16

    addi $sp, $sp, -8 #allocating more memory
    sw $ra, 0($sp)
    sw $s5, 4($sp)
     
    #base case
    beq $s1, $s6, Return
    
    lb $s5, 0($t3)
    #increment pointer and counter
    addi $t3, $t3, 1
    addi $s1, $s1, 1
    
    #makes sure that character is in range 
    #cannot be less than 0
    blt $s5, 48, InvalidInput 
    #chracter number between 0-9 
    blt $s5, 58, Ascii 
    #cannot be less than A
    blt $s5, 65, InvalidInput  
    #character capital between A-S
    blt $s5, 83, Letter
    #cannon be between S and '
    blt $s5, 97, InvalidInput
    #character between a-s  
    blt $s5, 115, Regular
    #cannot be between t-DEL
    blt $s5, 128, InvalidInput  
    
    Letter:
    #trying to get Ascii value for characters
    addi $s5, $s5, -55 
    j MoveOn
    
    Regular:
    #Ascii aswell
    addi $s5, $s5, -83
    j MoveOn 
    
    Ascii:
    #Ascii for numbers
    addi $s5, $s5, -48
    j MoveOn
    
    MoveOn:
    #Byte will be added by power of base 
    mul $s5, $s5, $s7
    div $s7, $s7, 28
    #space for character, address, power, and length
    addi $sp, $sp, -16
    sw $s5, 0($sp) 
    sw $t3, 4($sp) 
    sw $s1, 8($sp) 
    sw $s6, 12($sp) 
    
    jal ConvertString #loop for recursion
    
    lw $v0, 0($sp)
    addi $sp, $sp, 4 
    add $v0, $s5, $v0 #adding the values that were converted
    
    lw $ra, 0($sp)	
    lw $s5, 4($sp)	
    addi $sp, $sp, 8 
    
    addi $sp, $sp, -4
    sw $v0, 0($sp)
    #moves to return address
    jr $ra
    
    #Signaling the end of the recursion function
    Return: 
    li $v0, 0	
    lw $ra, 0($sp)	
    lw $s5, 4($sp)	
    addi $sp, $sp, 8	
    addi $sp, $sp, -4
    sw $v0, 0($sp)
    jr $ra 

    EmptyInput:
    #checks to see if the input is empty
    la $a0, msgempty #loading message 
    li $v0, 4 #prints string
    syscall 
    j exit 
    
    InvalidInput:
    #checks to see if the input is invlalid 
    la $a0, msginvalid
    li $v0, 4
    syscall 
    j exit 
    
    LongInput:
    #checks to see if the input is longer than 4 characters
    la $a0, msglong
    li $v0, 4
    syscall 
    j exit  
    
    exit:
    #tell the system the end of main 
    li $v0, 10
    syscall   
    
    #Error based off of length or base 
    Error:
    bge $t6, 4, LongInput
    j InvalidInput
    jr $ra


