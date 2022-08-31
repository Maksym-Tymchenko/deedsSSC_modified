#!/bin/bash

rm forloop_init_output.txt

for IMG in 1 2 3 4 5 6 7 8 12 13 14 15 16 17 18 19 21 23 24 25 26 27

do sh ./calculate_init_tre.sh $IMG >> forloop_init_output.txt

done

grep '^(' forloop_init_output.txt > error_lists/error_list_MRI_to_US_init_pre.txt