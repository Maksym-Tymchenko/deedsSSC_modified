#!/bin/sh

# Input arguments
case_num=${1-"01"}

image_folder=${2:-"bucket/BITE_group2_nii/${case_num}"}
us_image_uncompressed="US3DT.nii"
mri_image_uncompressed="MR.nii"
tag_file="bucket/BITE_group2_nii/BITE_group2_nii_tags/${case_num}/${case_num}_all.tag"

# Create directory to store the outputs
mkdir -p $image_folder/output/deeds

output_folder="$image_folder/output/deeds"

us_image="$output_folder/US3DT.nii.gz"
mri_image="$output_folder/MR.nii.gz"

# Compress images to match format expected by deedsBCV
# gzip -fck $image_folder/$us_image_uncompressed > $us_image
# gzip -fck $image_folder/$mri_image_uncompressed > $mri_image


# Resample images into a common reference frame and isotropic voxel size of 0.5x0.5x0.5 mm
c3d $us_image $mri_image -reslice-identity -resample-mm 0.5x0.5x0.5mm -o $output_folder/Case${case_num}-MRI_in_US.nii.gz
c3d $us_image -resample-mm 0.5x0.5x0.5mm -o $output_folder/Case${case_num}-US.nii.gz


# Generate 2 text files containing landmarks
python3 ./landmarks_split_txt.py --inputtag $tag_file --savetxt $output_folder/Case${case_num}_lm


# Generate landmark segmentations as a NIFTI file
c3d $output_folder/Case${case_num}-MRI_in_US.nii.gz -scale 0 -landmarks-to-spheres $output_folder/Case${case_num}_lm_mri.txt 1 -o $output_folder/Case${case_num}-MRI-landmarks.nii.gz
c3d $output_folder/Case${case_num}-US.nii.gz -scale 0 -landmarks-to-spheres $output_folder/Case${case_num}_lm_us.txt 1 -o $output_folder/Case${case_num}-US-landmarks.nii.gz


# Calculate mTRE
python3 ./landmarks_centre_mass_missing_vals.py \
--inputnii $output_folder/Case${case_num}-US-landmarks.nii.gz \
--movingnii $output_folder/Case${case_num}-MRI-landmarks.nii.gz \
--savetxt $output_folder/Case${case_num}-results
