# Very simple assembler and Virtual CPU

Only nine (9) instructions! 

DAT, ADD, SUB, CMP, LDA, STA, JMP, JIZ (jump if (accu) zero) and OUT.   

The Virtual machine has three (3) registers only. ACCU, IP and INSTRUCTION register.
The VM uses 128 bytes memory and all CPU steps piped out in a file (memo and regs. content).

The pgm is not too long. Only 220 lines of pascal code. Compiled with free pascal 3.2
You can create self-modifying code! Try it!

The first 16 address of memory (0h..Fh) is the space for variables.
The last memory address (7Fh) is an Outport. 

The source is public domain. Best regards.. W. Weston. 
 




 