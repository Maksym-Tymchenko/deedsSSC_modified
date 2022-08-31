#!/bin/bash

rm forloop_nifty_deeds_output.txt

for IMG in 1 2 3 4 5 6 7 8 12 13 14 15 16 17 18 19 21 23 24 25 26 27

do sh ./MRI_to_US_nifty_deeds.sh $IMG >> forloop_nifty_deeds_output.txt

done

grep '^(' forloop_nifty_deeds_output.txt > error_list_MRI_to_US_nifty_deeds.txt