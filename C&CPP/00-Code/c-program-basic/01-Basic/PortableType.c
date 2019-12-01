/*
 ============================================================================
 
 Author      : Ztiany
 Description : 可移植的数据类型

 ============================================================================
 */

#include <stdint.h>
#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>

int main() {
    //精确宽度整数类型（exact-width integer type）
    uint8_t uint8_a = 3;
    uint8_t uint8_b = 3;
    uint16_t uint16_a = 3;
    int32_t int32_a = 44;

    //最小宽度类型（minimum width type）
    int_least8_t intLeast8_a = 2;

    //最快最小宽度类型（fastst minimum width type）
    int_fast8_t fast8 = 32;

    //最大整数类型
    intmax_t intmax = 32;

    printf("sizeof(uint8_t) = %zd\n", sizeof(uint8_a));
    printf("sizeof(uint16_t) = %zd\n", sizeof(uint16_a));
    printf("sizeof(int_least8_t) = %zd\n", sizeof(intLeast8_a));
    printf("sizeof(int_fast8_t) = %zd\n", sizeof(fast8));
    printf("sizeof(intmax_t) = %zd\n", sizeof(intmax));

    //sizeof 返回类型
    size_t size = sizeof(32);
    //C还定义了ptrdiff_t类型和t修饰符来表示系统使用的两个地址差值的底层有符号整数类型
    ptrdiff_t ptrdiff = &uint8_a - &uint8_b;

    return EXIT_SUCCESS;
}

