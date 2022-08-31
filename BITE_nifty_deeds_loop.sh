#!/bin/bash

rm BITE_loop_output.txt

for IMG in 01 02 03 04 05 06 07 08 09 10 11 12 13 14

do sh ./BITE_MRI_to_US_nifty_deeds.sh $IMG >> BITE_loop_output.txt

done

grep '^(' BITE_loop_output.txt > "error_lists/New_BITE_MRI_to_US_nifty_deeds.txt"