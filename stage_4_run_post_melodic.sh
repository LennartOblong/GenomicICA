#!/bin/bash
#SBATCH -N 1
#SBATCH -t 01:00:00
#SBATCH --mem=5G


#Takes in the melodic_oIC.nii.gz file, or the melodic_pca.nii.gz file, which is a 4D volume of all components and the output of MELODIC
#and outputs text files with SNP IC/PC betas in vectors (Note, the melodic_mix matrixs containes the loadings for the IDPs)
#Each text file contains the SNP-loadings for a single IC or PC and can be used for further analysis. Note that the PCs are in reverse order (due to MELODIC version)

#Always check directories

#The wrapper script will submit these commands as jobs to a cluster. It will define sample, dim and meth (short for method, oIC or pca) variables.

sample=$1
dim=$2
meth=$3				##### set method to "melodic_oIC" for ica post melodic and to "melodic_pca" for pca post melodic in submit script - use "mean" to look at the grand mean across all ICs#######

indir=/path/to/melodic_oIC.nii.gz
outdir=/path/to/out
variant_base_file=/path/to/variantfile/with/clumpmask.txt #The clumpmask is a txt file that contains rsIDs, BP, A1, A2 and, crucially in the last column, a mask (0 or 1) denoting if the SNP is included post-clumping

output_fname=${meth}-SNPs

mkdir ${outdir}/scripts/ica/TMPdir_${meth}_${sample}_${dim}
cd ${outdir}/scripts/ica/TMPdir_${meth}_${sample}_${dim}

n_ic=$(fslinfo $indir/ica_Z_${dim}_${sample}/${meth}.nii.gz |awk '$1=="dim4"{print $2}')

fslsplit $indir/ica_Z_${dim}_${sample}/${meth}.nii.gz split_tmp -t

for ((i=1;i<=n_ic;i++));do

	fsl2ascii split_tmp$(printf "%04d" $((i-1)) ) split_tmp$(printf "%04d" $((i-1)) )"_ascii"

	cat split_tmp$(printf "%04d" $((i-1)) )"_ascii00000"|tr "\n" " "|sed 's/   / /g'|sed 's/  / /g'|sed 's/ /\n/g'> split_tmp$(printf "%04d" $((i-1)) )"_ascii"

	#only keep the in-mask SNPs in the output text
	paste -d" " $variant_base_file split_tmp$(printf "%04d" $((i-1)) )"_ascii"| awk '$6==1{print $7}' > ${outdir}/${sample}-oics/${output_fname}_${dim}_$i
	rm split_tmp$(printf "%04d" $((i-1)) )"_ascii" split_tmp$(printf "%04d" $((i-1)) )"_ascii00000" split_tmp$(printf "%04d" $((i-1)) )".nii.gz"

done

rm -d ${outdir}/scripts/ica/TMPdir_${meth}_${sample}_${dim}

