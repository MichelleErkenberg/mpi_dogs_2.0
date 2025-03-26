#!/bin/bash

# Check if enough arguments are provided
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <input_file> <output_file> <column1> [column2] ..."
    exit 1
fi

# first two arguments are stored as input and output file names
input_file="$1"
output_file="$2"
# Shift the first two arguments out of the list 
shift 2

# Define the columns to extract; first column is fixed and get always extracted (reference coordinates); and additional arguments can be extracted (defined in the real run of the script)
columns_to_extract=("1" "$@")

# Function to extract columns from a CSV file
extract_columns() {
    local columns=$(IFS=,; echo "${columns_to_extract[*]}")
    
    # Use csvcut to extract the specified columns and save directly to the output file
    csvcut -c "$columns" "$input_file" > "$output_file"
    
    echo "Extraction completed. Result saved in $output_file"
}

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file $input_file not found."
    exit 1
fi

# Perform the extraction
extract_columns

# Display the first few lines of the output file
echo "First 10 lines of output file:"
head -n 10 "$output_file"