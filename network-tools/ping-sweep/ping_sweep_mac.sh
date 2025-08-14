#!/bin/bash

# Simple Mac Ping Sweep Tool

read -p "Enter network prefix (e.g., 192.168.1): " PREFIX

for i in {1..254}
do
  ping -c 1 -W 1 ${PREFIX}.${i} &> /dev/null
  
  if [ $? -eq 0 ]; then
    echo "Host ${PREFIX}.${i} is UP"
  else
    echo "Host ${PREFIX}.${i} is DOWN"
  fi
done

