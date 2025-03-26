#!/bin/bash

# Set working directory
WORKDIR="$BASE_PATH/data/dog_samples/msa"

# Set output directory
OUTDIR="$BASE_PATH/data/dog_samples/tree"

#create OUTDIR if it doesn't exist

mkdir -p "$OUTDIR"

# Change to working directory
cd "$WORKDIR"

# Create phylogenetic tree with MPI dogs (org)
FastTree -nt < combined.aln > "$OUTDIR/mpi_dogs_tree.nwk"

echo "Phylogenetic tree for MPI dogs created and saved as '$OUTDIR/mpi_dogs_tree.nwk'."

# Create phylogenetic tree with MPI dogs, published dogs and reference dog NC_002008.4
FastTree -nt < combined_pub.ref.aln > "$OUTDIR/mpi_dogs_pub.ref.nwk"

echo "Phylogenetic tree for MPI dogs and published dogs created and saved as '$OUTDIR/mpi_dogs_pub.ref.nwk'."
