#!/bin/bash
cpu=$(top -l 1 | grep "CPU usage" | awk '{print $3}')
echo "CPU $cpu"
