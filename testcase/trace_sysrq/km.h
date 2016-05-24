#ifndef _KM_H_
#define _KM_H_

#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,0,0)
static char *func_name;
module_param(func_name, charp, 0000);
#endif /* ver 3.2 */

#if LINUX_VERSION_CODE < KERNEL_VERSION(3,0,0)
// 1st probe kernel symbol
static long long_1;
module_param(long_1, long, 0000);

// 2nd probe kernel symbol
static long long_2;
module_param(long_2, long, 0000);
#endif /* ver 2.6 */

#endif /* _KM_H_ */
