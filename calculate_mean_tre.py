# filename = "error_list_MRI_to_US.txt"
filename = "error_list_US_to_MRI.txt"

with open(filename) as f:
    mean_err = 0
    num_el = 0
    for line in f:
        err = line.split()[-1].replace(")", "")
        mean_err += float(err)
        num_el += 1

    mean_err = mean_err / num_el
    print(f"mTRE =  {mean_err:.3f}vox = {mean_err/2:.3f}mm")