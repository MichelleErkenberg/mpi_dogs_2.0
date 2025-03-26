#!/bin/bash

# Source directory
source_dir="$BASE_PATH/data/dog_samples/consensus"

# Destination directory
dest_dir="$BASE_PATH/data/dog_samples/msa/mask"

# Create the destination directory if it doesn't exist
mkdir -p "$dest_dir"

# Search for matching files in the source directory
for file in "$source_dir"/*consensus.cov5support80basequal0mask0.fas; do
    if [ -f "$file" ]; then
        # Extract the desired part of the filename
        new_name=$(basename "$file" | sed -n 's/.*s_all_\(.*\)_S.*\.fas/\1.fas/p')
        
        # Copy the file to the destination directory
        cp "$file" "$dest_dir/$new_name"

	# Rename the sequence within the file
        sed -i "1s/>.*/>${new_name%.fas}/" "$dest_dir/$new_name"
        
        echo "File copied and renamed: $new_name"
    fi
done



echo "Process completed."
