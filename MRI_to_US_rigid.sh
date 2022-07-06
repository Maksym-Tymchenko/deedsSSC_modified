#!/bin/sh

# Input arguments

case_num=${1-"1"}
image_folder=${2:-"bucket/RESECT/RESECT/NIFTI/Case${case_num}"}
us_image=${3:-"US/Case${case_num}-US-before.nii.gz"}
mri_image=${4:-"MRI/Case${case_num}-FLAIR.nii.gz"}
tag_file=${5:-"Landmarks/Case${case_num}-MRI-beforeUS.tag"}

# Create directory to store the outputs
mkdir -p $image_folder/output

# Resample images into a common reference frame and isotropic voxel size of 0.5x0.5x0.5 mm
c3d $image_folder/$us_image $image_folder/$mri_image -reslice-identity -resample-mm 0.5x0.5x0.5mm -o $image_folder/output/Case${case_num}-MRI_in_US.nii.gz
c3d $image_folder/$us_image -resample-mm 0.5x0.5x0.5mm -o $image_folder/output/Case${case_num}-US.nii.gz

# Apply linear rigid pre-registration
./linearBCV -F $image_folder/output/Case${case_num}-US.nii.gz -M $image_folder/output/Case${case_num}-MRI_in_US.nii.gz -R 1 -O $image_folder/output/affine${case_num}


# Apply the esitmated linear transform
c3d $image_folder/output/Case${case_num}-US.nii.gz $image_folder/output/Case${case_num}-MRI_in_US.nii.gz -reslice-itk $image_folder/output/affine${case_num}_matrix.txt -o output_image.nii


./applyBCV -M $image_folder/output/Case${case_num}-MRI_in_US.nii.gz -O nonlinear_2_4 -D second_warp.nii.gz -A $image_folder/output/affine${case_num}_matrix.txt
