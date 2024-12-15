#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>


unsigned long gpio_0_addr = 0x43C00000;

int main()
{

	int fd = open("/dev/mem", O_RDWR | O_SYNC);
	int bytes = 4;
	unsigned long *gpio_addr = (unsigned long *)mmap(NULL,bytes,PROT_READ | PROT_WRITE, MAP_SHARED, fd, gpio_0_addr);

	clock_t start = clock();

	gpio_addr[10] = 999999; // set repeat

	gpio_addr[1] =   (((unsigned char)'a' <<24) +
			   ((unsigned char)'b' <<16) +
			   ((unsigned char)'c' <<8) +
			   ((unsigned char)'0' <<0));


	gpio_addr[0] = (1<<31) + (1<<30) + 0xE;
	gpio_addr[0] = (0<<31) + (0<<30) + 0x7;

	while(gpio_addr[11] == 0); // wait calc

	printf("slv_reg11 = %d\r\n",gpio_addr[11]);

	unsigned int slv_hash;

	for (int i = 2;i<10;i++)
	{
		slv_hash = gpio_addr[i];
    	printf("%x",slv_hash);
	}	

	printf("\r\n");

    clock_t end = clock();
    
    float seconds = (float)(end - start);// / CLOCKS_PER_SEC;

    printf("%f\r\n",seconds);

    return 0;

}
