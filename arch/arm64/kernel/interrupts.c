/** \file
 * x86-64 interrupt handlers.
 *
 *
 */
#include <lwk/aspace.h>
#include <lwk/init.h>
#include <lwk/interrupt.h>
#include <lwk/kallsyms.h>
#include <lwk/kernel.h>
#include <lwk/kgdb.h>
#include <lwk/sched.h>
#include <lwk/show.h>
#include <lwk/task.h>
#include <lwk/timer.h>
// #include <arch/desc.h>
#include <arch/extable.h>
#include <arch/irq_vectors.h>
#include <arch/xcall.h>
// #include <arch/i387.h>
#include <arch/io.h>
#include <arch/irqchip.h>
#include <arch/proto.h>

extern int early_printk(const char *fmt, ...);

idtvec_handler_t irqvec_table[NUM_IRQ_ENTRIES] __aligned(PAGE_SIZE_4KB);
static DEFINE_SPINLOCK(irqvec_table_lock);

idtvec_handler_t ipivec_table[NUM_IPI_ENTRIES] __aligned(PAGE_SIZE_4KB);
static DEFINE_SPINLOCK(ipivec_table_lock);

/** \name Interrupt handlers
 * @{
 */
void do_unhandled_exception(struct pt_regs *regs, unsigned int vector) {
  printk(KERN_EMERG "Unhandled Exception! (vector=%u)\n", vector);
}

/** \name Interrupt handlers
 * @{
 */
void do_unhandled_irq(struct pt_regs *regs, unsigned int vector) {

  printk(KERN_EMERG "Unhandled Interrupt! (vector=%u)\n", vector);
}

static inline u64 get_mair_el1() {
  u64 mair = 0xdeadbeefULL;
  ;
  __asm__ __volatile__("mrs %0, mair_el1\n" : "=r"(mair));
  return mair;
}

static inline u64 get_spsr_el1() {
  u64 spsr = 0xdeadbeefULL;
  __asm__ __volatile__("mrs %0, spsr_el1\n" : "=r"(spsr));
  return spsr;
}

void do_mem_abort(unsigned long addr, unsigned int esr, struct pt_regs *regs) {
  /* Use early_printk for guaranteed immediate output to UART.
   * Regular printk may not flush, and accessing complex structures
   * (like current->aspace) can trigger recursive faults.
   */
  early_printk("do_mem_abort: addr=%p, esr=0x%x\n", (void *)addr, esr);
  early_printk("  ESR.EC=0x%x (exception class)\n", esr >> 26);
  early_printk("  ESR.ISS=0x%x\n", esr & 0x1FFFFFF);

  u64 mair_el1 = get_mair_el1();
  u64 spsr_el1 = get_spsr_el1();
  early_printk("MAIR_EL1: %p\n", (void *)mair_el1);
  early_printk("SPSR_EL1: %p\n", (void *)spsr_el1);

  if (regs) {
    early_printk("PC: %p\n", (void *)instruction_pointer(regs));
    early_printk("SP: %p\n", (void *)regs->sp);
  }

  panic("do_mem_abort: Fatal page fault at %p\n", (void *)addr);
}

void handle_irq(struct pt_regs *regs) {
  struct arch_irq irq = irqchip_ack_irq();

  irqreturn_t ret = IRQ_NONE;

  // printk(">> Hardware IRQ!!!! [%d]\n", irq.vector);

  if (irq.type == ARCH_IRQ_EXT) {
    irqvec_table[irq.vector](regs, irq.vector);
  } else if (irq.type == ARCH_IRQ_IPI) {
    ipivec_table[irq.vector](regs, irq.vector);
  } else if (irq.type == ARCH_IRQ_INVALID) {
    printk("Received Spurious IRQ\n");
  }

  irqchip_do_eoi(irq);
}

void set_irq_handler(unsigned int vector,  //!< Interrupt vector number
                     irq_handler_t handler //!< Callback function
) {
  char namebuf[KSYM_NAME_LEN + 1];
  unsigned long symsize, offset;
  unsigned long irqstate;

  ASSERT(vector < NUM_IRQ_ENTRIES);

  if (handler != &do_unhandled_irq) {
    printk(KERN_DEBUG "IDT Vector %3u -> %s()\n", vector,
           kallsyms_lookup((unsigned long)handler, &symsize, &offset, namebuf));
  }

  spin_lock_irqsave(&irqvec_table_lock, irqstate);
  irqvec_table[vector] = handler;
  spin_unlock_irqrestore(&irqvec_table_lock, irqstate);
}

void set_ipi_handler(unsigned int vector,  //!< Interrupt vector number
                     irq_handler_t handler //!< Callback function
) {
  char namebuf[KSYM_NAME_LEN + 1];
  unsigned long symsize, offset;
  unsigned long irqstate;

  ASSERT(vector < NUM_IPI_ENTRIES);

  if (handler != &do_unhandled_irq) {
    printk(KERN_DEBUG "IPI Vector %3u -> %s()\n", vector,
           kallsyms_lookup((unsigned long)handler, &symsize, &offset, namebuf));
  }

  spin_lock_irqsave(&ipivec_table_lock, irqstate);
  ipivec_table[vector] = handler;
  spin_unlock_irqrestore(&ipivec_table_lock, irqstate);
}

/**
 * Initialize high level exception handling
 */
void __init interrupts_init(void) {
  int vector;

  for (vector = 0; vector < NUM_IRQ_ENTRIES; vector++) {
    set_irq_handler(vector, &do_unhandled_irq);
  }

  for (vector = 0; vector < NUM_IPI_ENTRIES; vector++) {
    set_ipi_handler(vector, &do_unhandled_irq);
  }

  set_ipi_handler(LWK_XCALL_FUNCTION_VECTOR, &arch_xcall_function_interrupt);
  set_ipi_handler(LWK_XCALL_RESCHEDULE_VECTOR,
                  &arch_xcall_reschedule_interrupt);
}
