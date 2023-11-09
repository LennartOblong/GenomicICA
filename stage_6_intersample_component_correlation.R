# Lennart Oblong - 11.2022
# Script to compute the cross-correlation for the ICs/PCs
# Here we compute the similarity index of the decomposition done on different samples from UKB, to determine which decomposition is most reproducable (i.e. if we find similar information decomposed 
# within the different samples or if one sample stands out). Compare 11k and 22k since they are independent. 33k includes both, but can also be tested if needed.
# The below script performs the correlation analysis across all dimensionalities up to 50, and for components derived from z-transformed and raw sumstats. It is called by the wrapper script
# of the same stage to call each dimension

# Please adjust all directories and filenames according to your decomposition and pathing setup

require(readr)
require(dplyr)
require(tidyr)
require(purrr)
require(nlme)
require(lme4)
require(proxy)
require(gtools)

args <- commandArgs(trailingOnly = TRUE) 

#the script can be passed for any dimension that was previously decomposed using the melodic step. Note that, in the present naming convention, names with a "-" (e.g. dim-50) call the components derived
#from raw sumstats, while those without call those from z-transformed sumstats.
decomp <- args[1]

n <- ifelse((decomp == "dim-50"), 50,
	+ ifelse((decomp == "dim50"), 50,
	+ ifelse((decomp == "dim-25"), 25,
	+ ifelse((decomp == "dim25"), 25,
	+ ifelse((decomp == "dim10"), 10,
	+ ifelse((decomp == "dim-10"), 10,
	+ ifelse((decomp == "dim5_"), 5,
	+ ifelse((decomp == "dim-5_"), 5))))))))

indir <- paste0("/path/to/zgenICA")		
indir2 <- paste0("/path/to/rawgenICA")
outdir <- paste0("/path/to/outdir/", decomp) 

#get data
#Note that in the presently used MELODIC version, the PCA components in the output are ordered in reverse, which is why they are re-sorted in decreasing order here.
#Further, the PCA decompositions between dim5 and dim50 do not differ, as experience has shown that the PCs are the same. Thus, the largest dim50 PCA output is sufficient to extract all PCs for the 
#dimensions below.
        if (decomp == "dim-50") { filenames_22k_ica <- list.files(path = indir2, pattern = paste0("ica-22k-", decomp, "\\s*(.*?)\\s*"), full.names = TRUE)
                                filenames_22k_ica <- mixedsort(sort(filenames_22k_ica))
                                filenames_11k_ica <- list.files(path = indir2, pattern = paste0("ica-11k-", decomp, "\\s*(.*?)\\s*"), full.names = TRUE)
                                filenames_11k_ica <- mixedsort(sort(filenames_11k_ica))
                                filenames_22k_pca <- list.files(path = indir2, pattern = paste0("ica-22k-dim-50", "\\s*(.*?)\\s*-pca"), full.names = TRUE)
                                filenames_22k_pca <- mixedsort(sort(filenames_22k_pca),decreasing=TRUE)
                                filenames_11k_pca <- list.files(path = indir2, pattern = paste0("ica-11k-dim-50", "\\s*(.*?)\\s*-pca"), full.names = TRUE)
                                filenames_11k_pca <- mixedsort(sort(filenames_11k_pca),decreasing=TRUE)
				if (n == 50) {
                                        filenames_22k_ica <- filenames_22k_ica[c(TRUE, FALSE)]
                                        filenames_11k_ica <- filenames_11k_ica[c(TRUE, FALSE)]
                                        }
        } else if (decomp == "dim50") { filenames_22k_ica <- list.files(path = paste0(indir,"/22k-oics"), pattern = paste0("oIC\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_22k_ica <- mixedsort(sort(filenames_22k_ica))
                                filenames_11k_ica <- list.files(path = paste0(indir,"/11k-oics"), pattern = paste0("oIC\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_11k_ica <- mixedsort(sort(filenames_11k_ica))
                                filenames_22k_pca <- list.files(path = paste0(indir,"/22k-oics"), pattern = paste0("pca\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_22k_pca <- mixedsort(sort(filenames_22k_pca),decreasing=TRUE)
                                filenames_11k_pca <- list.files(path = paste0(indir,"/11k-oics"), pattern = paste0("pca\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_11k_pca <- mixedsort(sort(filenames_11k_pca),decreasing=TRUE)
        } else if (decomp == "dim-25") { filenames_22k_ica <- list.files(path = indir2, pattern = paste0("ica-22k-", decomp, "\\s*(.*?)\\s*"), full.names = TRUE)
                                filenames_22k_ica <- mixedsort(sort(filenames_22k_ica))
                                filenames_11k_ica <- list.files(path = indir2, pattern = paste0("ica-11k-", decomp, "\\s*(.*?)\\s*"), full.names = TRUE)
                                filenames_11k_ica <- mixedsort(sort(filenames_11k_ica))
                                filenames_22k_pca <- list.files(path = indir2, pattern = paste0("ica-22k-dim-50", "\\s*(.*?)\\s*-pca"), full.names = TRUE)
                                filenames_22k_pca <- mixedsort(sort(filenames_22k_pca),decreasing=TRUE)
                                filenames_11k_pca <- list.files(path = indir2, pattern = paste0("ica-11k-dim-50", "\\s*(.*?)\\s*-pca"), full.names = TRUE)
                                filenames_11k_pca <- mixedsort(sort(filenames_11k_pca),decreasing=TRUE)
                                if (n < 50) {
                                        filenames_22k_pca <- filenames_22k_pca[1:n]
                                        filenames_11k_pca <- filenames_11k_pca[1:n]
                                        }
        } else if (decomp == "dim25") { filenames_22k_ica <- list.files(path = paste0(indir,"/22k-oics"), pattern = paste0("oIC\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_22k_ica <- mixedsort(sort(filenames_22k_ica))
                                filenames_11k_ica <- list.files(path = paste0(indir,"/11k-oics"), pattern = paste0("oIC\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_11k_ica <- mixedsort(sort(filenames_11k_ica))
                                filenames_22k_pca <- list.files(path = paste0(indir,"/22k-oics"), pattern = paste0("pca\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_22k_pca <- mixedsort(sort(filenames_22k_pca),decreasing=TRUE)
                                filenames_11k_pca <- list.files(path = paste0(indir,"/11k-oics"), pattern = paste0("pca\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_11k_pca <- mixedsort(sort(filenames_11k_pca),decreasing=TRUE)
        } else if (decomp == "dim-10") { filenames_22k_ica <- list.files(path = indir2, pattern = paste0("ica-22k-", decomp, "\\s*(.*?)\\s*"), full.names = TRUE)
                                filenames_22k_ica <- mixedsort(sort(filenames_22k_ica))
                                filenames_11k_ica <- list.files(path = indir2, pattern = paste0("ica-11k-", decomp, "\\s*(.*?)\\s*"), full.names = TRUE)
                                filenames_11k_ica <- mixedsort(sort(filenames_11k_ica))
                                filenames_22k_pca <- list.files(path = indir2, pattern = paste0("ica-22k-dim-50", "\\s*(.*?)\\s*-pca"), full.names = TRUE)
                                filenames_22k_pca <- mixedsort(sort(filenames_22k_pca),decreasing=TRUE)
                                filenames_11k_pca <- list.files(path = indir2, pattern = paste0("ica-11k-dim-50", "\\s*(.*?)\\s*-pca"), full.names = TRUE)
                                filenames_11k_pca <- mixedsort(sort(filenames_11k_pca),decreasing=TRUE)
                                if (n < 50) {
                                        filenames_22k_pca <- filenames_22k_pca[1:n]
                                        filenames_11k_pca <- filenames_11k_pca[1:n]
                                        }
        } else if (decomp == "dim10") { filenames_22k_ica <- list.files(path = paste0(indir,"/22k-oics"), pattern = paste0("oIC\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_22k_ica <- mixedsort(sort(filenames_22k_ica))
                                filenames_11k_ica <- list.files(path = paste0(indir,"/11k-oics"), pattern = paste0("oIC\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_11k_ica <- mixedsort(sort(filenames_11k_ica))
                                filenames_22k_pca <- list.files(path = paste0(indir,"/22k-oics"), pattern = paste0("pca\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_22k_pca <- mixedsort(sort(filenames_22k_pca),decreasing=TRUE)
                                filenames_11k_pca <- list.files(path = paste0(indir,"/11k-oics"), pattern = paste0("pca\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_11k_pca <- mixedsort(sort(filenames_11k_pca),decreasing=TRUE)
        } else if (decomp == "dim5_") { filenames_22k_ica <- list.files(path = paste0(indir,"/22k-oics"), pattern = paste0("oIC\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_22k_ica <- mixedsort(sort(filenames_22k_ica))
                                filenames_11k_ica <- list.files(path = paste0(indir,"/11k-oics"), pattern = paste0("oIC\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_11k_ica <- mixedsort(sort(filenames_11k_ica))
                                filenames_22k_pca <- list.files(path = paste0(indir,"/22k-oics"), pattern = paste0("pca\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_22k_pca <- mixedsort(sort(filenames_22k_pca),decreasing=TRUE)
                                filenames_11k_pca <- list.files(path = paste0(indir,"/11k-oics"), pattern = paste0("pca\\s*(.*?)\\s*",decomp), full.names = TRUE)
                                filenames_11k_pca <- mixedsort(sort(filenames_11k_pca),decreasing=TRUE)
        } else if (decomp == "dim-5_")  { filenames_22k_ica <- list.files(path = indir2, pattern = paste0("ica-22k-", decomp, "\\s*(.*?)\\s*"), full.names = TRUE)
                                filenames_22k_ica <- mixedsort(sort(filenames_22k_ica))
                                filenames_11k_ica <- list.files(path = indir2, pattern = paste0("ica-11k-", decomp, "\\s*(.*?)\\s*"), full.names = TRUE)
                                filenames_11k_ica <- mixedsort(sort(filenames_11k_ica))
                                filenames_22k_pca <- list.files(path = indir2, pattern = paste0("ica-22k-dim-50", "\\s*(.*?)\\s*-pca"), full.names = TRUE)
                                filenames_22k_pca <- mixedsort(sort(filenames_22k_pca),decreasing=TRUE)
                                filenames_11k_pca <- list.files(path = indir2, pattern = paste0("ica-11k-dim-50", "\\s*(.*?)\\s*-pca"), full.names = TRUE)
                                filenames_11k_pca <- mixedsort(sort(filenames_11k_pca),decreasing=TRUE)
                                if (n < 50) {
                                        filenames_22k_pca <- filenames_22k_pca[1:n]
                                        filenames_11k_pca <- filenames_11k_pca[1:n]
                                        }
        } else { print("decomp not defined")
        }

############################################# load data
#22k
ica22 <- as.data.frame(lapply(filenames_22k_ica,function(x){
	  read.csv(x, sep="\t", header=FALSE)
	}))
colnames(ica22) <- c(paste0("IC", 1:n))

pca22 <- as.data.frame(lapply(filenames_22k_pca,function(x){
	  read.csv(x, sep="\t", header=FALSE)
	}))
colnames(pca22) <- c(paste0("PC", 1:n))

#11k
ica11 <- as.data.frame(lapply(filenames_11k_ica,function(x){
	  read.csv(x, sep="\t", header=FALSE)
	}))
colnames(ica11) <- c(paste0("IC", 1:n))

pca11 <- as.data.frame(lapply(filenames_11k_pca,function(x){
	  read.csv(x, sep="\t", header=FALSE)
	}))
colnames(pca11) <- c(paste0("PC", 1:n))

###################################################### binarise IC and PC data with threshold 1 for fisher's test
#22k
ica22_abs <- abs(ica22)
ica22_bin1 <- as.matrix((ica22_abs>1)+0)

pca22_abs <- abs(pca22)
pca22_bin1 <- as.matrix((pca22_abs>1)+0)

#11k
ica11_abs <- abs(ica11)
ica11_bin1 <- as.matrix((ica11_abs>1)+0)
 
pca11_abs <- abs(pca11)
pca11_bin1 <- as.matrix((pca11_abs>1)+0)

##### cross correlations on ica and pca
#ica
ica.est <- matrix(0, nrow=n,ncol=n)
ica.p <- matrix(0, nrow=n,ncol=n)
for ( i in 1:n ) {
  for (j in 1:n) {
        result <- cor.test(ica11[,i] ,ica22[,j], method="pearson", use = "complete.obs")
        ica.p[i,j] <- result$p.value
        ica.est[i,j] <- result$estimate
} }
colnames(ica.p) <- c(paste0("IC", 1:n))
rownames(ica.p) <- c(paste0("IC", 1:n))
colnames(ica.est) <- c(paste0("IC", 1:n))
rownames(ica.est) <- c(paste0("IC", 1:n))
ica.p.adj <- ica.p*(n^2-n/2)

sig_p_adj_ica <- matrix(NA , sum(ica.p.adj < 0.05) , 4)
r <- 1L
for(i in 1:nrow(ica.p.adj)){
  for(j in 1:ncol(ica.p.adj)){
    if(ica.p.adj[i,j] <0.05){
      sig_p_adj_ica[r,1] <- ica.p.adj[i,j]
      sig_p_adj_ica[r,2] <- abs(ica.est[i,j])
      sig_p_adj_ica[r,3] <- rownames(ica.p.adj)[i]
      sig_p_adj_ica[r,4] <- colnames(ica.p.adj)[j]
      r <- r + 1L
    }
  }
}
colnames(sig_p_adj_ica) <- c("p_val_adjusted", "coefficient", "11k_comp", "22k_comp")
sig_p_adj_ica <- as.data.frame(sig_p_adj_ica, quote=FALSE)
sig_p_adj_ica <- sig_p_adj_ica[order(sig_p_adj_ica$p_val_adjusted, decreasing=TRUE),]


#pca
pca.est <- matrix(0, nrow=n,ncol=n)
pca.p <- matrix(0, nrow=n,ncol=n)
for ( i in 1:n ) {
  for (j in 1:n) {
        result <- cor.test(pca11[,i] ,pca22[,j], method="pearson", use = "complete.obs")
        pca.p[i,j] <- result$p.value
        pca.est[i,j] <- result$estimate
} }
colnames(pca.p) <- c(paste0("PC", 1:n))
rownames(pca.p) <- c(paste0("PC", 1:n))
colnames(pca.est) <- c(paste0("PC", 1:n))
rownames(pca.est) <- c(paste0("PC", 1:n))
pca.p.adj <- pca.p*(n^2-n/2)

sig_p_adj_pca <- matrix(NA , sum(pca.p.adj < 0.05) , 4)
r <- 1L
for(i in 1:nrow(pca.p.adj)){
  for(j in 1:ncol(pca.p.adj)){
    if(pca.p.adj[i,j] <0.05){
      sig_p_adj_pca[r,1] <- pca.p.adj[i,j]
      sig_p_adj_pca[r,2] <- pca.est[i,j]
      sig_p_adj_pca[r,3] <- rownames(pca.p.adj)[i]
      sig_p_adj_pca[r,4] <- colnames(pca.p.adj)[j]
      r <- r + 1L
    }
  }
}
colnames(sig_p_adj_pca) <- c("p_val_adjusted", "coefficient", "11k_comp", "22k_comp")
sig_p_adj_pca <- as.data.frame(sig_p_adj_pca, quote=FALSE)
sig_p_adj_pca <- sig_p_adj_pca[order(sig_p_adj_pca$p_val_adjusted,decreasing=TRUE),]

#Fisher's test for non-kurtotic components

p_mat <- matrix(0, nrow=n,ncol=n)
for ( i in 1:n ) {
       for (j in 1:n) {
                if  ( ( dim(table(ica11_bin1[,i]))==2) & ( dim(table(ica22_bin1[,j]))==2) ) {
                test <- fisher.test(table(ica11_bin1[,i] ,ica22_bin1[,j]))
                p_mat[i,j] <- test$p.value

                } else { p_mat[i,j] <- 1
                }
        }
}
colnames(p_mat) <- c(paste0("IC", 1:n))
rownames(p_mat) <- c(paste0("IC", 1:n))
####
p_mat_adj <- p_mat*(n^2-n/2)
####
sig_p_adj_ica <- matrix(NA , sum(p_mat_adj < 0.05) , 3)
r <- 1L
for(i in 1:nrow(p_mat_adj)){
  for(j in 1:ncol(p_mat_adj)){
    if(p_mat_adj[i,j] <0.05){
      sig_p_adj_ica[r,1] <- p_mat_adj[i,j]
      sig_p_adj_ica[r,2] <- rownames(p_mat_adj)[i]
      sig_p_adj_ica[r,3] <- colnames(p_mat_adj)[j]
      r <- r + 1L
    }
  }
}
colnames(sig_p_adj_ica) <- c("p_val_adjusted", "11k_comp", "22k_comp")
sig_p_adj_ica <- as.data.frame(sig_p_adj_ica, quote=FALSE)
sig_p_adj_ica <- sig_p_adj_ica[order(sig_p_adj_ica$p_val_adjusted,decreasing=TRUE),]

p_mat2 <- matrix(0, nrow=n,ncol=n)
for ( i in 1:n ) {
       for (j in 1:n) {
                if  ( ( dim(table(pca11_bin1[,i]))==2) & ( dim(table(pca22_bin1[,j]))==2) ) {
                test2 <- fisher.test(table(pca11_bin1[,i] ,pca22_bin1[,j]))
                p_mat2[i,j] <- test2$p.value
                } else { p_mat2[i,j] <- 1
                }
        }
}
colnames(p_mat2) <- c(paste0("PC", 1:n))
rownames(p_mat2) <- c(paste0("PC", 1:n))
#####
p_mat2_adj <- p_mat2*(n^2-n/2)
#####
sig_p_adj_pca <- matrix(NA , sum(p_mat2_adj < 0.05) , 3)
r <- 1L
for(i in 1:nrow(p_mat2_adj)){
  for(j in 1:ncol(p_mat2_adj)){
    if(p_mat2_adj[i,j] <0.05){
      sig_p_adj_pca[r,1] <- p_mat2_adj[i,j]
      sig_p_adj_pca[r,2] <- rownames(p_mat2_adj)[i]
      sig_p_adj_pca[r,3] <- colnames(p_mat2_adj)[j]
      r <- r + 1L
    }
  }
}
colnames(sig_p_adj_pca) <- c("p_val_adjusted", "11k_comp", "22k_comp")
sig_p_adj_pca <- as.data.frame(sig_p_adj_pca, quote=FALSE)
sig_p_adj_pca <- sig_p_adj_pca[order(sig_p_adj_pca$p_val_adjusted,decreasing=TRUE),]

