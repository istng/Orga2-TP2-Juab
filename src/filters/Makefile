# ************************************************************************* #
# Organizacion del Computador II                                            #
#                                                                           #
#   Trabajo Practico 2                                                      #
#                                                                           #
# ************************************************************************* #

all: C_fourCombine.o C_linearZoom.o C_maxCloser.o C_convert.o ASM_fourCombine.o ASM_linearZoom.o ASM_maxCloser.o ASM_maxCloser_cache.o ASM_convert.o filter_toX.o ASM_convert_loopUnrolling.o ASM_convert_phaddd.o ASM_convert_macros.o C_convert_defines.o ASM_fourCombine_unrolling.o ASM_linearZoom_mem_alineada.o ASM_linearZoom_tres_pasadas.o

CFLAGS=-Wall -Wextra -pedantic -O0 -ggdb -lm -std=c99
# CFLAGS=-Wall -O0 -ggdb -lm -std=c99 -Wunused-variable

NASMFLAGS=-f elf64 -g -F DWARF

%.o: %.c filters.h
	gcc $(CFLAGS) -c -o $@ $<

%.o: %.asm
	nasm $(NASMFLAGS) -o $@ $<

clean:
	rm  -f *.o
