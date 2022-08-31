#!/bin/bash

rm forloop_post_output.txt

for IMG in 1 2 3 4 6 7 8 11 12 14 15 16 17 18 19 21 23 24 25 27

do sh ./MRI_to_US_post.sh $IMG >> forloop_post_output.txt

done

grep '^(' forloop_post_output.txt > error_lists/error_list_MRI_to_US_NL_post_no_padding_alpha_16.txt