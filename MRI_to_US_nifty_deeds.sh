#!/bin/sh

# Input arguments

case_num=${1-"1"}
image_folder=${2:-"bucket/RESECT/RESECT/NIFTI/Case${case_num}"}
us_image=${3:-"$image_folder/US/Case${case_num}-US-before.nii.gz"}
mri_image=${4:-"$image_folder/MRI/Case${case_num}-FLAIR.nii.gz"}
tag_file=${5:-"$image_folder/Landmarks/Case${case_num}-MRI-beforeUS.tag"}

# Create directory to store the outputs
mkdir -p $image_folder/output/deeds

output_folder="$image_folder/output/deeds"

vox_size=0.5

# Resample images into a common reference frame and isotropic voxel size of 0.5x0.5x0.5 mm
c3d $us_image $mri_image -reslice-identity -resample-mm ${vox_size}x${vox_size}x${vox_size}mm -o $output_folder/Case${case_num}-MRI_in_US.nii.gz
c3d $us_image -resample-mm ${vox_size}x${vox_size}x${vox_size}mm -o $output_folder/Case${case_num}-US.nii.gz

# Extract US background (pixels with 0 intensity exactly)
c3d $output_folder/Case${case_num}-US.nii.gz -threshold 0 0 0 1 -o $output_folder/mask_US.nii.gz

#c3d $output_folder/Case${case_num}-US.nii.gz -threshold 0 0 1 0 -o $output_folder/mask_US_opposite.nii.gz

 # Perform affine registration step
reg_aladin -ref $output_folder/Case${case_num}-US.nii.gz \
-flo $output_folder/Case${case_num}-MRI_in_US.nii.gz \
-res $output_folder/Case${case_num}-MRI_to_US_result_rigid.nii.gz \
-rmask $output_folder/mask_US.nii.gz \
-fmask $output_folder/mask_US.nii.gz \
-aff $output_folder/affine_matrix.txt -rigOnly


# Generate 2 text files containing landmarks
python3 ./landmarks_split_txt.py --inputtag $tag_file --savetxt $output_folder/Case${case_num}_lm

# Generate landmark segmentations as a NIFTI file
c3d $output_folder/Case${case_num}-MRI_in_US.nii.gz -scale 0 -landmarks-to-spheres $output_folder/Case${case_num}_lm_mri.txt 1 -o $output_folder/Case${case_num}-MRI-landmarks.nii.gz
c3d $output_folder/Case${case_num}-US.nii.gz -scale 0 -landmarks-to-spheres $output_folder/Case${case_num}_lm_us.txt 1 -o $output_folder/Case${case_num}-US-landmarks.nii.gz


# Apply linear preregistration to landmarks
python3 ./generate_zero_displacements.py $output_folder $output_folder/Case${case_num}-MRI_in_US.nii.gz

./applyBCV -M $output_folder/Case${case_num}-MRI-landmarks.nii.gz \
-O $output_folder/zero \
-D $output_folder/Case${case_num}-MRI-landmarks_linear.nii.gz \
-A $output_folder/affine_matrix.txt


 ./applyBCV -M $output_folder/Case${case_num}-MRI_in_US.nii.gz \
 -O $output_folder/zero \
 -D $output_folder/Case${case_num}-MRI_in_US_linear.nii.gz \
 -A $output_folder/affine_matrix.txt


# Perform non linear registration
./deedsBCV -F $output_folder/Case${case_num}-US.nii.gz \
-M $output_folder/Case${case_num}-MRI_in_US.nii.gz \
-O $output_folder/Case${case_num}-deeds \
-S $output_folder/Case${case_num}-MRI-landmarks.nii.gz \
-A $output_folder/affine_matrix.txt \
-a 0.4 # make a smoother but less accurate registration

# Remove background from MRI
c3d $output_folder/Case${case_num}-deeds_deformed.nii.gz $output_folder/mask_US.nii.gz -multiply -o $output_folder/clean_MRI.nii.gz



# Calculate mTRE
python3 ./landmarks_centre_mass.py \
--inputnii $output_folder/Case${case_num}-US-landmarks.nii.gz \
--movingnii $output_folder/Case${case_num}-deeds_deformed_seg.nii.gz \
--savetxt $output_folder/Case${case_num}-results

# Remove unnecessary files
rm $output_folder/mask_US.nii.gz
rm $output_folder/Case${case_num}_lm*
rm $output_folder/Case${case_num}-results*