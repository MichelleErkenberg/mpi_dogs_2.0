#!/bin/bash

# Change to the correct directory
cd "$BASE_PATH/data/dog_samples"

for file in s_all_*_S*.bam; do
    # Extract the dog name
    newname=$(echo "$file" | sed 's/s_all_\(.*\)_S.*/\1/')
    
    # Add .bam extension
    newname="${newname}.bam"
    
    # Rename the file
    mv "$file" "$newname"
    
    echo "Renamed: $file -> $newname"
    
    # Remove the old file (this line is actually not needed since we're renaming)
    rm -f "$file"
    
    echo "Old file removed: $file"
done
