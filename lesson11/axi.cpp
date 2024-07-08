#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <iostream>

unsigned long gpio_0_addr = 0x41200000;

int main()
{
	int fd = open("/dev/mem", O_RDWR | O_SYNC);
	
	int bytes = 4;

	unsigned long *gpio_0 = (unsigned long *)mmap(NULL,bytes,PROT_READ | PROT_WRITE, MAP_SHARED, fd, gpio_0_addr);

	gpio_0[0] = 10;
	gpio_0[0] = 0;

	return 0;

}
