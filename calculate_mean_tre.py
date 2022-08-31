filename = "error_lists/error_list_MRI_to_US.txt"
# filename = "error_list_MRI_to_US_fitted.txt"
# filename = "error_list_MRI_to_US_fitted_nifty_sym.txt"
# filename = "error_list_MRI_to_US_fitted_nifty.txt"
# filename = "error_list_MRI_to_US_fitted_nifty_masked.txt"
# filename = "error_list_MRI_to_US_linear.txt"
# filename = "error_list_MRI_to_US_0_tol.txt"
# filename = "error_lists/error_list_MRI_to_US_04_alpha.txt"
# filename = "error_lists/BITE_MRI_to_US.txt"
# filename = "error_lists/BITE_MRI_to_US_04_alpha.txt"
# filename =  "error_lists/error_list_MRI_to_US_nifty_deeds.txt"
filename = "error_lists/error_list_MRI_to_US_045_alpha.txt"
# filename = "error_lists/BITE_MRI_to_US_045_alpha.txt"
# filename = "error_lists/New_BITE_MRI_to_US_045_alpha.txt"
# filename = "error_lists/error_list_MRI_to_US_045_alpha_with_padding.txt"
# filename = "error_lists/error_list_MRI_to_US_linear.txt"
#filename = "error_lists/error_list_MRI_to_US_post.txt"
# filename = "error_lists/error_list_MRI_to_US_post_linearBCV.txt"
# filename =  "error_lists/error_list_MRI_to_US_nifty_deeds_post.txt"
#filename = "error_lists/error_list_MRI_to_US_init_pre.txt"

#filename = "error_lists/error_list_MRI_to_US_padding_1px.txt"

with open(filename) as f:
    mean_err = 0
    num_el = 0
    for line in f:
        err = line.split()[-1].replace(")", "")

        if err != "nan":
            mean_err += float(err)
            num_el += 1


    mean_err = mean_err / num_el
    print(f"mTRE =  {mean_err:.3f}vox = {mean_err/2:.3f}mm")

# From BITE paper:
# SSC achieves the best overall registration accuracy of 2.12±1.29 mm