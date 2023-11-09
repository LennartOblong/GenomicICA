#!/bin/bash
#script to submit melodic function per dimensionality and function as seperate jobs.
cd /current/direcotry

source ~/.bashrc

for i in 11k 22k 33k #tailored to present naming convention for samples
do
	for dim in 10 #can be any dimensionality (e.g. 5, 25, 50)
	do

	sbatch $PWD/stage_3_run_melodic.sh ${i} ${dim}

 	done
done











