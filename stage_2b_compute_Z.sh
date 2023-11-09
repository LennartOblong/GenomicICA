#!/bin/bash
#SBATCH -p fat
#SBATCH -N 1
#SBATCH -t 12:00:00
#SBATCH --mem=600G
 
#This script is to calculate the z-transformed sumstats. Using a scratch directory with bigger memory is recommended.

cwd="desired/output/directory/"

source ~/.bashrc

cd $TMPDIR

cp /path/to/BIG40_downloads/all_33k_SE.nii.gz ./
cp /path/to/BIG40_downloads/all-33k-beta.nii.gz ./
fslmaths all-33k-beta.nii.gz -div all_33k_SE.nii.gz all_22k_Z
cp all_33k_Z.nii.gz $cwd
echo "33k done" >> $cwd/log_2b.txt

# 22k
cp /path/to/BIG40_downloads/all_22k_SE.nii.gz ./
cp /path/to/BIG40_downloads/all-22k-beta.nii.gz ./
fslmaths all-22k-beta.nii.gz -div all_22k_SE.nii.gz all_22k_Z
cp all_22k_Z.nii.gz $cwd
echo "22k done" >> $cwd/log_2b.txt

# 11k
cp /path/to/BIG40_downloads/all_11k_SE.nii.gz ./
cp /path/to/BIG40_downloads/all-11k-beta.nii.gz ./
fslmaths all-11k-beta.nii.gz -div all_11k_SE.nii.gz all_11k_Z
cp all_11k_Z.nii.gz $cwd
echo "11k done" >> $cwd/log_2b.txt




