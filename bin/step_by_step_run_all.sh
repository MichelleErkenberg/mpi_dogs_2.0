##!/bin/bash

read -p "change BASE_PATH?(n/y): " b
if [[ "$b" == "n" ]]; then
	export BASE_PATH=$(pwd)
	echo "current BASE_PATH = "$BASE_PATH"" 
elif [[ "$b" == "y" ]]; then
	read -p "change BASE_PATH to: " bn
	export BASE_PATH="$bn"
	echo "BASE_PATH changed to "$bn""	
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

#finding differences and replace the n's (also see diff.sh for more details); it takes the latest aln so far and trims it to 16138bp; afterwards closely related dog sequences are extracted (manually) and differences are highlighted in an csv file; the n's from our dogs are than replaced (if possible) with the bases from the replated dogs; that leads to an csv file with replaced n's and in the long term to an fasta file with out dogs + replaced possions 
elif [[ "$x" == "differences" ]]; then
	bash bin/diff/diff.sh
	echo "differences found, N's replaced"

#using the ref dog genome for genome coordinates
elif [[ "$x" == "coordinates" ]]; then

	mkdir -p "$BASE_PATH/data/dog_samples/ref"
	python3 bin/ref/ref_coor.py "$BASE_PATH/data/dog_samples/diff/replaced_seq.related_n.mpi_dogs.added_ref.aln" "$BASE_PATH/data/dog_samples/ref/ref_coordinates.csv" NC_002008.4 fasta
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
ENV_BAM_DIR="$BASE_PATH/data/dog_samples/env_bam"
R_PREP_DIR="$BASE_PATH/data/dog_samples/R_prep"


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
#python3 R_prep/env_place.py "$BASE_PATH/data/dog_samples/R_prep/R_prep_sample_vs_dog.csv" "$BASE_PATH/data/dog_samples/R_prep/dog_env_samples_24_v1.txt" "$BASE_PATH/data/dog_samples/R_prep/"
#python3 R_prep/env_place.py "$BASE_PATH/data/dog_samples/R_prep/all_dogs_AC/R_prep_sample_vs_dog_AC.csv" "$BASE_PATH/data/dog_samples/R_prep/dog_env_samples_24_v1.txt" "$BASE_PATH/data/dog_samples/R_prep/all_dogs_AC"

# for running the entire script
elif [[ "$x" == "all" ]]; then
	bash bin/run_all.sh

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
	echo "all"
fi

read -p "continue process (y/n)?: " c
	if [[ "$c" == "y" ]]; then
		continue
	else
		break	
	fi
done	