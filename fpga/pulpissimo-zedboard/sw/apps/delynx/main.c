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

// interval between probing in µs
static int waitfor = 1000;

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

static FILE *output;

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

    load_cnt = instr_cnt + 8;

    if ((store_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_1)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_1\n");
        exit(-1);
    }

    alu_cnt = store_cnt + 8;

    if ((mult_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_2)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_2\n");
        exit(-1);
    }

    branch_cnt = mult_cnt + 8;

    if ((branch_taken_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_3)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_3\n");
        exit(-1);
    }

    fpu_cnt = branch_taken_cnt + 8;

    if ((jump_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_4)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_4\n");
        exit(-1);
    }

    hwl_init_cnt = jump_cnt + 8;

    if ((hwl_jump_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_5)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_5\n");
        exit(-1);
    }

    inst_fetch_cnt = hwl_jump_cnt + 8;

    if ((cycl_wasted_cnt = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_6)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_6\n");
        exit(-1);
    }

    if ((eop = mmap(0, getpagesize(), PROT_READ, MAP_SHARED, fd, axi_gpio_7)) == MAP_FAILED) {
        perror("Error mapping axi_gpio_7\n");
        exit(-1);
    }

    overflow = instr_cnt + 2;    


}

int main (int argc, char** argv) {
    printf("Starting delynx\n");
    
    // make sure we are given a program name
    if (argc != 2) {
        perror("Wrong usage. Wrong argument count.");
        exit(-1);
    }

    printf("Mapping GPIO units\n");
    // Map the GPIOs
    map_gpios();

    printf("Opening output file\n");
    // open the output file
    output = fopen(argv[1], "w");
    if (output == NULL) {
        perror("Could not open output file.");
        exit(-1);
    }

    uint32_t instr_cnt_cur;
    uint32_t load_cnt_cur;
    uint32_t store_cnt_cur;
    uint32_t alu_cnt_cur;
    uint32_t mult_cnt_cur;
    uint32_t branch_cnt_cur;
    uint32_t branch_taken_cnt_cur;
    uint32_t fpu_cnt_cur;
    uint32_t jump_cnt_cur;
    uint32_t hwl_init_cnt_cur;
    uint32_t hwl_jump_cnt_cur;
    uint32_t inst_fetch_cnt_cur;
    uint32_t cycl_wasted_cnt_cur;

    struct timeval startTime;
    struct timeval endTime;

    printf("Starting data gathering...\n");
    // GPIO and file open and ready. Start logging
    while (!eop) {
        // save start time
        gettimeofday(&startTime, NULL);

        // read the gpio values
        instr_cnt_cur = *instr_cnt;
        load_cnt_cur = *load_cnt;
        store_cnt_cur = *store_cnt;
        alu_cnt_cur = *alu_cnt;
        mult_cnt_cur = *mult_cnt;
        branch_cnt_cur = *branch_cnt;
        branch_taken_cnt_cur = *branch_taken_cnt;
        fpu_cnt_cur = *fpu_cnt;
        jump_cnt_cur = *jump_cnt;
        hwl_init_cnt_cur = *hwl_init_cnt;
        hwl_jump_cnt_cur = *hwl_jump_cnt;
        inst_fetch_cnt_cur = *inst_fetch_cnt;
        cycl_wasted_cnt_cur = *cycl_wasted_cnt;

        // check if eop has not been reached in the meantime
        if (*eop || *overflow) break;

        // save to csv file
        fprintf(output, "%u,", instr_cnt_cur);
        fprintf(output, "%u,", load_cnt_cur);
        fprintf(output, "%u,", store_cnt_cur);
        fprintf(output, "%u,", alu_cnt_cur);
        fprintf(output, "%u,", mult_cnt_cur);
        fprintf(output, "%u,", branch_cnt_cur);
        fprintf(output, "%u,", branch_taken_cnt_cur);
        fprintf(output, "%u,", fpu_cnt_cur);
        fprintf(output, "%u,", jump_cnt_cur);
        fprintf(output, "%u,", hwl_init_cnt_cur);
        fprintf(output, "%u,", hwl_jump_cnt_cur);
        fprintf(output, "%u,", inst_fetch_cnt_cur);
        fprintf(output, "%u\n", cycl_wasted_cnt_cur);

        // wait until next time step
        gettimeofday(&endTime, NULL);
        usleep(waitfor - (endTime.tv_usec - startTime.tv_usec));
    }

    printf("EOP signal received. Ending data gathering.\n");

    // read the final values and write to file
    instr_cnt_cur = *instr_cnt;
    load_cnt_cur = *load_cnt;
    store_cnt_cur = *store_cnt;
    alu_cnt_cur = *alu_cnt;
    mult_cnt_cur = *mult_cnt;
    branch_cnt_cur = *branch_cnt;
    branch_taken_cnt_cur = *branch_taken_cnt;
    fpu_cnt_cur = *fpu_cnt;
    jump_cnt_cur = *jump_cnt;
    hwl_init_cnt_cur = *hwl_init_cnt;
    hwl_jump_cnt_cur = *hwl_jump_cnt;
    inst_fetch_cnt_cur = *inst_fetch_cnt;
    cycl_wasted_cnt_cur = *cycl_wasted_cnt;

    fprintf(output, "%u,", instr_cnt_cur);
    fprintf(output, "%u,", load_cnt_cur);
    fprintf(output, "%u,", store_cnt_cur);
    fprintf(output, "%u,", alu_cnt_cur);
    fprintf(output, "%u,", mult_cnt_cur);
    fprintf(output, "%u,", branch_cnt_cur);
    fprintf(output, "%u,", branch_taken_cnt_cur);
    fprintf(output, "%u,", fpu_cnt_cur);
    fprintf(output, "%u,", jump_cnt_cur);
    fprintf(output, "%u,", hwl_init_cnt_cur);
    fprintf(output, "%u,", hwl_jump_cnt_cur);
    fprintf(output, "%u,", inst_fetch_cnt_cur);
    fprintf(output, "%u\n", cycl_wasted_cnt_cur);

    printf("Closing file...\n");
    // close the file
    fclose(output);
    return(0);
}
