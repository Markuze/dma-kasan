#!/bin/bash
[ -z "$ip" ] && echo "missing ip=$ip" && exit 1
[ -z "$if" ] && echo "missing network interface if=$if" && exit 1
[ -z "$repeat" ] && echo "missing number of repeatitions=$repeat" && exit 1

function step {
	for i in `seq 8 8 1496`; do sudo ping -s $i -c 128 -i 0.01  $ip; done
	for i in `seq 1 1 254`; do sudo arping -I $if -c 128 192.168.1.$i; done
	cd ubuntu-bionic; make -j2 clean; make -j2; cd -;
	ls -lR ubuntu-bionic
}

for i in `seq 1 $repeat`; do
	step
done
