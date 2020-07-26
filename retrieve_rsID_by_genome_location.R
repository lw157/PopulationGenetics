## modify from stackoverflow

library(biomaRt)
listEnsemblArchives() 

coords = data.frame(chr_name = c(1,1), start = c('12554805','41036621'), end=c('12554805','41036621'))
coords$ID = paste0("id", 1:nrow(coords)) ## This unique ID for merging data

# snps38 =useMart(biomart="ENSEMBL_MART_SNP", dataset="hsapiens_gene_ensembl") # GRCh38
snps = useMart(biomart="ENSEMBL_MART_SNP", host="grch37.ensembl.org", path="/biomart/martservice",dataset="hsapiens_snp") ## hg19

res <- list()

for ( i in 1:nrow(coord)){
  ens=getBM(attributes = c('refsnp_id','chr_name','chrom_start', 'chrom_end', 'allele_1'), filters = c('chr_name','start','end'),
            values = as.list(coords[i,]), mart = snps)
  res[[i]] = ens
}

res_out = plyr::ldply(res, .id = "ID")

res_fin = merge(res_out, coords, by = "id")
