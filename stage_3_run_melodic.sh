#!/bin/bash
#SBATCH -N 1
#SBATCH -p fat
#SBATCH -t 05:00:00
#SBATCH --mem=600G
#$ -cwd

#This script is used for running the MELODIC on the 4D nifti formatted GWAS sumstats

source ~/.bashrc #to export FSLDIR

#Check the absolute path or config FSL based on cluster	
melodic=${FSLDIR}/bin/melodic


#now run MELODIC on the nifti files we generated previously. The present script is called by a wrapper script also named stage_3
#in the wrapper we define i as the sample size. Given that we downloaded and tested the UKBB-samples for 11k, 22k, and 33k sizes, this is our i.
#dim denotes the dimensionality of the decomposition (i.e. the number of components we extract from the data)

#The decomposition can be performed on the raw betas GWAS sumstats or the z-transformed GWAS sumstats

#The clumping mask also must be in nifti-format. You may use the same workaround as previously mentioned.  We clumped the UKB sumstats using plink 1.07 following these parameters:
#Options in effect:
#        --clump-r2 0.1
#        --clump-kb 1000
#        --clump-p1 0.0001
#        --clump-p2 0.0001


i=$1
dim=$2

$melodic -i path/to/sumstats/all_${i}_Z.nii.gz --no_mm --mask=path/to/clumpmask/mask-clump.nii.gz --update_mask --Oall \
         -o /path/to/output/directory/ica_Z_dim${dim}_${i} --keep_meanvol --rescale_nht --vn  -d $dim
