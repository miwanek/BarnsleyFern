 BarnsleyFern
======================

Barnsley fern generator written in MIPS assembly. Input files should be in bmp format and may have custom proportions 

Generator takes 1 argument:
- number of iterations(the more iterations, the more detailed fern we get)


There are two versions :
- in Decimal_Barnsley.asm calculations are based on decimal numbers
- in Binary_Barnsley.asm calculations are based on binary numbers

Exact algorithm how to choose next pixel to paint can be found [here](https://en.wikipedia.org/wiki/Barnsley_fern)


Important notes:
--------
- MARS simulator is necessary to run the program.
- Program will use input.bmp as input file and output.bmp as output file
- Input file must be in the same directory as MARS
