#!/bin/bash

# Set the working directory
work_dir="$BASE_PATH/data/dog_samples/msa"
OUTDIR="$BASE_PATH/data/dog_samples/diff"

cd "$work_dir" || exit 1

#Set the specific input file name

input_file="combined_pub.ref.aln"

# Set the desired length
desired_length=16138
# Set the number of bases per line (adjust this to match your original files)
bases_per_line=60

# Function to get the actual sequence name from the ALN file
get_seq_name() {
    head -n 1 "$1" | sed 's/^>//' | awk '{print $1}' | sed 's/:[0-9-]*$//'
}

# Function to format ALN sequence
format_aln() {
    local input_file="$1"
    local output_file="$2"

 # Process each sequence in the input file
    awk -v l=$desired_length -v bpl=$bases_per_line '
    /^>/ {
        if (NR != 1) {
            print substr(seq, 1, l)
        }
        print $0
        seq = ""
        next
    }
    {
        seq = seq $0
    }
    END {
        print substr(seq, 1, l)
    }' "$input_file" | awk -v bpl=$bases_per_line '
    /^>/ {print; next}
    {
        for (i=1; i<=length($0); i+=bpl)
            print substr($0, i, bpl)
    }' > "$output_file"
}

    # Check if the specific file exists
if [ -f "$input_file" ]; then
    # Extract the filename without extension
    base_name="${input_file%.aln}"


    # Format the trimmed ALN file
    format_aln "$input_file" "${work_dir}/${base_name}.trimmed.aln" "$seq_name"

    # move output file to OUTDIR
    mv "${base_name}.trimmed.aln" "$OUTDIR/${base_name}.trimmed.aln"

    echo "File $input_file has been trimmed to ${desired_length} bases and saved as ${OUTDIR}/${base_name}.trimmed.aln"
else
    echo "Error: Input file $input_file not found."
fi

