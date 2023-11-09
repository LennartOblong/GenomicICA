#!/bin/bash
#Lennart 12/2022

#This script parallelises the submission of stage 5 per IDP. file is defined to avoid overwriting.
#When running define "param" as either "raw" or "z", depending on your naming convention and path structure

param=$1

#all-pheno.txt contains IDP IDs from 0000 to 2240.
#loop checks if file exists and submits the job to the cluster if it cannot find the output file of the main script.
for idp in $(cat /projects/0/einf2700/oblongl/almanac/all-pheno.txt) ; do
file=path/to/output/${param}-betas/idp-11k-22k-${idp_id}-masked.txt

	if [ -f $file ]; then

		echo "IDP${idp} file exists. No action required."

	else

		sbatch $PWD/stage_5_gwas-idp-corr.sh $idp $param

	fi

done 

