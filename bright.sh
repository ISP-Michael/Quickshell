#!/bin/sh
text=$(echo "scale=2; $(bat /sys/class/backlight/amdgpu_bl1/brightness) / $(bat /sys/class/backlight/amdgpu_bl1/max_brightness)" | bc)
echo "$text" > tmp.txt
cat tmp.txt
