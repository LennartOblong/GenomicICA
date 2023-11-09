#!/bin/bash
#SBATCH -N 1
#SBATCH -t 48:00:00
#SBATCH --mem=100G


#retreives UKB summary statistics from https://open.win.ox.ac.uk/ukbiobank/big40 and converts to nifti-1 file format

#modify the FSLDIR or load FSL module available on system
FSLDIR=/path/to/tools/fsl
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH

# declare parallel, modify the path for your cluster
parallel=/path/to/parallel

#Optimally this script is submitted multiple times, each time with a different list of e.g. 24 IDPs,
#so the process is parallelized as much as possible
#Alternatively, just put all IDP codes (thousands) in a single text file and pass as an argument. But this will only be run in a single node

pheno_list_24=$1
# wrap steps into a function so all cores are kept occupied
function ukbb_downloader {
        pheno=$1

        wget -q https://open.win.ox.ac.uk/ukbiobank/big40/release2/stats33k/${pheno}.txt.gz -O ${pheno}-33k.txt.gz
        wget -q https://open.win.ox.ac.uk/ukbiobank/big40/release2/stats/${pheno}.txt.gz -O ${pheno}-22k.txt.gz
        wget -q https://open.win.ox.ac.uk/ukbiobank/big40/release2/repro/${pheno}.txt.gz -O ${pheno}-11k.txt.gz

        gunzip ${pheno}-33k.txt.gz
        gunzip ${pheno}-22k.txt.gz
        gunzip ${pheno}-11k.txt.gz

        cat ${pheno}-33k.txt |awk 'NR>1 {print $6}' > temp_${pheno}_beta_33k.txt
        cat ${pheno}-33k.txt |awk 'NR>1 {print $8}' > temp_${pheno}_logp_33k.txt

        cat ${pheno}-22k.txt |awk 'NR>1 {print $6}' > temp_${pheno}_beta_22k.txt
        cat ${pheno}-22k.txt |awk 'NR>1 {print $8}' > temp_${pheno}_logp_22k.txt

        cat ${pheno}-11k.txt |awk 'NR>1 {print $6}' > temp_${pheno}_beta_11k.txt
        cat ${pheno}-11k.txt |awk 'NR>1 {print $8}' > temp_${pheno}_logp_11k.txt

        fslascii2img  temp_${pheno}_beta_33k.txt 10223 239 7 1 1 1 1 1  nifti/big_33k_beta_${pheno}
        fslascii2img  temp_${pheno}_logp_33k.txt 10223 239 7 1 1 1 1 1  nifti/big_33k_logp_${pheno}

        fslascii2img  temp_${pheno}_beta_22k.txt 10223 239 7 1 1 1 1 1  nifti/big_22k_beta_${pheno}
        fslascii2img  temp_${pheno}_logp_22k.txt 10223 239 7 1 1 1 1 1  nifti/big_22k_logp_${pheno}

        fslascii2img  temp_${pheno}_beta_11k.txt 10223 239 7 1 1 1 1 1  nifti/big_11k_beta_${pheno}
        fslascii2img  temp_${pheno}_logp_11k.txt 10223 239 7 1 1 1 1 1  nifti/big_11k_logp_${pheno}

        rm temp_${pheno}_beta_33k.txt temp_${pheno}_logp_33k.txt ${pheno}-33k.txt
        rm temp_${pheno}_beta_22k.txt ${pheno}-22k.txt #temp_${pheno}_logp_22k.txt
        rm temp_${pheno}_beta_11k.txt ${pheno}-11k.txt #temp_${pheno}_logp_11k.txt
        }

# export the function to the environment so that parallel can access it outside the bash script
export -f ukbb_downloader


# run the function in parallel. Change number of parallel jobs with --jobs N depending on how many cores/threads the CPU has
# "-a file " takes a text file as input and every line is a argument
# parallel will keep a number of jobs (--jobs N) running and start new ones when the older ones are finished

cat $pheno_list_24 | $parallel --jobs 12 ukbb_downloader {1}

###alternative to the above, cat over list and submit multiple times. Less efficient but functional if parallel not available###
#define pheno_list for all phenotypes
#adapt script for your pathing structure and for 22k and 33k samples if desired.

for i in $(cat ${pheno_list}); do
file=/path/to/nifti/big_11k_beta_${i}.nii.gz
	if [ -f $file ]; then
		echo "11k-big-IDP${idp} file exists. No action required."
	else
		wget -q https://open.win.ox.ac.uk/ukbiobank/big40/release2/repro/${i}.txt.gz -O ${i}-11k.txt.gz
        	gunzip ${i}-11k.txt.gz

	        cat ${i}-11k.txt |awk 'NR>1 {print $6}' > temp_${i}_beta_11k.txt

        	fslascii2img  temp_${i}_beta_11k.txt 10223 239 7 1 1 1 1 1  nifti/big_11k_beta_${i}

	        rm temp_${i}_beta_11k.txt ${i}-11k.txt
	fi
done

#function below to extratc the standard error of the sumstats, needed to generate the z-transformerd sumstats later
function ukbb_downloader {
        pheno=$1

	if [ ! -f nifti/big_33k_SE_${pheno}.nii.gz ] ; then
         wget -q https://open.win.ox.ac.uk/ukbiobank/big40/release2/stats33k/${pheno}.txt.gz -O ${pheno}-33k.txt.gz
         zcat ${pheno}-33k.txt | awk 'NR>1 {print $7}' > temp_${pheno}_SE_33k.txt
         rm ${pheno}-33k.txt.gz
	fi

	if [ ! -f nifti/big_22k_SE_${pheno}.nii.gz ] ; then
         wget -q https://open.win.ox.ac.uk/ukbiobank/big40/release2/stats/${pheno}.txt.gz -O ${pheno}-22k.txt.gz
	 zcat ${pheno}-22k.txt | awk 'NR>1 {print $7}' > temp_${pheno}_SE_22k.txt
  	 rm ${pheno}-22k.txt.gz
	fi

	if [ ! -f nifti/big_11k_SE_${pheno} ]; then
         wget -q https://open.win.ox.ac.uk/ukbiobank/big40/release2/repro/${pheno}.txt.gz -O ${pheno}-11k.txt.gz
	 zcat ${pheno}-11k.txt | awk 'NR>1 {print $7}' > temp_${pheno}_SE_11k.txt
	 rm ${pheno}-11k.txt.gz
        else echo "$pheno 11k was already processed"
	 fi

#Integer factorization: 17103079 SNPs total = 10223*239*7
#This is a fast and arbitrary workaround to encode the 1D SNP vector in a 3D volumetric file, 
#since NIFTI-1 doesn't support any dimension with more than 32k voxels
#CIFTI and NIFTI-2 can handle that, but MELODIC predates these formats

	if [ ! -f nifti/big_33k_SE_${pheno}.nii.gz ] ; then
	 fslascii2img  temp_${pheno}_SE_33k.txt 10223 239 7 1 1 1 1 1  nifti/big_33k_SE_${pheno}
         rm temp_${pheno}_SE_33k.txt
	fi

	if [ ! -f nifti/big_22k_SE_${pheno}.nii.gz ] ; then 
  	 fslascii2img  temp_${pheno}_SE_22k.txt 10223 239 7 1 1 1 1 1  nifti/big_22k_SE_${pheno}
         rm temp_${pheno}_SE_22k.txt
	fi

        if [ ! -f nifti/nifti/big_11k_SE_${pheno} ]; then
	 fslascii2img  temp_${pheno}_SE_11k.txt 10223 239 7 1 1 1 1 1  nifti/big_11k_SE_${pheno}
         rm temp_${pheno}_SE_11k.txt
	fi

     }

export -f ukbb_downloader

cat $pheno_list_24 | $parallel --jobs 12 ukbb_downloader {1}

