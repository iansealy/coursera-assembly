#!/bin/sh

x=`cat dataset_100_2.txt | tr -d '\n'`
echo "$x * ($x + 1) / 2 + 1" | bc > dataset_100_2_output.txt
