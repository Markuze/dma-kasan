#!/bin/bash
[ -z "$ip" ] && echo "missing ip=$ip" && exit 1
[ -z "$if" ] && echo "missing network interface if=$if" && exit 1
[ -z "$repeat" ] && echo "missing number of repeatitions=$repeat" && exit 1

function trace_start {
	echo 1 | sudo tee /sys/kernel/debug/tracing/options/trace_printk
	sudo cat /sys/kernel/debug/tracing/trace > trace_output_start
}

function trace_end {
	echo 0 | sudo tee /sys/kernel/debug/tracing/options/trace_printk
	sudo cat /sys/kernel/debug/tracing/trace > trace_output_end
}

function step {
	for i in `seq 8 8 1496`; do sudo ping -s $i -c 128 -i 0.01  $ip; done
	for i in `seq 1 1 254`; do sudo arping -I $if -c 128 192.168.1.$i; done
	cd ubuntu-bionic; make -j2 clean; make -j2; cd -;
	ls -lR ubuntu-bionic
}

trace_start
for i in `seq 1 $repeat`; do
	step
done
trace_end
