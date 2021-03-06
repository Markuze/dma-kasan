# dma-kasan

Setup configuration
----------------------

Run the create\_image.sh script to:
(0) install kernel build utilities;
(1) clone an ubuntu kernel (v5.0);
(2) apply the three patches available in the root directory;
(3) configure the kernel to use KASAN in addition to the configuration for the
currently running kernel;
(4) compile and install the kernel.

Then reboot and load the newly installed kernel.


Experiments
-----------

To initiate tracing run tracek.sh which sets up kernel ftracing that
we use for KASAN logging, it also dumps the current log to output\_trace.

On the newly installed kernel, run an IO application that exercises the DMA
APIs. We run pings with various messages sizes to trigger DMA map/unmap
operations of various lengths in NIC drivers.  For example, ping 128 times with
0.01 second intervals between requests sending packets to destination IP $ip
with lengths of 8,16,...1496:
```
for i in `seq 8 8 1496`; do sudo ping -s $i -c 128 -i 0.01 $ip; done
```

Additional methods to stress IO include:
* compiling the linux kernel
* benchmarks such as filebench and netperf
* listing directories

We provide a script that stresses these components (run\_me.sh). To
run the script set the following environment variables:
* $ip -- some destination IP address.
* $if -- some local network interface.
* $repeat -- number of repeatitions for the test.

After the IO stressing operation completes, check logs written to the local
trace\_output\_end file for any interesting issues caught by DMA-KASAN.

Example output
---------------
$ ./tracek.sh
or
$ trace-cmd show

```
size 512 [READ, WRITE] __alloc_skb+0xe0/0x3f0
size 512 [WRITE] load_elf_phdrs+0xbf/0x130
size 512 [WRITE] __do_execve_file.isra.0+0x287/0x1080
size 64  [WRITE] sock_alloc_inode+0x4f/0x120
size 328 [READ, WRITE] assoc_array_insert+0xa9/0x7e0
```
Recommendations and extensability
---------------------------------

* Compile the kernel with as many models as possible. Sometimes kernel modules
  will perform DMA operations even if they are not actively being used.
* Excercise as many IO devices as possible. Concurrent operations on the DMA API
  increases the likelihood of finding bugs.
