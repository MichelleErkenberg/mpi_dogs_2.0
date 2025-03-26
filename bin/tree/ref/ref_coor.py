import sys
import csv
from Bio import AlignIO

def process_alignment(aln_file, output_file, ref_id, file_format):
    try:
        alignment = AlignIO.read(aln_file, file_format)
    except Exception as e:
        print(f"Error reading alignment file: {e}")
        sys.exit(1)

    sequences = {record.id: str(record.seq) for record in alignment}

    if ref_id not in sequences:
        print(f"Error: Reference sequence with ID '{ref_id}' not found in the alignment.")
        sys.exit(1)

    ref_seq = sequences[ref_id]

    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)

        header = ['Position', f'Reference ({ref_id})'] + [seq_id for seq_id in sequences if seq_id != ref_id]
        writer.writerow(header)

        position = 1
        for i, ref_base in enumerate(ref_seq):
            if ref_base != '-':
                row = [position, ref_base]
                position += 1
            else:
                row = ['', ref_base]  # Empty string for position when there's a gap

            for seq_id in sequences:
                if seq_id != ref_id:
                    row.append(sequences[seq_id][i])
            writer.writerow(row)

    print(f"Output written to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python script.py <alignment_file> <output_file> <reference_sequence_id> <format>")
        print("Supported formats: fasta, clustal, phylip")
        sys.exit(1)

    aln_file = sys.argv[1]
    output_file = sys.argv[2]
    ref_id = sys.argv[3]
    file_format = sys.argv[4]

    process_alignment(aln_file, output_file, ref_id, file_format)