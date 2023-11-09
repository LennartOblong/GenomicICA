# Description
GenomicICA code repository
Contains the code to reproduce the results presented in our published preprint "Principal and Independent Genomic Components of Brain Structure and Function" by Oblong et al., 2023.
This includes the software implementation of the FSL MELODIC algorithm v3.15 (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MELODIC) on genetic data.
Please cite our work when implementing genomic ICA in your own work. https://www.biorxiv.org/content/10.1101/2022.07.13.499912v2

Herein also contained is the step-by-step reproducibility analysis outlined in our publication.
The code is divided into 6 stages. Following the stages from 1 through 6 will yield the univariate GWAS reproducibiliy benchmark, and the reproducibility of genomic PCA/ICA components in independent samples. For reproducing our work, please follow
the comments in the scripts carefully and pay attention to the "important notes" section below.

    STAGE 1
      UKB data downloader
    STAGE 2 & 2b
      Convert downloaded data into nifti-fileformat to make it usable by MELODIC. Then generate z-transformed sumstats also in nifti-format
    STAGE 3
      Run MELODIC
    STAGE 4
      Post-MELODIC formatting
    STAGE 5
      Calculate univariate GWAS reproducibility per IDP
    STAGE 6
      Calculate reproducibility of genomic PCs and ICs across the 11k and 22k UKB samples

# Acknowledgements
The present code, and the paper referenced above, is an evolution of the previous work by Sourena Soheili-Nezhad, who deserves a lot of credit for developing the first scripts to successfuly run MELODIC on genetic data (it was developed for neuroimaging data).
His code was further developed and expanded to further steps by Emma Sprooten and myself.

# Important Notes
This repository does not contain a plug-and-play code that will immediatley work on any machine. The code provided here is useful for checking the reproducibility of our approach, and shows the implementation of MELODIC on GWAS sumstats.
All the analyses were run on Snellius, using the Slurm cluster management system.
Some of the steps are memory hungry and require a high-performance computing environment.
FSL is necessary to run our analysis pipeline.
