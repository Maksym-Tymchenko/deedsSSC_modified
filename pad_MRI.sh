image_folder="bucket/US_collection"
us_image="$image_folder/lateral_short_scalar_aligned.nii.gz"
mri_image="$image_folder/MRI_cube_Case7_aligned.nii.gz"

# Create directory to store the outputs
mkdir -p $image_folder/output/deeds

output_folder="$image_folder/output/deeds"

c3d $output_folder/MRI_in_US.nii.gz -pad 10x10x10 10x10x10 0 -o $output_folder/MRI_in_US.nii.gz
c3d $output_folder/US.nii.gz -pad 1x1x1 1x1x1 0 -o $output_folder/US.nii.gz