/* 
 * 2022, Friedrich Doku <frd20@pitt.edu>
 */
#ifndef GPIO_H
#define GPIO_H

#include <lwk/driver.h>
#include <lwk/pci/pci.h>
#include <lwk/interrupt.h>
#include <arch/fixmap.h>
#include <arch/io.h>
#include <lwk/blkdev.h>
#include <lwk/delay.h>
#include <lwk/spinlock.h>

#define SW_PORT_IO_BASE 0x01c20800


#define SUNXI_GPIO_A 0
#define SUNXI_GPIO_B 1
#define SUNXI_GPIO_C 2
#define SUNXI_GPIO_D 3
#define SUNXI_GPIO_E 4
#define SUNXI_GPIO_F 5
#define SUNXI_GPIO_G 6
#define SUNXI_GPIO_H 7
#define SUNXI_GPIO_I 8

struct sunxi_gpio {
	unsigned int cfg[4];
	unsigned int dat;
	unsigned int drv[2];
	unsigned int pull[2];
};

/* gpio interrupt control */
struct sunxi_gpio_int {
	unsigned int cfg[3];
	unsigned int ctl;
	unsigned int sta;
	unsigned int deb; /* interrupt debounce */
};

struct sunxi_gpio_reg {
	struct sunxi_gpio	  gpio_bank[9];
	unsigned char		  res[0xbc];
	struct sunxi_gpio_int gpio_int;
};

#define GPIO_BANK(pin) ((pin) >> 5)
#define GPIO_NUM(pin) ((pin)&0x1F)

#define GPIO_CFG_INDEX(pin) (((pin)&0x1F) >> 3)
#define GPIO_CFG_OFFSET(pin) ((((pin)&0x1F) & 0x7) << 2)

/* GPIO bank sizes */
#define SUNXI_GPIO_A_NR (32)
#define SUNXI_GPIO_B_NR (32)
#define SUNXI_GPIO_C_NR (32)
#define SUNXI_GPIO_D_NR (32)
#define SUNXI_GPIO_E_NR (32)
#define SUNXI_GPIO_F_NR (32)
#define SUNXI_GPIO_G_NR (32)
#define SUNXI_GPIO_H_NR (32)
#define SUNXI_GPIO_I_NR (32)

#define SUNXI_GPIO_NEXT(__gpio) \
	((__gpio##_START) + (__gpio##_NR) + 0)

enum sunxi_gpio_number {
	SUNXI_GPIO_A_START = 0,
	SUNXI_GPIO_B_START = SUNXI_GPIO_NEXT(SUNXI_GPIO_A),
	SUNXI_GPIO_C_START = SUNXI_GPIO_NEXT(SUNXI_GPIO_B),
	SUNXI_GPIO_D_START = SUNXI_GPIO_NEXT(SUNXI_GPIO_C),
	SUNXI_GPIO_E_START = SUNXI_GPIO_NEXT(SUNXI_GPIO_D),
	SUNXI_GPIO_F_START = SUNXI_GPIO_NEXT(SUNXI_GPIO_E),
	SUNXI_GPIO_G_START = SUNXI_GPIO_NEXT(SUNXI_GPIO_F),
	SUNXI_GPIO_H_START = SUNXI_GPIO_NEXT(SUNXI_GPIO_G),
	SUNXI_GPIO_I_START = SUNXI_GPIO_NEXT(SUNXI_GPIO_H),
};

/* SUNXI GPIO number definitions */
#define SUNXI_GPA(_nr) (SUNXI_GPIO_A_START + (_nr))
#define SUNXI_GPB(_nr) (SUNXI_GPIO_B_START + (_nr))
#define SUNXI_GPC(_nr) (SUNXI_GPIO_C_START + (_nr))
#define SUNXI_GPD(_nr) (SUNXI_GPIO_D_START + (_nr))
#define SUNXI_GPE(_nr) (SUNXI_GPIO_E_START + (_nr))
#define SUNXI_GPF(_nr) (SUNXI_GPIO_F_START + (_nr))
#define SUNXI_GPG(_nr) (SUNXI_GPIO_G_START + (_nr))
#define SUNXI_GPH(_nr) (SUNXI_GPIO_H_START + (_nr))
#define SUNXI_GPI(_nr) (SUNXI_GPIO_I_START + (_nr))

/* GPIO pin function config */
#define SUNXI_GPIO_INPUT (0)
#define SUNXI_GPIO_OUTPUT (1)

#define SUNXI_GPA0_ERXD3 (2)
#define SUNXI_GPA0_SPI1_CS0 (3)
#define SUNXI_GPA0_UART2_RTS (4)

#define SUNXI_GPA1_ERXD2 (2)
#define SUNXI_GPA1_SPI1_CLK (3)
#define SUNXI_GPA1_UART2_CTS (4)

#define SUNXI_GPA2_ERXD1 (2)
#define SUNXI_GPA2_SPI1_MOSI (3)
#define SUNXI_GPA2_UART2_TX (4)

#define SUNXI_GPA10_UART1_TX (4)
#define SUNXI_GPA11_UART1_RX (4)

#define SUN4I_GPB22_UART0_TX (2)
#define SUN4I_GPB23_UART0_RX (2)

#define SUN5I_GPG3_UART0_TX (4)
#define SUN5I_GPG4_UART0_RX (4)

#define SUNXI_GPC2_NCLE (2)
#define SUNXI_GPC2_SPI0_CLK (3)

#define SUNXI_GPC6_NRB0 (2)
#define SUNXI_GPC6_SDC2_CMD (3)

#define SUNXI_GPC7_NRB1 (2)
#define SUNXI_GPC7_SDC2_CLK (3)

#define SUNXI_GPC8_NDQ0 (2)
#define SUNXI_GPC8_SDC2_D0 (3)

#define SUNXI_GPC9_NDQ1 (2)
#define SUNXI_GPC9_SDC2_D1 (3)

#define SUNXI_GPC10_NDQ2 (2)
#define SUNXI_GPC10_SDC2_D2 (3)

#define SUNXI_GPC11_NDQ3 (2)
#define SUNXI_GPC11_SDC2_D3 (3)

#define SUNXI_GPF2_SDC0_CLK (2)
#define SUNXI_GPF2_UART0_TX (4)

#define SUNXI_GPF4_SDC0_D3 (2)
#define SUNXI_GPF4_UART0_RX (4)


#endif
