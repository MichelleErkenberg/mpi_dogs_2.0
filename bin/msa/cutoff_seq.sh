#!/bin/bash

# Define the working directory
work_dir="$BASE_PATH/data/dog_samples/msa/mask"

# Ensure the working directory exists
mkdir -p "$work_dir"

# Change to the working directory
cd "$work_dir" || exit

# Set the number of bases per line (adjust this to match your original files)
bases_per_line=60

# Loop through all *.fas files in the current directory
for file in *.fas; do
    # Extract the base name of the file (without .fas)
    basename=${file%.fas}
    
    # Create new filenames for the cutoff output and FAI file
    output_file="${basename}_cutoff.fas"
    fai_file="${basename}_cutoff.fas.fai"
    
    # Process each file
    awk -v basename="$basename" -v line_length="$bases_per_line" -v fai_file="$fai_file" '
    BEGIN { 
        print_seq = 0 
        seq = ""
        seq_name = ""
        offset = 0
    }
    function print_wrapped(s, name) {
        len = length(s)
        lines = int((len + line_length - 1) / line_length)
        last_line_length = len % line_length
        if (last_line_length == 0) last_line_length = line_length

        printf "%s\t%d\t%d\t%d\t%d\n", name, len, offset, line_length, line_length + 1 > fai_file

        for (i = 1; i <= len; i += line_length) {
            print substr(s, i, line_length) > "'$output_file'"
        }
        offset += len + lines  # Add number of bases plus number of newline characters
    }
    {
        if ($0 ~ /^>/) {
            if (print_seq && seq != "") {
                last_pos = match(seq, /(.*)(TTTTAGG|TTTTAAG)/)
                if (last_pos > 0) {
                    trimmed_seq = substr(seq, 1, RSTART + RLENGTH - 1)
                } else {
                   trimmed_seq = seq
                }
                print_wrapped(trimmed_seq, seq_name)
            }
            if ($0 ~ "^>" basename) {
                print_seq = 1
                seq_name = substr($0, 2)  # Remove the ">" from the sequence name
                print $0 > "'$output_file'"
                offset += length($0) + 1  # Add header length plus newline character
            } else {
                print_seq = 0
            }
            seq = ""
        } else if (print_seq) {
            seq = seq $0
        }
    }
    END {
        if (print_seq && seq != "") {
            last_pos = match(seq, /(.*)(TTTTAGG|TTTTAAG)/)
            if (last_pos > 0) {
                trimmed_seq = substr(seq, 1, RSTART + RLENGTH - 1)
            } else {
                trimmed_seq = seq
            }
            print_wrapped(trimmed_seq, seq_name)
        }
    }
    ' "$file"
    
    echo "Processed: $file -> $output_file (with FAI file: $fai_file)"
done
