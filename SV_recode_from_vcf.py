#! /usr/bin/python

## under python 3.6

import pandas as pd
from tqdm import trange
import sys, getopt

cnv_AltCode_dict = {'CN0':0, 'CN1':1,  'CN2':2, 'CN3':3, 'CN4':4, 'CN5':5, 'CN6':6, 'CN7':7, 'CN8':8, 'CN9':9,
               'INS:ME:ALU':2, 'INS:ME:LINE1':2, 'INS:ME:SVA':2,'INS:MT':2, 'INV':2, 'A':2,'T':2,'G':2,'C':2 }

def convert_cnv(dat):
    samples = dat.columns.tolist()

    cnv_recode_all = []
    for irow in trange(dat.shape[0]): #dat.shape[0]
        chr = dat.iloc[irow,0]
        pos = dat.iloc[irow,1]
        marker = dat.iloc[irow,2]
        ref = dat.iloc[irow,3]
        alt = dat.iloc[irow, 4].replace("<", "").replace(">", "")

        allele_ref = 'CN1'
        allele_alt = alt.split(",")

        alleles = [allele_ref] + allele_alt

        allele_recode = [chr, pos, marker, ref, alt]

        for jcol in range(9, dat.shape[1]):
            geno = dat.iloc[irow, jcol].split('|')
            copy_num = 0
            for igeno in geno:
                if str(igeno).isnumeric():
                    v = alleles[int(igeno)]
                    if v not in cnv_AltCode_dict.keys():
                        print(v, " is not a valid CNV code")
                        print("Please check genotype of ", dat.iloc[irow, jcol], " at row of ", irow, " and \t column ", jcol)
                    else:
                        copy_num += cnv_AltCode_dict[v]
                else:
                    print("Please check genotype of ", dat.iloc[irow, jcol], " at row of ", irow, " and \t column ", jcol)
                    copy_num = 'NA'

            allele_recode.append(copy_num)

        cnv_recode_all.append(allele_recode)

    cnv_fin = pd.DataFrame(cnv_recode_all)
    cnv_fin.columns = ['Chr', 'Pos', 'Marker', "RefA", "AltA"] + samples[9:]

    return(cnv_fin)


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Convert vcf copy number variant')
    parser.add_argument("-i", "--ifile", dest="infile", help="input vcf file name", metavar="FILE")
    parser.add_argument("-o", "--ofile", dest="outfile", help="outfile name")

    args = parser.parse_args()

    if not args.outfile:
        outfile = str(args.infile) + "_to_R2.txt"
    else:
        outfile = args.outfile

    if args.infile:
        dat = pd.read_csv(args.infile, comment="##", sep='\t', engine="python")
        dat.rename(columns={'#CHROM': 'CHROM'}, inplace=True)

        print(dat.shape[0], " variants from ", dat.shape[1] - 9, " samples were loaded")

        cnv_out = convert_cnv(dat)
        cnv_out.to_csv(outfile, sep='\t', index=False)
    else:
        parser.print_help()


if __name__ == '__main__':
    main()


## README
## for CNV, ref always = CN1

#For CNVs the REF is <CN1>, ALT is <CN0>
#Humans are diploid thus :
# 0/0 == CN1/CN1 or 2 copies
# 0/0 = CN1/CN1 = 2 copies
# 0/1 = CN1/CN0 = 1 copy
# 1/1 = CN0/CN0 = 0 copies
#
# With multiallelic variants the order of the alleles is the same as the genotypes (in 1-base positions)
# So when ALT is <CN0>,<CN2>; the possible genotypes are 0,1,2 corresponding to CN1,CN0,CN2
#
# 0/1 = CN1/CN0 = 1 copy
# 1/2 = CN0/CN2 = 2 copies
# 2/2 = CN2/CN2 = 4 copies
# So if the ALT is <CN0>,<CN2>,<CN3>,<CN4>
# The genotypes are (0/Ref), 1, 2, 3, 4 in the same order as the alleles in ALT
# 1/3 = CN0/CN3 = 3 copies

# <INS:ME:ALU>  --> I recoded it as 2 as this is a insertion, this is treated as biallelic
# <INS:ME:LINE1> --> I recoded it as 2 as this is a insertion, this is treated as biallelic
# <INS:ME:SVA> --> I recoded it as 2 as this is a insertion, this is treated as biallelic
# <INS:MT> --> I recoded it as 2 as this is a insertion, this is treated as biallelic
# <INV> --> I recoded it as 2 as this is a insertion, this is treated as biallelic
# Alt is A, T, G, C, I also recode as 2, this is treated as biallelic
