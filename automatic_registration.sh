#!/bin/sh

# Input arguments

image_folder=${1:-"brain_images"}
us_image=${2:-'Case1-US-before.nii.gz'}
mri_image=${3:-"Case1-FLAIR.nii.gz"}
tag_file=${4:-"Case1-MRI-beforeUS.tag"}

# Resample images into a common reference frame and isotropic voxel size of 0.5x0.5x0.5 mm
c3d $image_folder/$us_image $image_folder/$mri_image -reslice-identity -resample-mm 0.5x0.5x0.5mm -o $image_folder/Case1-MRI_in_US.nii.gz
c3d $image_folder/$us_image -resample-mm 0.5x0.5x0.5mm -o $image_folder/Case1-US.nii.gz


# Apply linear rigid pre-registration
./linearBCV -F $image_folder/Case1-US.nii.gz -M $image_folder/Case1-MRI_in_US.nii.gz -R 1 -O $image_folder/affine1

# Generate 2 text files containing landmarks
python3 ./landmarks_split_txt.py --inputtag $image_folder/$tag_file --savetxt $image_folder/Case1_lm

# Generate landmark segmentations as a NIFTI file
c3d $image_folder/Case1-MRI_in_US.nii.gz -scale 0 -landmarks-to-spheres $image_folder/Case1_lm_mri.txt 1 -o $image_folder/Case1-MRI-landmarks.nii.gz
c3d $image_folder/Case1-US.nii.gz -scale 0 -landmarks-to-spheres $image_folder/Case1_lm_us.txt 1 -o $image_folder/Case1-US-landmarks.nii.gz

# Perform non linear registration
./deedsBCV -F $image_folder/Case1-MRI_in_US.nii.gz -M $image_folder/Case1-US.nii.gz -O $image_folder/Case1-deeds -S $image_folder/Case1-US-landmarks.nii.gz -A $image_folder/affine1_matrix.txt

# Calculate mTRE
python3 ./landmarks_centre_mass.py --inputnii $image_folder/Case1-MRI-landmarks.nii.gz --movingnii $image_folder/Case1-deeds_deformed_seg.nii.gz --savetxt $image_folder/Case1-results
