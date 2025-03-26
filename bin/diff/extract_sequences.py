from ete3 import Tree
from Bio import SeqIO
import sys
from collections import defaultdict

def read_relatives(relatives_file):
    """
    Reads manually defined relationships from a file.
    """
    sequence_groups = defaultdict(set)
    with open(relatives_file, 'r') as f:
        for line in f:
            parts = line.strip().split(',')
            if parts:
                main_seq = parts[0]
                relatives = set(parts[1:])
                sequence_groups[main_seq] = relatives.union({main_seq})
    return sequence_groups

def extract_and_organize_sequences(alignment_file, relatives_file, output_file):
    """
    Main function to extract and organize sequences based on manually defined relationships.
    """
    # Read the relationships
    sequence_groups = read_relatives(relatives_file)

    # Load all sequences from the alignment file
    all_sequences = {record.id: record for record in SeqIO.parse(alignment_file, "fasta")}

    # Write organized sequences to the output file
    with open(output_file, 'w') as out_handle:
        for main_seq in sorted(sequence_groups.keys()):
            if main_seq in all_sequences:
                SeqIO.write(all_sequences[main_seq], out_handle, "fasta")
            
            related_seqs = sorted(sequence_groups[main_seq] - {main_seq})
            for seq_id in related_seqs:
                if seq_id in all_sequences:
                    SeqIO.write(all_sequences[seq_id], out_handle, "fasta")

    print(f"Organized sequences have been saved to {output_file}.")

if __name__ == "__main__":
    # Check if the correct number of command-line arguments is provided
    if len(sys.argv) != 4:
        print("Usage: python script.py <alignment_file> <relatives_file> <output_file>")
        sys.exit(1)
    
    # Assign command-line arguments to variables
    alignment_file = sys.argv[1]
    relatives_file = sys.argv[2]
    output_file = sys.argv[3]
    
    # Run the main function
    extract_and_organize_sequences(alignment_file, relatives_file, output_file)

