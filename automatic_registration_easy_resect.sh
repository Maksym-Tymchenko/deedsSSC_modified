#!/bin/sh

# Input arguments

case_num=${1-"1"}
image_folder=${2:-"bucket/EASY-RESECT/NIFTI/Case${case_num}"}

us_image_uncompressed=${3:-"Case${case_num}-US-before-resize.nii"}
mri_image_uncompressed=${4:-"Case${case_num}-FLAIR-resize.nii"}

us_image=${5:-"Case${case_num}-US-before-resize.nii.gz"}
mri_image=${6:-"Case${case_num}-FLAIR-resize.nii.gz"}

# Create directory to store the outputs
mkdir -p $image_folder/output

# Compress images to match format expected by deedsBCV
gzip -f --keep $image_folder/$us_image_uncompressed
gzip -f --keep $image_folder/$mri_image_uncompressed

# Apply linear rigid pre-registration
./linearBCV -F $image_folder/$us_image -M $image_folder/$mri_image -R 1 -O $image_folder/output/affine${case_num}

# Perform non linear registration
./deedsBCV -F $image_folder/$us_image -M $image_folder/$mri_image -O $image_folder/output/Case${case_num}-deeds -S $image_folder/../landmarks/Case${case_num}-MRI-landmarks.nii.gz -A $image_folder/output/affine${case_num}_matrix.txt

# Calculate mTRE
python3 ./landmarks_centre_mass.py --inputnii $image_folder/../landmarks/Case${case_num}-US-landmarks.nii.gz --movingnii $image_folder/output/Case${case_num}-deeds_deformed_seg.nii.gz --savetxt $image_folder/output/Case${case_num}-results