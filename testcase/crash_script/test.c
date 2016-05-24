#include <stdio.h>

typedef unsigned int kmem_bufctl_t;
#define BUFCTL_END	(((kmem_bufctl_t)(~0U))-0)
#define BUFCTL_FREE	(((kmem_bufctl_t)(~0U))-1)
#define	BUFCTL_ACTIVE	(((kmem_bufctl_t)(~0U))-2)
#define	SLAB_LIMIT	(((kmem_bufctl_t)(~0U))-3)

struct abc
{
	int	*a;
	int	*b;
	int	*c;
};

kmem_bufctl_t *slab_bufctl(struct abc *slabp)
{
	printf("slabp+1 %p\n", (slabp + 1));
	return (kmem_bufctl_t *) (slabp + 1);
}

main()
{
	struct abc	dd, *p;

	p = &dd;

	printf("BUFCTL_END %x\n", BUFCTL_END);
	printf("BUFCTL_FREE %x\n", BUFCTL_FREE);
	printf("BUFCTL_ACTIVE %x\n", BUFCTL_ACTIVE);
	printf("SLAB_LIMIT %x\n", SLAB_LIMIT);
	printf("p      %p\n", p);
	printf("P+1    %p\n", slab_bufctl(p));
	printf("P+1[0] %p\n", slab_bufctl(p)[0]);
	printf("P+1[1] %p\n", slab_bufctl(p)[1]);
	printf("P+1[2] %p\n", slab_bufctl(p)[2]);
	printf("P+1[3] %p\n", slab_bufctl(p)[3]);
	printf("P+1[4] %p\n", slab_bufctl(p)[4]);
	slab_bufctl(p)[0] = 1;
	slab_bufctl(p)[1] = 2;
	slab_bufctl(p)[2] = 3;
	slab_bufctl(p)[3] = 4;
	slab_bufctl(p)[4] = BUFCTL_END;
	printf("P+1[0] %p\n", slab_bufctl(p)[0]);
	printf("P+1[1] %p\n", slab_bufctl(p)[1]);
	printf("P+1[2] %p\n", slab_bufctl(p)[2]);
	printf("P+1[3] %p\n", slab_bufctl(p)[3]);
	printf("P+1[4] %p\n", slab_bufctl(p)[4]);

}
