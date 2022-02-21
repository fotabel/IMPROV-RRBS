# IMPROVE-RRBS tool Ignores MsPI site and sequencing Read 3’ end OVErlap in RRBS methylation calling

## Overview
IMPROVE-RRBS efficiently identifies and hides non-methylated cytosine from the 3’ end of MspI digested
DNA fragments.

## Features
- Detecting whether the input file is single-read or paired-end
- Logging the "Number of unique MsPI reads", the "Number of MsPI reads" and the "Number of all reads"
- Outputting a BAM file without the biased cytosines

## Installation
IMPROVE-RRBS is an easy-to-use, Unix shell script, which can be easily implemented in common RRBS analysis pipelines.
Set execute permission on IMPROVE-RRBS.sh using chmod command and run it.

## Usage
To run IMPROVE-RRBS the following input parameters are required in this order:
- infile: path to input sorted BAM file
- chromsizes: path to chrom.sizes file to define the chromosome lengths for a given genome
- genome: path to genome file
- outfile: name for the output file

**Example**:
`./IMPROVE-RRBS.sh infile.bam mm10.chrom.sizes mm10.fa output.bam`

## Dependencies
- samtools
- bedtools
