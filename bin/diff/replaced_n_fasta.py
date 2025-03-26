import argparse
import csv

def read_csv(filename):
    """
    Read the CSV file and organize data by sequence.
    
    The CSV file is expected to have positions in the first column
    and sequence data in subsequent columns.
    """
    with open(filename, 'r') as f:
        reader = csv.reader(f)
        headers = next(reader)  # Read the header row
        sequences = {headers[i]: [] for i in range(1, len(headers))}
        
        for row in reader:
            for i in range(1, len(row)):
                value = row[i]
                # Store all values including 'n' and '-'
                sequences[headers[i]].append(value)
    
    # Convert lists to strings
    for key in sequences:
        sequences[key] = ''.join(sequences[key])
    
    return sequences

def write_fasta(filename, sequences):
    """Write the sequences to a FASTA file."""
    with open(filename, 'w') as f:
        for header, sequence in sequences.items():
            f.write(f">{header}\n")
            # Split the sequence into 60-character lines
            for i in range(0, len(sequence), 60):
                f.write(sequence[i:i+60] + '\n')

def main():
    # Set up command-line argument parsing
    parser = argparse.ArgumentParser(description="Create FASTA File from CSV Data")
    parser.add_argument("csv_file", help="Path to CSV file with sequences")
    parser.add_argument("output_file", help="Path to output FASTA file")
    args = parser.parse_args()

    # Read input files
    sequences = read_csv(args.csv_file)

    # Write to FASTA file
    write_fasta(args.output_file, sequences)

    print(f"FASTA file has been saved to {args.output_file}.")

if __name__ == "__main__":
    main()

