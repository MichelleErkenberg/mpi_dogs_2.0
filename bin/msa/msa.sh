#!/bin/bash

mkdir -p "$BASE_PATH/data/dog_samples/msa"


# Set the working directory
work_dir="$BASE_PATH/data/dog_samples/msa/mask"
msa_dir="$BASE_PATH/data/dog_samples/msa"

# Change to the working directory
cd "$work_dir" || exit 1

#  Combine all cutoffed consensus files into one file in the 'msa' directory
cat *_cutoff.fas > "$msa_dir/combined.fasta"

# Display all header lines of the combined fasta file
grep '>' "$msa_dir/combined.fasta"

# Create a multiple sequence alignment using MAFFT
mafft "$msa_dir/combined.fasta" > "$msa_dir/combined.aln"

echo "Script executed successfully. The alignment has been saved in 'msa/combined.aln'."

# INCLUDING PREVIOUSLY PUBLISHED DOGS

cat "$msa_dir/combined.fasta" "$BASE_PATH/data/science_dogs/Canis_latrans.fasta" "$BASE_PATH/data/science_dogs/science_dogs_all.with_haps.fasta" > "$msa_dir/combined_pub.fasta"

# create a msa using MAFFT with previously published dogs
mafft "$msa_dir/combined_pub.fasta" > "$msa_dir/combined_pub.aln"

echo "Script executed successfully. The alignment has been saved in 'msa/combined_pub.aln'."

# Including reference dog NC_002008.4

cat "$msa_dir/combined_pub.aln" "$BASE_PATH/data/science_dogs/Canis_lupus_familiaris.fasta" > "$msa_dir/combined_pub.ref.fasta"

#create a msa using MAFFT with reference dog NC_002008.4

mafft "$msa_dir/combined_pub.ref.fasta" > "$msa_dir/combined_pub.ref.aln"

echo "Script executed successfully. The alignment has been saved in 'msa/combined_pub.ref.aln"

