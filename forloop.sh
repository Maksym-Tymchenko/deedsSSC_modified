#!/bin/bash

rm forloop_output.txt

for IMG in 1 2 3 4 5 6 7 8 12 13 14 15 16 17 18 19 21 23 24 25 26 27

do sh ./automatic_registration_US_to_MRI.sh $IMG >> forloop_output.txt

done

grep '^(' forloop_output.txt > error_list_US_to_MRI.txt