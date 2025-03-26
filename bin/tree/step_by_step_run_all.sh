##!/bin/bash

read -p "change BASE_PATH?(n/y): " b
if [[ "$b" == "n" ]]; then
#define base path, need to be change to your path
	#export BASE_PATH="/mnt/expressions/michelle_erkenberg/github/mpi_dogs" 
	export BASE_PATH="/home/michelle/github/mpi_dogs"
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
	bash processing/filter.sh
	echo "data processed"

	
elif [[ "$x" == "count" ]]; then	
	#count the sequences and for orignial data count also for sequences per chromosom
	bash processing/sequence_counter.sh
	echo "amount of sequences pre chromosom and for ChrM counted"
	
#Call a consensus sequence for each dog using Matthias' perl script
elif [[ "$x" == "consensus" ]]; then
	bash consensus/consensus.sh	
	echo "consensus sequences created"

#msa for the created consensus sequences (renaming the sequence as part of the masking process)
elif [[ "$x" == "msa" ]]; then
	#copies and renames the consensus sequences for all of our dogs, Undetermined is deleted in the process
	bash msa/mask.sh
	echo "masking finished"

	#cutoff the sequence of all our dogs after TTTTAGG/AAG
	bash msa/cutoff_seq.sh
	echo "sequeces were cut after TTTTAGG/AAG"
	
	#all of your dogs + previously published ones + reference dog combined in one script each + msa
	bash msa/msa.sh 
	echo "MSA created"

#create phylogenetic tree for our dogs and the published dogs with a reference one
elif [[ "$x" == "tree" ]]; then

	bash tree/tree.sh
	echo "phylogenentic tree created"

#finding differences and replace the n's (also see diff.sh for more details); it takes the latest aln so far and trims it to 16138bp; afterwards closely related dog sequences are extracted (manually) and differences are highlighted in an csv file; the n's from our dogs are than replaced (if possible) with the bases from the replated dogs; that leads to an csv file with replaced n's and in the long term to an fasta file with out dogs + replaced possions 
elif [[ "$x" == "differences" ]]; then
	bash diff/diff.sh
	echo "differences found, N's replaced"

#using the ref dog genome for genome coordinates
elif [[ "$x" == "coordinates" ]]; then

	mkdir -p "$BASE_PATH/data/dog_samples/ref"
	python3 ref/ref_coor.py "$BASE_PATH/data/dog_samples/diff/replaced_seq.related_n.mpi_dogs.added_ref.aln" "$BASE_PATH/data/dog_samples/ref/ref_coordinates.csv" NC_002008.4 fasta
	echo "genomic coordinates detected"

#dogs were living in different offices, this script creates files with just the dogs that lived together 
elif [[ "$x" == "snps" ]]; then
	bash ref/run_extract_dog.sh

#finding the private position for our dogs in the environment data
	bash env_bam/run_bam.sh
	echo "private positions for each dog detected and compared with environmental data" 

#prepairing the environmental dog data to process them using R 
#creates a csv file with the average radio for each dog in the sample
elif [[ "$x" == "R" ]]; then
	read -p "choose required amount of snps: " s
	
 

#creates csv file with average radio for each dog by using all dog (except Thor A and B)
#mkdir -p "$BASE_PATH/data/dog_samples/R_prep/all_dogs_AC"
#python3 R_prep/csv_prep.py "$BASE_PATH/data/dog_samples/env_bam/all_env_AC*.csv" "$BASE_PATH/data/dog_samples/R_prep/all_dogs_AC/R_prep_sample_vs_dog_AC.csv" "2"
#creates csv file with average radio for each dog by using all dog (except Thor A and B and Lily)
	mkdir -p "$BASE_PATH/data/dog_samples/R_prep/all_dogs_ACwoL"
	python3 R_prep/csv_prep.py "$BASE_PATH/data/dog_samples/env_bam/all_env_ACwoL/all_env_AC*.csv" "$BASE_PATH/data/dog_samples/R_prep/all_dogs_ACwoL/R_prep_sample_vs_dog_ACwoL_2snp.csv" "$s"
	echo "environmental data processed with "$s" SNPs"

#uses the txt file with the location to sort those average radios into new csv files
#python3 R_prep/env_place.py "$BASE_PATH/data/dog_samples/R_prep/R_prep_sample_vs_dog.csv" "$BASE_PATH/data/dog_samples/R_prep/dog_env_samples_24_v1.txt" "$BASE_PATH/data/dog_samples/R_prep/"
#python3 R_prep/env_place.py "$BASE_PATH/data/dog_samples/R_prep/all_dogs_AC/R_prep_sample_vs_dog_AC.csv" "$BASE_PATH/data/dog_samples/R_prep/dog_env_samples_24_v1.txt" "$BASE_PATH/data/dog_samples/R_prep/all_dogs_AC"

# for running the entire script
elif [[ "$x" == "all" ]]; then
	bash run_all.sh

else
	echo "avalible processes:"
	echo "processing"
	echo "count"
	echo "consensus"
	echo "msa"
	echo "tree"
	echo "differences"
	echo "coordinates"
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