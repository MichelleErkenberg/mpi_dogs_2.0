#!/bin/bash


#processing the data, filtering for ChrM and Quality and counting

	#filter for the mitochondrial Chromosom, mapquaility 25% and dedup
	bash bin/processing/filter.sh
	
	#count the sequences and for orignial data count also for sequences per chromosom
	bash bin/processing/sequence_counter.sh
	
#Call a consensus sequence for each dog using Matthias' perl script
	bash bin/consensus/consensus.sh	

#msa for the created consensus sequences (renaming the sequence as part of the masking process)

	#copies and renames the consensus sequences for all of our dogs, Undetermined is deleted in the process
	bash bin/msa/mask.sh

	#cutoff the sequence of all our dogs after TTTTAGG/AAG
	bash bin/msa/cutoff_seq.sh
	
	#all of your dogs + previously published ones + reference dog combined in one script each + msa
	bash bin/msa/msa.sh 

#create phylogenetic tree for our dogs and the published dogs with a reference one
	bash bin/tree/tree.sh

#finding differences and replace the n's (also see diff.sh for more details); it takes the latest aln so far and trims it to 16138bp; afterwards closely related dog sequences are extracted (manually) and differences are highlighted in an csv file; the n's from our dogs are than replaced (if possible) with the bases from the replated dogs; that leads to an csv file with replaced n's and in the long term to an fasta file with out dogs + replaced possions 
	bash bin/diff/diff.sh

#using the ref dog genome for genome coordinates 
mkdir -p "$BASE_PATH/data/dog_samples/ref"
python3 bin/ref/ref_coor.py "$BASE_PATH/data/dog_samples/diff/replaced_seq.related_n.mpi_dogs.added_ref.aln" "$BASE_PATH/data/dog_samples/ref/ref_coordinates.csv" NC_002008.4 fasta

#dogs were living in different offices, this script creates files with just the dogs that lived together 
bash bin/ref/run_extract_dog.sh 

#finding the private position for our dogs in the environment data
bash bin/env_bam/run_bam.sh

#prepairing the environmental dog data to process them using R 
#creates a csv file with the average radio for each dog in the sample
#python3 R_prep/csv_prep.py "$BASE_PATH/data/dog_samples/env_bam/all_env_*.csv" "$BASE_PATH/data/dog_samples/R_prep/R_prep_sample_vs_dog.csv" "2"

#creates csv file with average radio for each dog by using all dog (except Thor A and B)
#mkdir -p "$BASE_PATH/data/dog_samples/R_prep/all_dogs_AC"
#python3 R_prep/csv_prep.py "$BASE_PATH/data/dog_samples/env_bam/all_env_AC*.csv" "$BASE_PATH/data/dog_samples/R_prep/all_dogs_AC/R_prep_sample_vs_dog_AC.csv" "2"
#creates csv file with average radio for each dog by using all dog (except Thor A and B and Lily)
mkdir -p "$BASE_PATH/data/dog_samples/R_prep/all_dogs_ACwoL"
python3 R_prep/csv_prep.py "$BASE_PATH/data/dog_samples/env_bam/all_env_ACwoL/all_env_AC*.csv" "$BASE_PATH/data/dog_samples/R_prep/all_dogs_ACwoL/R_prep_sample_vs_dog_ACwoL_2snp.csv" "2"
python3 R_prep/csv_prep.py "$BASE_PATH/data/dog_samples/env_bam/all_env_ACwoL/all_env_AC*.csv" "$BASE_PATH/data/dog_samples/R_prep/all_dogs_ACwoL/R_prep_sample_vs_dog_ACwoL_5snp.csv" "5"
python3 R_prep/csv_prep.py "$BASE_PATH/data/dog_samples/env_bam/all_env_ACwoL/all_env_AC*.csv" "$BASE_PATH/data/dog_samples/R_prep/all_dogs_ACwoL/R_prep_sample_vs_dog_ACwoL_10snp.csv" "10"

#uses the txt file with the location to sort those average radios into new csv files
#python3 R_prep/env_place.py "$BASE_PATH/data/dog_samples/R_prep/R_prep_sample_vs_dog.csv" "$BASE_PATH/data/dog_samples/R_prep/dog_env_samples_24_v1.txt" "$BASE_PATH/data/dog_samples/R_prep/"
#python3 R_prep/env_place.py "$BASE_PATH/data/dog_samples/R_prep/all_dogs_AC/R_prep_sample_vs_dog_AC.csv" "$BASE_PATH/data/dog_samples/R_prep/dog_env_samples_24_v1.txt" "$BASE_PATH/data/dog_samples/R_prep/all_dogs_AC"
