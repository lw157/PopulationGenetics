#BiocManager::install('rtracklayer')
#BiocManager::install('liftOver')
library(rtracklayer)
require(liftOver)
require(data.table)

path = system.file(package="liftOver", "extdata", "hg38ToHg19.over.chain")
ch = import.chain(path)

dat = fread("testdata.txt.gz")
dat$chr= paste0("chr",dat$chromosome)
dat[dat$chr == "chr23"]$chr <- "chrX"
## make sure your chr is in "chr1" ... "chrX" format

gr <- GRanges(seqnames=dat$chr, ranges=IRanges(start=dat$base_pair_location, end=dat$base_pair_location, strand="*"),
              snp = dat$variant_id)
res_lift <- as.data.frame(liftOver(gr, chain))



##### Alternatively, with longer code
## download from UCSC golden path
chainfile = import.chain("hg38ToHg19.over.chain")

#### load data
gwas = fread("gwas.txt")
hg38 = data.frame(chr= paste0("chr", gwas$chromosome), start = gwas$base_pair_location,
                  end = gwas$base_pair_location,snp=gwas$variant_id)

hg38$chr = gsub("chr23", "chrX", hg38$chr)

hg38obj <- makeGRangesFromDataFrame(hg38, TRUE)
hg19lift <- liftOver(hg38obj, chainfile)
hg19 <- as.data.frame(hg19lift)
hg19slim = hg19[,c("seqnames","start","snp")] ##

misssnp = dim(hg38)[1] - dim(hg19slim)[1] ## 
misssnp ## double check missing SNPs

finout_2hg19 = merge(gwas, hg19slim, by.x="variant_id", by.y="snp", all.x = TRUE)



