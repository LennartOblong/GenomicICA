#!/bin/bash
#SBATCH -N 1
#SBATCH -t 00:10:00
#SBATCH --mem=5G

#$ -cwd
source ~/.bashrc #export FSL

#Script to compute the IDP-wise correlation of univariate GWAS of SNPs influencing IDPs.  Here 11k vs 22k. Used to create the reproducibility benchmark.
#Takes the z-transformed (and raw) beta values of GWAS summary stats, as well as IDP-IDs as input.
#Wrapper script will define idp_id and parameter (e.g. raw or z-transformed)


#Adapt the directories for variables defined by arguments - defined by wrapper script
idp_id=$1
param=$2

#prepare files - first use fsl2ascii to extract individual IDP sumstats from the raw beta (or z-transformed) nifti-file, then save it to a txt file after processing
for sample in 11k 22k;do
fsl2ascii /${param}-dir/${sample}_idps/big_${sample}_beta_${idp_id}.nii.gz /gwas-betas/${param}-betas/${sample}-idp-${idp_id}-ascii
cat /gwas-betas/${param}-betas/${sample}-idp-${idp_id}-ascii00000 |tr "\n" " "|sed 's/   /\n/g'|sed 's/  /\n/g'|sed 's/ /\n/g' > /gwas-betas/${param}-betas/${sample}-idp-${idp_id}.txt

#combine variant clump mask with the txt file, and extract the SNPs that remained post-clumping (mask contained in 6th column of mask file)
paste /almanac/variants-clump-mask.txt /gwas-betas/${param}-betas/${sample}-idp-${idp_id}.txt |awk '$6==1{print $7}' > /gwas-betas/${param}-betas/${sample}-idp-${idp_id}-masked.txt
rm /gwas-betas/${param}-betas/${sample}-idp-${idp_id}-ascii00000 /gwas-betas/${param}-betas/${sample}-idp-${idp_id}.txt 
done

#once done for both IDPs in 11k and 22k sample, combine txt files
paste -d "," /gwas-betas/${param}-betas/11k-idp-${idp_id}-masked.txt /gwas-betas/${param}-betas/22k-idp-${idp_id}-masked.txt > /gwas-betas/${param}-betas/idp-11k-22k-${idp_id}-masked.txt

rm /gwas-betas/${param}-betas/11k-idp-${idp_id}-masked.txt /gwas-betas/${param}-betas/22k-idp-${idp_id}-masked.txt

#call R script to perform calculation on IDP file combining 11k and 22k sample GWAS sumstats. Outputs file containing correlation for each IDP.
module load 2021
module load R/4.1.0-foss-2021a
Rscript /run-gwas-idp-corr.R /gwas-betas/${param}-betas/idp-11k-22k-${idp_id}-masked.txt /gwas-betas/${param}-betas/idp-11k-22k-${idp_id}-corr.txt ${idp_id}

rm /projects/0/einf2700/oblongl/inter-sample-reproc/univariate_GWAS/${param}-betas/idp-11k-22k-${idp_id}-masked.txt
