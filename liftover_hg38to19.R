#BiocManager::install('rtracklayer')
#BiocManager::install('liftOver')
library(rtracklayer)
require(liftOver)
require(data.table)

## download from UCSC golden path
chainfile = import.chain("hg38ToHg19.over.chain")

#### load data
gwas = fread("gwas.txt")
hg38 = data.frame(chr= paste0("chr",gwas $chromosome), start = gwas$base_pair_location,
                  end = gwas$base_pair_location,snp=gwas$variant_id)

hg38$chr = gsub("chr23", "chrX", hg38$chr)

hg38obj <- makeGRangesFromDataFrame(hg38, TRUE)
hg19lift <- liftOver(hg38obj, chainfile)
hg19 <- as.data.frame(hg19lift)
hg19slim = hg19[,c("seqnames","start","snp")] ##

misssnp = dim(hg38)[1] - dim(hg19slim)[1] ## 
misssnp ## double check missing SNPs

finout_2hg19 = merge(gwas, hg19slim, by.x="variant_id", by.y="snp", all.x = TRUE)
