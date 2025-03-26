#!/bin/ bash


# Loop through all BAM files in the specified directory
for INFILE in "$bam_file"/*.bam
do
    echo "Indexing: $INFILE"
    samtools index "$INFILE"
done
