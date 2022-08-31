#!/bin/bash

rm forloop_init_BITE_output.txt

for IMG in 01 02 03 04 05 06 07 08 09 10 11 12 13 14

do sh ./calculate_init_tre_BITE.sh $IMG >> forloop_init_BITE_output.txt

done

grep '^(' forloop_init_BITE_output.txt > error_lists/error_list_MRI_to_US_init_BITE.txt