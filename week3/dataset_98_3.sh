#!/bin/sh

x=`cat dataset_98_3.txt | tr -d '\n'`
echo "$x * ($x - 1)" | bc > dataset_98_3_output.txt
