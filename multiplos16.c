#include <stdio.h>
#include <stdlib.h>

int main() {
	int i = 0;
	while(i < 100) {
		printf("%i %s %i %s", 16*i, "x", 16*i, " ");
		i = i + 6;
	}
}