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

all: delynx

delynx: main.c
	$(CC) $(CFLAGS) -pthread -o $@ $^

push: remake
	scp -i $(FPGA_IDFILE) ./delynx root@$(FPGA_HOSTNAME):/root/

clean:
	@rm -f ./*.o delynx

remake:
	clear
	make all
