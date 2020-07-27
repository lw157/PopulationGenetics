## get heng li's batchUCSC.pl from following link:
##http://lh3lh3.users.sourceforge.net/download/batchUCSC.pl


#conda install -c bioconda perl-dbi
#conda install -c bioconda perl-dbd-mysql

## single region
echo "chr1 1 1000000" | perl batchUCSC.pl -p snp

## batch 
perl batchUCSC.pl -p snp151::: -d hg38 input.bed > out.annot.txt

## cat input.bed
#1	2103939	2103940
#1	2104244	2104245
#1	2104359	2104360
