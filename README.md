# MPI Dog Office Project

This project was conducted with eight canines residing in their respective owners' offices at the MPI-EVA in Leipzig.The objective of this project was to identify genetic variations among the canines using DNA analysis. Leveraging this genomic information, the relationship among the canines was ascertained. With the assistance of reference canines, unsequenced information was annotated the subjects. Furthermore, samples were collected from various locations at the MPI-EVA, including office floors, hallways, elevators, and laboratories. The extracted DNA was then used to identify the locations where each dog was present. 

## One script to rule them all

The step_by_step_run_all script should be used to process the data. This script will guide you according to the "Step-by-step explanation of the script". Please be sure to run this script from the directory above /bin.
```
bash /bin/step_by_step_run_all.sh
```


## Step-By-Step explanation of the script

### 1. Processing (processing and count)

Here it is nessesary to change the *.bam file to your *.bam file directory.
In a first step the data was processed. Therefore the raw data was filtered for the mitochondrial DNA (mtDNA). Furthermore a map quality of 25 % was required, and only deduplicated data was allowed.
```
bash processing/filter.sh
```

Also there is one script to count the sequences. This process might take some time.
```
bash processing/sequence_counter.sh
```


### 2. Consensus (consensus)

Using the processed data to call a consensus sequence for each dog is done by using Matthias' perl script and a canines references FASTA. In addition, the undetermined data were deleted.
```
bash consensus/consensus.sh	
```

### 3. MSA (msa)

In a first step to create a multiple sequence alignment (MSA), a masking step was performed. This resulted in a renamed copy of the consensus sequence for all dogs in a separate file. Also, the files are renamed to a shorter form.
```
bash msa/mask.sh	
```

For further processing, all dog sequences go through a cutoff process. Therefore, all sequences were trimmed after a TTTTAGG/AAG part at the end of their DNA. 
```
bash msa/cutoff_seq.sh	
```

In a final step, the sequences of all our dogs (combined), previously published ones (combined_pub), and a reference dog (combined_pub.ref) were aligned using MAFFT. This resulted in three different .fasta and .aln files, shown in brackets.
```
bash msa/msa.sh 	
```

### 4. Phylogenetic tree (tree)

Using the alignment files, a phylogenetic tree was generated for the MPI dogs only, and for the MPI dogs, the previously published dogs, and the reference dog. Therefore FastTree was used.
```
bash tree/tree.sh
```

### 5. Detecting differences between the MPI dogs (differences)

The information from the phylogenetic tree was used to find closely related dogs for each MPI dog. This information was then manually added to the /bin/diff/related.txt file. Afterward the script can be executed.
```
bash diff/diff.sh
```

In a first step, the script trims the sequences of the file combined_pub.ref.aln to a length of 16138 bp. From these trimmed sequences, the sequences of the MPI dogs and their closely related dogs are extracted. The information is then transferred to a csv file. In this csv file, the n's of the MPI dogs are replaced by the bases of their closely related dogs, if they are the same. The replaced sequences of the MPI dogs were then written into a fasta file together with the sequence information of the reference dog. A new alignment was then performed.

### 6. Genome Coordinates (coordinates)

In order to compare the sequence of the MPI dogs with the sequence information from the environmental data, genomic coordinates are required. Therefore, the reference dog genome is used to assign coordinates to all MPI dog sequences.
```
python3 ref/ref_coor.py "$BASE_PATH/data/dog_samples/diff/replaced_seq.related_n.mpi_dogs.added_ref.aln" "$BASE_PATH/data/dog_samples/ref/ref_coordinates.csv" NC_002008.4 fasta
```
### 7. Dividing the dogs in different categorize for detailt analysizes (offices)

As we assume that MPI dogs are most likely to be found in their owner's office, we focused mainly on the differentiation between dogs in the same office (raw). It is also possible to exclude dogs via differnt filters (exclude).
```
bash ref/run_extract_dog.sh
```

### 8. Detecting private positions (snps)

The following script should find private position of each dog in comparission the other (filtered) dogs. 
```
bash env_bam/run_bam.sh
```

### 9. R preparation (R)

In order to visualize the collected data in R, some processing was required. Therefore, a csv file was created containing the average radio for each MPI dog in each sample.
```
python3 R_prep/csv_prep.py "$BASE_PATH/data/dog_samples/env_bam/all_env_*.csv" "$BASE_PATH/data/dog_samples/R_prep/R_prep_sample_vs_dog.csv"
```

## Python packages

* pandas
* csv
* argparse
* sys
* re
* ete3
* pysam
* glob
* os

## R

R was used for data visualization. For further data analysis, we decided to group genetically similar dogs together. This includes Anda, Thor A and Lily as well as Thor B and Cami.

### Locations of the dogs

Samples were collected from different locations. To highlight the amount of dog DNA at each location, the following R script can be used
```
R/dog_catagorized_readsdeduped.R
```
As the data contains samples with no data points or low amounts of DNA, these samples need to be sorted out. For SNP validation, the position of the SNPs must be covered by at least 10 sequences, regardless of whether the SNP occurs in them or not. There must also be at least 50 ReadsDeduped in the raw data. 
After this filtering, different locations where the dogs might be present are examined. 

Samples that are filtered out are highlighted with an asterisk. The data shows that each dog is mainly present in its owner's office. Based on this knowledge, further research was conducted.

### Headmaps

With the knowledge that every dog's DNA is most likely to occur in there owners office, we started to investigate the two main dog offices. Those include for office 1: Heidi, Vito, Fritzy and Urza, and for office 2: Lily and Thor A. The amount of DNA belonging to each individual dog was visualized as a heatmap.
```
R/heatmaps_dog_offices.R
``` 

### Different species in dog and non-dog locations

As the ground samples were taken from various locations, they might as well contain DNA of other species. Therefore, the presence of human, Felican and Suidae DNA was also checked. As this is also an indicator of the amount of dog DNA in general, we decided to compare dog offices with all other locations. 
```
R/family_dog_vs_non_dog_office.R
```

### Occurrence of human and dog DNA

Most of the DNA found is from humans or dogs, and dog DNA is more likely to be found in the dog offices than in other locations. To compare the amount of human and dog DNA in different locations, another plot was created.
```
R/category_family_location.R
```

### Walls vs Non-Walls

Another hypothesis was that DNA might accumulate near the walls. Therefore, the amount of human and dog DNA was compared in the dog offices as well as in other locations.
```
R/walls_vs_no_walls.R
```






