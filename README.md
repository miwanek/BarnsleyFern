 BarnsleyFern
======================

Barnsley fern generator written in MIPS assembly.

Generator takes 3 three arguments:
- number of iterations(the more iterations, the more detailed fern we get)
- name of input image(max 20 chars)
- name of output image(max 20 chars)

There are two versions :
- in Decimal_Barnsley.asm calculations are based on decimal numbers
- in Binary_Barnsley.asm calculations are based on binary numbers

Exact algorithm how to choose next pixel to paint can be found [here](https://en.wikipedia.org/wiki/Barnsley_fern)


Important note:
--------
MARS simulator is necessary to run the program.
