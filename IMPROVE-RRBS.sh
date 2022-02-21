#!/bin/bash


infile=$1
chromsizes=$2
genome=$3
outfile=$4
PE=`samtools view -c -f 1 $infile`
echo "$PE"
if [ "$PE" != 0 ]
then
echo "Paired-end sequences are detected"
else
echo "Single-end sequences are detected"
fi

# Oriantation selection
#PE
if [ "$PE" != 0 ]
then
samtools view -b -h -f 0x40 -o ${infile%.bam}_R1.bam $infile
samtools view -b -h -f 0x80 -o ${infile%.bam}_R2.bam $infile
else #SE
samtools view -b -h -o ${infile%.bam}_R1.bam $infile
fi

#defining blocks
bedtools bamtobed -i ${infile%.bam}_R1.bam |
	cut -f1,2,3,6 |
	uniq |
	sed 's/\t/\t0\t0\t/3' |
	bedtools slop -s -i stdin -g $chromsizes -l 0 -r 2 |
	bedtools getfasta -s -fi $genome -bed stdin -bedOut |
	egrep -i 'CCGG.{0,2}$' |
	cut -f1-6 |
	bedtools slop -s -i stdin -g $chromsizes -l 0 -r -2 > ${infile%.bam}_blocks.bed

echo "Number of unique msp1 reads:" > $outfile.logs
wc -l ${infile%.bam}_blocks.bed >> $outfile.logs

bedtools intersect -s -f 1 -F 1 -a ${infile%.bam}_R1.bam -b ${infile%.bam}_blocks.bed > ${infile%.bam}_msp1.bam 
bedtools subtract -s -f 1 -F 1 -a ${infile%.bam}_R1.bam -b ${infile%.bam}_blocks.bed > ${infile%.bam}_msp1neg.bam

rm ${infile%.bam}_blocks.bed ${infile%.bam}_R1.bam

echo "Blocks have been found"

#logging
echo "Number of msp1 reads:" >> $outfile.logs
samtools view -c -F 4 ${infile%.bam}_msp1.bam >> $outfile.logs
echo "Number of all reads:" >> $outfile.logs
samtools view -c -F 4 $infile >> $outfile.logs

#strand selection
samtools view -h -F 0x10 -o ${infile%.bam}_msp1_forw.sam ${infile%.bam}_msp1.bam
samtools view -h -f 0x10 -o ${infile%.bam}_msp1_rev.sam ${infile%.bam}_msp1.bam

rm ${infile%.bam}_msp1.bam
echo "Reads have been desected"

#header cut
awk '/^@/ { print $0 }' ${infile%.bam}_msp1_forw.sam > ${infile%.bam}_msp1_forw_header.sam
awk '!/^@/,EOF { print $0 }' ${infile%.bam}_msp1_forw.sam > ${infile%.bam}_msp1_forw_reads.sam
awk '/^@/ { print $0 }' ${infile%.bam}_msp1_rev.sam > ${infile%.bam}_msp1_rev_header.sam
awk '!/^@/,EOF { print $0 }' ${infile%.bam}_msp1_rev.sam > ${infile%.bam}_msp1_rev_reads.sam

rm ${infile%.bam}_msp1_forw.sam ${infile%.bam}_msp1_rev.sam

#SE, Read1 forw
awk -F "\t" 'OFS="\t" { $10 = substr($10, 1, length($10)-3) "NNN"; $11 = substr($11, 1, length($11)-3) "!!!"; $14 = substr($14, 1, length($14)-3) "..." } 1' ${infile%.bam}_msp1_forw_reads.sam > ${infile%.bam}_msp1_forw_trim.sam
#rev
awk -F "\t" 'OFS="\t" { $10 = "NNN" substr($10, 4, length($10)); $11 = "!!!" substr($11, 4, length($11)); $14 = "XM:Z:..." substr($14, 9, length($14)) } 1' ${infile%.bam}_msp1_rev_reads.sam > ${infile%.bam}_msp1_rev_trim.sam

rm ${infile%.bam}_msp1_forw_reads.sam ${infile%.bam}_msp1_rev_reads.sam
echo "Reads have been trimmed"

#merge
cat ${infile%.bam}_msp1_forw_trim.sam >> ${infile%.bam}_msp1_forw_header.sam
cat ${infile%.bam}_msp1_rev_trim.sam >> ${infile%.bam}_msp1_rev_header.sam

rm ${infile%.bam}_msp1_forw_trim.sam ${infile%.bam}_msp1_rev_trim.sam

if [ "$PE" != 0 ]
then
samtools merge -f $outfile ${infile%.bam}_R2.bam ${infile%.bam}_msp1neg.bam ${infile%.bam}_msp1_forw_header.sam ${infile%.bam}_msp1_rev_header.sam
rm ${infile%.bam}_R2.bam ${infile%.bam}_msp1neg.bam ${infile%.bam}_msp1_forw_header.sam ${infile%.bam}_msp1_rev_header.sam
else
samtools merge -f $outfile ${infile%.bam}_msp1neg.bam ${infile%.bam}_msp1_forw_header.sam ${infile%.bam}_msp1_rev_header.sam
rm ${infile%.bam}_msp1neg.bam ${infile%.bam}_msp1_forw_header.sam ${infile%.bam}_msp1_rev_header.sam
fi

echo "Reads have been merged"
