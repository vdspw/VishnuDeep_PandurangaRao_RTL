Contains 2 kinds of RTL folders :
1. RTL_ref -> reference RTL for which the spec is written.
2. RTL_Errors -> contais RTL wiht erros implanted.
3. RTL_exp -> expected result of the prompt.

DOCS folder:
1. The tech spec written for the refence.
2. Error locations and descriptions.
3. Potenitial solutions to these errors.

Overview :
The base design of AXI4 stream for UART is used and the orginal design is the reference and 
the technical specifications are written based on this ( RTL_ref) . Based on the technical spec
and the Errors introduced should be resolved to bring the design to the level of RTL_ref.
The second stage solution is about altering the design specifications by changing the sampling rate to 4x
on all operations and changing the active low initiated design into active high initiated one.
