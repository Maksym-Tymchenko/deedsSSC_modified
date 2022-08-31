import nibabel as nib

nii_us_orig = nib.load('bucket/RESECT/RESECT/NIFTI/Case1/US/Case1-US-before.nii.gz')
nii_cropped_MRI = nib.load('bucket/RESECT/RESECT/NIFTI/Case7/output/deeds/Case7-MRI_in_US.nii.gz')
#nii_mri_orig = nib.load('bucket/RESECT/RESECT/NIFTI/Case2/MRI/Case2-FLAIR.nii.gz')
#nii_us = nib.load('bucket/RESECT/RESECT/NIFTI/Case2/output/Case2-US_nifty.nii')
#nii_mri = nib.load('bucket/RESECT/RESECT/NIFTI/Case2/output/Case2-MRI_in_US_nifty.nii')

#nii = nib.load('bucket/RESECT/RESECT/NIFTI/Case1/MRI/Case1-FLAIR.nii.gz')

image = nii_cropped_MRI

print(image.header)
sx, sy, sz = image.header.get_zooms()
volume = sx * sy * sz

print(f"sx:{sx} sy:{sy} sz:{sz}")

## print(image.affine)
