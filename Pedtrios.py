#! usr/bin/python
import string
import re
import sys,getopt


def trio(infile,outfile):

    f = open(infile,"r")
    out = open(outfile,"w")

    print "Inputfile is " + infile
    print "Output will be " + outfile

    trios = set()
    count_trios = 0
    count_sigleparents = 0

    for i in map(string.strip,f):
        ls = i.split()

        if re.match(r'NA',ls[3],re.M|re.I) or re.match(r'NA',ls[4], re.M|re.I):
            trios.add(ls[1])
            trios.add(ls[3])
            trios.add(ls[4])

        if 'NA' in ls[3] and 'NA' in ls[4]:
            count_trios += 1

        if re.match(r'NA',ls[3],re.M|re.I) and (not re.match(r'NA',ls[4], re.M|re.I)):
            count_singleparents += 1

        if (not re.match(r'NA',ls[3],re.M|re.I)) and re.match(r'NA',ls[4], re.M|re.I):
            conut_singleparents += 1
            
            with open(infile,"r") as ff:
        for j in map(string.strip,ff):
            l = j.split()
            if l[1] in trios:
                out.write(j + "\n")

    f.close()
    out.close()

    print "There are " + count_trios + " trios in " + infile
    print "There are " + count_singleparents + " single parents in " + infile


def usage():
    print 'This python script will count number of trios, parents\n'
    print 'Usage: python Pedtrios.py -i <inputfile> -o <outputfile> \n'
    print 'Method: >>> count number of family member from plink Ped file'
    print '        >>> out put unique family in Plink Ped format \n'
    print 'Options: python cntped.py input.ped'
    sys.exit(' ')

def main(argv):
    inputfile = ''
    outputfile = ''

    try:
        opts, args = getopt.getopt(argv,"hi:o", ["ifile=","ofile="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            usage()
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o","--ofile"):
            outputfile = arg
        else:
            usage()
            sys.exit(2)

        if inputfile and outputfile:
            trio(inputfile,outputfile)

        print "analysis is done\n"

if __name__ == "__main__":
    if len(sys.argv) <= 1:
        usage()
        sys.exit()
    else:
        main(sys.argv[1:])
