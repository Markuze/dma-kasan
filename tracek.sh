#!/bin/bash

sudo apt-get install trace-cmd -y

echo 1 | sudo tee /sys/kernel/debug/tracing/options/trace_printk
sudo cat /sys/kernel/debug/tracing/trace > trace_output
