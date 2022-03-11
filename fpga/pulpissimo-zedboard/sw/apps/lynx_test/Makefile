ifeq ($(VIVADO_VERSION),2018.3)
	ARMCC?=arm-linux-gnueabihf-gcc
else
	ARMCC?=arm-xilinx-linux-gnueabi-gcc
endif
CC = $(ARMCC)
CFLAGS = -Wall

ifeq ($(BOARD),zybo)
	CFLAGS += -DZYBO
endif

all: lynx_test

lynx_test: main.c
	$(CC) $(CFLAGS) -pthread -o $@ $^

push: remake
	scp -i $(FPGA_IDFILE) ./lynx_test root@$(FPGA_HOSTNAME):/root/

clean:
	@rm -f ./*.o lynx_test

remake:
	clear
	make all
