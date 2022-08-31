#!/bin/sh

# Input arguments

case_num=${1-"1"}
image_folder=${2:-"bucket/RESECT/RESECT/NIFTI/Case${case_num}"}
us_image=${3:-"$image_folder/US/Case${case_num}-US-after.nii.gz"}
mri_image=${4:-"$image_folder/MRI/Case${case_num}-FLAIR.nii.gz"}
tag_file=${5:-"$image_folder/Landmarks/Case${case_num}-MRI-afterUS.tag"}

# Create directory to store the outputs
mkdir -p $image_folder/output/deeds

output_folder="$image_folder/output/deeds/after"

vox_size=0.5

# Resample images into a common reference frame and isotropic voxel size of 0.5x0.5x0.5 mm
c3d $us_image $mri_image -reslice-identity -resample-mm ${vox_size}x${vox_size}x${vox_size}mm -o $output_folder/Case${case_num}-MRI_in_US.nii.gz
c3d $us_image -resample-mm ${vox_size}x${vox_size}x${vox_size}mm -o $output_folder/Case${case_num}-US.nii.gz


# Add a black frame of 1 voxel around the MRI and US as a workaround for artifacts
c3d $output_folder/Case${case_num}-MRI_in_US.nii.gz -pad 1x1x1 1x1x1 0 -o $output_folder/Case${case_num}-MRI_in_US.nii.gz
c3d $output_folder/Case${case_num}-US.nii.gz -pad 1x1x1 1x1x1 0 -o $output_folder/Case${case_num}-US.nii.gz

# Generate 2 text files containing landmarks
python3 ./landmarks_split_txt.py --inputtag $tag_file --savetxt $output_folder/Case${case_num}_lm

# Generate landmark segmentations as a NIFTI file
c3d $output_folder/Case${case_num}-MRI_in_US.nii.gz -scale 0 -landmarks-to-spheres $output_folder/Case${case_num}_lm_mri.txt 1 -o $output_folder/Case${case_num}-MRI-landmarks.nii.gz
c3d $output_folder/Case${case_num}-US.nii.gz -scale 0 -landmarks-to-spheres $output_folder/Case${case_num}_lm_us.txt 1 -o $output_folder/Case${case_num}-US-landmarks.nii.gz

# Calculate mTRE
python3 ./landmarks_centre_mass.py \
--inputnii $output_folder/Case${case_num}-US-landmarks.nii.gz \
--movingnii $output_folder/Case${case_num}-MRI-landmarks.nii.gz \
--savetxt $output_folder/Case${case_num}-results

# Remove unnecessary files
rm $output_folder/mask_US.nii.gz
rm $output_folder/Case${case_num}_lm*
rm $output_folder/Case${case_num}-results*