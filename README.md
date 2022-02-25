# IMPROVE-RRBS tool Ignores MsPI site and sequencing Read 3’ end OVErlap in RRBS methylation calling

## Overview
3’ ends of RRBS reads overlapping with genomic MspI sites include non-methylated cytosines introduced through end-repair. These cytosines are not recognized by Trim Galore and are therefore not trimmed but considered during methylation calling. To avoid this bias we developed IMPROVE-RRBS, which identifies and hides end-repaired cytosines from methylation calling to avoid methylation bias.

## Features
- Detecting whether the input file is single-read or paired-end
- Logging the "Number of unique MspI reads", the "Number of MspI reads" and the "Number of all reads"
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
`./IMPROVE-RRBS.sh test.bam rn6.chrom.sizes rn6.fa output.bam
It should produce the same result as in test.logs.

## Dependencies
- samtools
- bedtools
