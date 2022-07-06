#!/bin/sh

# Input arguments

case_num=${1-"01"}
# image_folder=${2:-"bucket/BITE_group4/${case_num}/3D"}
image_folder=${2:-"bucket/BITE_group2/${case_num}"}

us_image_uncompressed="US3DT.nii"
mri_image_uncompressed="MR.nii"

us_image="US3DT.nii.gz"
mri_image="MR.nii.gz"
tag_file="${case_num}_all.tag"

# Create directory to store the outputs
mkdir -p $image_folder/output

# Compress images to match format expected by deedsBCV
gzip -f --keep $image_folder/$us_image_uncompressed
gzip -f --keep $image_folder/$mri_image_uncompressed

# Resample images into a common reference frame and isotropic voxel size of 0.5x0.5x0.5 mm
c3d $image_folder/$us_image $image_folder/$mri_image -reslice-identity -resample-mm 0.5x0.5x0.5mm -o $image_folder/output/Case${case_num}-MRI_in_US.nii.gz
c3d $image_folder/$us_image -resample-mm 0.5x0.5x0.5mm -o $image_folder/output/Case${case_num}-US.nii.gz


# Generate 2 text files containing landmarks
python3 ./landmarks_split_txt.py --inputtag $image_folder/$tag_file --savetxt $image_folder/output/Case${case_num}_lm

# Generate landmark segmentations as a NIFTI file
c3d $image_folder/output/Case${case_num}-MRI_in_US.nii.gz -scale 0 -landmarks-to-spheres $image_folder/output/Case${case_num}_lm_mri.txt 1 -o $image_folder/output/Case${case_num}-MRI-landmarks.nii.gz
c3d $image_folder/output/Case${case_num}-US.nii.gz -scale 0 -landmarks-to-spheres $image_folder/output/Case${case_num}_lm_us.txt 1 -o $image_folder/output/Case${case_num}-US-landmarks.nii.gz

# Apply linear rigid pre-registration
./linearBCV -F $image_folder/output/Case${case_num}-US.nii.gz -M $image_folder/output/Case${case_num}-MRI_in_US.nii.gz -R 1 -O $image_folder/output/affine${case_num}

# Perform non linear registration
./deedsBCV -F $image_folder/output/Case${case_num}-US.nii.gz -M $image_folder/output/Case${case_num}-MRI_in_US.nii.gz -O $image_folder/output/Case${case_num}-deeds -S $image_folder/output/Case${case_num}-MRI-landmarks.nii.gz -A $image_folder/output/affine${case_num}_matrix.txt

# Calculate mTRE
python3 ./landmarks_centre_mass.py --inputnii $image_folder/output/Case${case_num}-US-landmarks.nii.gz --movingnii $image_folder/output/Case${case_num}-MRI-landmarks.nii.gz --savetxt $image_folder/output/Case${case_num}-results

python3 ./landmarks_centre_mass.py --inputnii $image_folder/output/Case${case_num}-US-landmarks.nii.gz --movingnii $image_folder/output/Case${case_num}-deeds_deformed_seg.nii.gz --savetxt $image_folder/output/Case${case_num}-results

