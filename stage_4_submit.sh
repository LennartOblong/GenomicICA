#!/bin/bash
#Lennart, 2022
#Script to submit post_melodic script to the cluster for 

source /home/oblongl/.bash_profile
source /home/oblongl/.bashrc

for k in 11k 22k 33k #samples that you wish to process
do
        for dim in dim10 #can be any dimensionality previously decomposed (e.g. dim05, dim-05, dim-10, etc.)
        do
		for meth in mean melodic_pca melodic_oIC #method according to the MELODIC naming convention. Submits the mean, the pPCA and meldoicICA for post-processing
		do

		sbatch $PWD/stage_4_run_post_melodic.sh ${k} ${dim} ${meth}

		done
	done
done
