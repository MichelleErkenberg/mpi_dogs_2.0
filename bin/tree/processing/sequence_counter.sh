#!/bin/bash

# Define the base directory
base_dir="${BASE_PATH}/data/dog_samples/processing"

# Function to extract the sample name from the filename
extract_sample_name() {
    local filename="$1"
    echo "$filename" | sed -n 's/.*s_all_\(.*\)_S.*/\1/p'
}

# Function to index BAM files (only if .bai doesn't exist)
index_bam_files() {
    local dir="$1"
    find "$dir" -type f -name "*.bam" | while read -r bam_file; do
        if [ ! -f "${bam_file}.bai" ]; then
            samtools index "$bam_file"
        fi
    done
}

# Function to process BAM files in a directory and update results in the CSV file
process_bam_files_in_directory() {
    local dir="$1"
    local output_file="$2"
    local column_name="$3"

    # Check if there are any BAM files in this directory
    if ! ls "$dir"/*.bam 1> /dev/null 2>&1; then
        echo "No BAM files found in $dir"
        return
    fi

    # Add the column name to the header if it doesn't exist
    if ! grep -q "$column_name" "$output_file"; then
        sed -i "1s/$/,$column_name/" "$output_file"
    fi

    # Iterate over all BAM files in the directory
    for bam_file in "$dir"/*.bam; do
        # Count the number of sequences in the BAM file
        sequence_count=$(samtools view -c "$bam_file")
        
        # Extract the sample name
        sample_name=$(extract_sample_name "$(basename "$bam_file")")

        # Update the CSV file
        if grep -q "^$sample_name," "$output_file"; then
            sed -i "/^$sample_name,/ s/$/,$sequence_count/" "$output_file"
        else
            num_columns=$(awk -F, '{print NF}' "$output_file" | head -1)
            padding=$(printf '%0.s,' $(seq 2 $num_columns))
            echo "$sample_name,$padding$sequence_count" >> "$output_file"
        fi

        echo "Processed: $sample_name ($column_name) - Count: $sequence_count"
    done
}


# Function to process bam_files
process_bam_files() {
    local output_file="$base_dir/bam_files_sequence_counts.csv"

    # Check if the output file already exists
    if [[ -f "$output_file" ]]; then
        read -p "bam_files_sequence_counts.csv already exists. Repeat processing? (y/n): " choice
        if [[ $choice != "y" ]]; then
            echo "Skipping bam_files processing."
            return
        fi
    fi

    # Write the header to the CSV file
    echo "Sample,bam_files" > "$output_file"

    echo "Processing bam_files..."
    process_bam_files_in_directory "$base_dir/bam_files" "$output_file" "bam_files"
}

# Function to process ChrM and its subdirectories
process_chrm_files() {
    local output_file="$base_dir/chrm_sequence_counts.csv"

    # Check if the output file already exists
    if [[ -f "$output_file" ]]; then
        read -p "chrm_sequence_counts.csv already exists. Repeat processing? (y/n): " choice
        if [[ $choice != "y" ]]; then
            echo "Skipping ChrM processing."
            return
        fi
    fi

    # Write the header to the CSV file
    echo "Sample" > "$output_file"

    # Process ChrM directory and subdirectories (ChrM, MQ25, MQ25/dedup)
    for subdir in "ChrM" "ChrM/MQ25" "ChrM/MQ25/dedup"; do
        dir="$base_dir/$subdir"
        if [ -d "$dir" ]; then
            echo "Indexing and processing $subdir..."
            index_bam_files "$dir"
            process_bam_files_in_directory "$dir" "$output_file" "$(basename "$subdir")"
        else
            echo "Directory $subdir does not exist. Skipping."
        fi
    done
}

# Main execution

# Process bam_files directory first and create its CSV file.
process_bam_files

# Process ChrM and its subdirectories and create/update its CSV file.
process_chrm_files

echo "Processing complete. Check the CSV files in ${base_dir}"