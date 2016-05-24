#include <stdio.h>

void
cf(int first, int second, int third)
{
	int x, y, z;
	int *ptr;

	x = first;
	y = second;
	z = third;

	ptr = &x;
}

int
bf(int first, int second, int third, int fourth, int fifth)
{
	int a = first;
	int b = second;
	int c = third;
	int d = fourth;
	int e = fifth;
	int ret;

	cf(a, b, c);

	return 100;
}

int
af(int first, int second, int third, int fourth, int fifth)
{
	int a = 0x10;
	int b = 0x20;
	int c = 0x30;
	int d = 0x40;
	int e = 0x50;
	int ret;

	ret = bf(a, b, c, d, e);

	return ret;
}

main()
{
	int first = 1;
	int second = 2;
	int third = 3;
	int fourth = 4;
	int fifth = 5;
	int ret;

	ret = af(first, second, third, fourth, fifth);

}
