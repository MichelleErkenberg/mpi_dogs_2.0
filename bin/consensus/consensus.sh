#!/bin/bash

# Define directories and reference file
BAM_DIR="$BASE_PATH/data/dog_samples/processing/ChrM/MQ25/dedup"
REF_FILE="$BASE_PATH/data/science_dogs/Canis_lupus_familiaris.fasta"
SCRIPT_PATH="$BASE_PATH/bin/consensus/consensus_from_bam.pl"

# Create the 'consensus' directory if it doesn't exist
mkdir -p "$BASE_PATH/data/dog_samples/consensus"

# Change to the 'consensus' directory
cd "$BASE_PATH/data/dog_samples/consensus"

# Loop through all BAM files in the specified directory
for bam_file in "$BAM_DIR"/*.bam; do
    # Extract the base name of the file 
    base=$(basename "$bam_file" .bam)
    
    echo "Processing $base.bam..."

    # Run the Perl script 'consensus_from_bam.pl'
    "$SCRIPT_PATH" \
      -ref "$REF_FILE" \
      "$bam_file"

    echo "Consensus creation process completed for $base.bam"
    echo "----------------------------------------"
done

# Delete Undetermined if it exists in the source directory (isn't a dog, just the stuff thats left)
    find . -name "s_all_Undetermined_*" -type f -delete
    echo "Deleted Undetermined."


echo "All BAM files have been processed."
