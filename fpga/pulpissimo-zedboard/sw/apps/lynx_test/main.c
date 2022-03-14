// Copyright 2021 TU Wien
// Author: Fabian Posch
// Small application to read data registers from the datalynx interconnect

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>

static volatile uint32_t *instr_cnt;
static volatile uint32_t *load_cnt;
static volatile uint32_t *store_cnt;
static volatile uint32_t *alu_cnt;
static volatile uint32_t *mult_cnt;
static volatile uint32_t *branch_cnt;
static volatile uint32_t *branch_taken_cnt;
static volatile uint32_t *fpu_cnt;
static volatile uint32_t *jump_cnt;
static volatile uint32_t *hwl_init_cnt;
static volatile uint32_t *hwl_jump_cnt;
static volatile uint32_t *inst_fetch_cnt;
static volatile uint32_t *cycl_wasted_cnt;
static volatile uint32_t *eop;
static volatile uint32_t *overflow;

static const uint32_t axi_gpio_0 = 0x41200000;
static const uint32_t axi_gpio_1 = 0x41210000;
static const uint32_t axi_gpio_2 = 0x41220000;
static const uint32_t axi_gpio_3 = 0x41230000;
static const uint32_t axi_gpio_4 = 0x41240000;
static const uint32_t axi_gpio_5 = 0x41250000;
static const uint32_t axi_gpio_6 = 0x41260000;
static const uint32_t axi_gpio_7 = 0x41270000;

void map_gpios (void) {
	int fd;

    if ((fd = open("/dev/mem", O_RDWR | O_SYNC)) < 0) {
        perror("Error opening /dev/mem\n");
        exit(-1);
    }
    
    if ((instr_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_0)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_0\n");
        exit(-1);
    }

    load_cnt = instr_cnt + 2;

    if ((store_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_1)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_1\n");
        exit(-1);
    }

    alu_cnt = store_cnt + 2;

    if ((mult_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_2)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_2\n");
        exit(-1);
    }

    branch_cnt = mult_cnt + 2;

    if ((branch_taken_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_3)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_3\n");
        exit(-1);
    }

    fpu_cnt = branch_taken_cnt + 2;

    if ((jump_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_4)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_4\n");
        exit(-1);
    }

    hwl_init_cnt = jump_cnt + 2;

    if ((hwl_jump_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_5)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_5\n");
        exit(-1);
    }

    inst_fetch_cnt = hwl_jump_cnt + 2;

    if ((cycl_wasted_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_6)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_6\n");
        exit(-1);
    }

    if ((eop = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_7)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_7\n");
        exit(-1);
    }

    overflow = eop + 2;    


}

int main (int argc, char** argv) {
    printf("Starting lynx_test\n");
    
    printf("Mapping GPIO units\n");
    // Map the GPIOs
    map_gpios();

    uint16_t overflow_masked = *overflow;
    overflow_masked = 0x1FFF & overflow_masked;
    uint8_t eop_masked = *eop;
    eop_masked = 0x1 & eop_masked;

    printf("Gathering data...\n");
    printf("instr_cnt: %u\n", *instr_cnt);
    printf("load_cnt: %u\n", *load_cnt);
    printf("store_cnt: %u\n", *store_cnt);
    printf("alu_cnt: %u\n", *alu_cnt);
    printf("mult_cnt: %u\n", *mult_cnt);
    printf("branch_cnt: %u\n", *branch_cnt);
    printf("branch_taken_cnt: %u\n", *branch_taken_cnt);
    printf("fpu_cnt: %u\n", *fpu_cnt);
    printf("jump_cnt: %u\n", *jump_cnt);
    printf("hwl_init_cnt: %u\n", *hwl_init_cnt);
    printf("hwl_jump_cnt: %u\n", *hwl_jump_cnt);
    printf("inst_fetch_cnt: %u\n", *inst_fetch_cnt);
    printf("cycl_wasted_cnt: %u\n", *cycl_wasted_cnt);
    printf("eop: %u\n", eop_masked);
    printf("overflow: %u\n", overflow_masked);

    return(0);
}
