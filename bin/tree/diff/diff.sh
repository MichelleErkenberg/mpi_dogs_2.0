##!/bin/bash

OUTDIR="$BASE_PATH/data/dog_samples/diff"

#create OUTDIR if it doesn't exist
mkdir -p "$OUTDIR"

#create and trim the .aln file to cut all sequences to a defined length of 16138 bp
bash diff/trim_msa.sh

#Extract the closely related reference dogs for our mpi dogs (if possible) + alignment; mpi_dogs replaced by mpi_dogs are not used for comparison; related dog were detected manually and can be changed in the diff/related.txt file
python3 diff/extract_sequences.py "$OUTDIR/combined_pub.ref.trimmed.aln" diff/related.txt "$OUTDIR/related_seq.fasta"
mafft "$OUTDIR/related_seq.fasta" > "$OUTDIR/related_seq.aln"

#write the aln file into a csv file to replace in the n's afterwards in this file
python3 diff/aln_to_csv.py "$OUTDIR/related_seq.aln" "$OUTDIR/related_seq.csv"

#creates a .csv-file where N's are replaced by bases from closely related dogs (if they are the same)
python3 diff/replace_n.py names.txt "$OUTDIR/related_seq.csv" "$OUTDIR/replaced_seq.related_n.csv"

#uses the replaced_n.csv to create a new .fasta-file with replaced n's
python3 diff/replaced_n_fasta.py "$OUTDIR/replaced_seq.related_n.csv" "$OUTDIR/replaced_seq.related_n.fasta"  

#write the mpi dog sequences with replaced n's into a new fasta 
seqkit grep -f names.txt "$OUTDIR/replaced_seq.related_n.fasta" > "$OUTDIR/replaced_seq.related_n.mpi_dogs.fasta"

#add the ref dog to this fasta
cat "$BASE_PATH/data/science_dogs/Canis_lupus_familiaris.fasta" "$OUTDIR/replaced_seq.related_n.mpi_dogs.fasta" > "$OUTDIR/replaced_seq.related_n.mpi_dogs.added_ref.fasta"

#renaming the reference sequence into just NC_002008.4
sed -i 's/>NC_002008\.4 Canis lupus familiaris mitochondrion, complete genome/>NC_002008.4/' "$OUTDIR/mpi_ref.fasta"

#align mpi dogs with ref dog
mafft "$OUTDIR/replaced_seq.related_n.mpi_dogs.added_ref.fasta" > "$OUTDIR/replaced_seq.related_n.mpi_dogs.added_ref.aln"


