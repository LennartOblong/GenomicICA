#Rscript to compute univariate GWAS correlation of individual IDPs. Called by stage 5.

require(dplyr)
args <- commandArgs(trailingOnly = TRUE)

input_csv=args[1]
output_csv=args[2]
idp_id=args[3]
in_data<-read.csv(input_csv,header=F)

a<-in_data[,1] %>% na.omit()
b<-in_data[,2] %>% na.omit()

cor_res <- cor.test(a,b)
a_b_corr <- cor_res$estimate
p_value <- cor_res$p.value

m_data<- as.data.frame(cbind(idp_id,a_b_corr,p_value,overlap_coeff))

colnames(m_data)<- c("IDP_ID","Correlation","P_Value","Overlap_coeff")
write.table(m_data, output_csv,row.names = FALSE, col.names = TRUE, quote = FALSE)

