##!/bin/bash

read -p "change MPI_BASE_PATH?(n/y): " b
if [[ "$b" == "n" ]]; then
	export MPI_BASE_PATH=$(pwd)
	echo "current MPI_BASE_PATH = "$MPI_BASE_PATH"" 
elif [[ "$b" == "y" ]]; then
	read -p "change MPI_BASE_PATH to: " bn
	export MPI_BASE_PATH="$bn"
	echo "MPI_BASE_PATH changed to "$bn""	
fi


while true; do

read -p "enter the process to be executed (press Enter for showing avalible processes): " x


#processing the data, filtering for ChrM and Quality and counting
if [[ "$x" == "processing" ]]; then
	#filter for the mitochondrial Chromosom, mapquaility 25% and dedup
	bash bin/processing/filter.sh
	echo "data processed"

	
elif [[ "$x" == "count" ]]; then	
	#count the sequences and for orignial data count also for sequences per chromosom
	bash bin/processing/sequence_counter.sh
	echo "amount of sequences pre chromosom and for ChrM counted"
	
#Call a consensus sequence for each dog using Matthias' perl script
elif [[ "$x" == "consensus" ]]; then
	bash bin/consensus/consensus.sh	
	echo "consensus sequences created"

#msa for the created consensus sequences (renaming the sequence as part of the masking process)
elif [[ "$x" == "msa" ]]; then
	#copies and renames the consensus sequences for all of our dogs, Undetermined is deleted in the process
	bash bin/msa/mask.sh
	echo "masking finished"

	#cutoff the sequence of all our dogs after TTTTAGG/AAG
	bash bin/msa/cutoff_seq.sh
	echo "sequeces were cut after TTTTAGG/AAG"
	
	#all of your dogs + previously published ones + reference dog combined in one script each + msa
	bash bin/msa/msa.sh 
	echo "MSA created"

#create phylogenetic tree for our dogs and the published dogs with a reference one
elif [[ "$x" == "tree" ]]; then

	bash bin/tree/tree.sh
	echo "phylogenentic tree created"

#finding differences and replace the n's 
elif [[ "$x" == "differences" ]]; then
	bash bin/diff/diff.sh
	echo "differences found, N's replaced"

#using the ref dog genome for genome coordinates
elif [[ "$x" == "coordinates" ]]; then

	mkdir -p "$MPI_BASE_PATH/data/dog_samples/ref"
	python3 bin/ref/ref_coor.py "$MPI_BASE_PATH/data/dog_samples/diff/replaced_seq.related_n.mpi_dogs.added_ref.aln" "$MPI_BASE_PATH/data/dog_samples/ref/ref_coordinates.csv" NC_002008.4 fasta
	echo "genomic coordinates detected"

#dogs were living in different offices, this script creates files with just the dogs that lived together 
elif [[ "$x" == "offices" ]]; then
	bash bin/ref/run_extract_dog.sh

#finding the private position for our dogs in the environment data
elif [[ "$x" == "snps" ]]; then
	bash bin/env_bam/run_bam.sh
	echo "private positions for each dog detected and compared with environmental data" 

#prepairing the environmental dog data to process them using R 
#creates a csv file with the average radio for each dog in the sample
elif [[ "$x" == "R" ]]; then
	read -p "choose required amount of snps: " s


#creates csv file with average radio for each dog by using all dog (except excluded onces)
ENV_BAM_DIR="$MPI_BASE_PATH/data/dog_samples/env_bam"
R_PREP_DIR="$MPI_BASE_PATH/data/dog_samples/R_prep"


for folder in "$ENV_BAM_DIR"/*; do
    if [ -d "$folder" ]; then
        folder_name=$(basename "$folder")
        
        
        mkdir -p "$R_PREP_DIR/$folder_name"
        
        
        python3 bin/R_prep/csv_prep.py \
            "$folder/all_env_*.csv" \
            "$R_PREP_DIR/$folder_name/R_prep_sample_vs_dog_${folder_name}_${s}snp.csv" \
            "$s"
    fi
done
	echo "environmental data processed with "$s" SNPs"

#uses the txt file with the location to sort those average radios into new csv files
elif [[ "$x" == "split" ]]; then
    TXT_FILE="$MPI_BASE_PATH/data/dog_samples/R_prep/dog_env_samples_24_v1.txt"
    R_PREP_DIR="$MPI_BASE_PATH/data/dog_samples/R_prep"

    for rfolder in "$R_PREP_DIR"/*; do
        if [ -d "$rfolder" ]; then
            rfolder_name=$(basename "$rfolder")
            
            # Process each CSV file in the folder
            for csv_file in "$rfolder"/R_prep_sample_vs_dog_*.csv; do
                if [ -f "$csv_file" ]; then
                    # Extract the SNP suffix (e.g., 0snps, 2snps)
                    csv_basename=$(basename "$csv_file")
                    suffix=${csv_basename##*_}  # Get everything after last underscore
                    suffix=${suffix%.csv}       # Remove .csv extension
                    
                    # Create dedicated split directory for this SNP variant
                    split_dir="$rfolder/R_split_${suffix}"
                    mkdir -p "$split_dir"
                    
                    # Run processing with the specific output directory
                    python3 "$MPI_BASE_PATH/bin/R_prep/env_place.py" \
                        "$csv_file" \
                        "$TXT_FILE" \
                        "$split_dir/"
                fi
            done
        fi
    done


else
	echo "avalible processes:"
	echo "processing"
	echo "count"
	echo "consensus"
	echo "msa"
	echo "tree"
	echo "differences"
	echo "coordinates"
	echo "offices"
	echo "snps"
	echo "R"
	echo "split"
fi

read -p "continue process (y/n)?: " c
	if [[ "$c" == "y" ]]; then
		continue
	else
		break	
	fi
done	