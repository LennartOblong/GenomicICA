#!/bin/bash
#SBATCH -N 1
#SBATCH --partition=fat
#SBATCH -t 01:00:00
#SBATCH --mem=500G


#after downloading and converting betas/pvals into 3D NIFTI volumes this code merges them into a 4D nifti which is necessary for MELODIC
#The list of all IDPs are read from an all-pheno.txt file which contains the IDP IDs (e.g. 0001, 0002, etc)
#This step is memory-hungry with thousands of IDPs, so need to be run on the big memory node

#This step uses the FSL toolbox (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki) so make sure to have it installed

source ~/.bashrc #or your your preffered method to export fsl


fslmerge -t all-33k-beta $(cat all-pheno.txt |while read s;do echo -en "33k/big_33k_beta_${s} ";done)
fslmerge -t all-33k-logp $(cat all-pheno.txt |while read s;do echo -en "33k/big_33k_logp_${s} ";done)

fslmerge -t all-22k-beta $(cat all-pheno.txt |while read s;do echo -en "22k/big_22k_beta_${s} ";done)
fslmerge -t all-11k-beta $(cat all-pheno.txt |while read s;do echo -en "11k/big_11k_beta_${s} ";done)

