## modify from stackoverflow

library(biomaRt)
## biomaRt 2.44.1

listEnsemblArchives() 
listEnsembl(version = 100)

coords = data.frame(chr_name = c(1,1), start = c(12554805,41036621), end=c(12554805,41036621))
coords$ID = paste0("id", 1:nrow(coords)) ## This unique ID for merging data

snpmart = useEnsembl(biomart = "snp", dataset="hsapiens_snp") ## This is for biomaRt 2.44.1 + GRCh38
# snps38 =useMart(biomart="ENSEMBL_MART_SNP", dataset="hsapiens_gene_ensembl") # GRCh38
# snps = useMart(biomart="ENSEMBL_MART_SNP", host="grch37.ensembl.org", path="/biomart/martservice",dataset="hsapiens_snp") ## hg19

res <- list()

for ( i in 1:nrow(coords)){
  
  ens = getBM(attributes = c( 'chr_name', 'chrom_start','chrom_end','refsnp_id'), 
        filters = c('chr_name','start','end'), 
        values = as.list(coords[i,1:3]), 
        mart = snpmart)
  
  res[[i]] = ens
}


res_out = plyr::ldply(res, .id = "ID")

res_fin = merge(res_out, coords, by = "id")
