import pysam
import csv
import argparse
import glob
import os
import re

def sort_sample_names(name):
    match = re.search(r'sample_(\d+)', name)
    return int(match.group(1)) if match else 0

def process_pileup(pileup, pos, match_count, total_count, nucleotides_at_position, expected_nucleotide):
    for pileup_read in pileup.pileups:
        if not pileup_read.is_del and not pileup_read.is_refskip:
            query_pos = pileup_read.query_position
            if query_pos is not None:
                nucleotide = pileup_read.alignment.query_sequence[query_pos].upper()
                nucleotides_at_position[nucleotide] = nucleotides_at_position.get(nucleotide, 0) + 1
                total_count += 1
                if nucleotide == expected_nucleotide:
                    match_count += 1

    return match_count, total_count, nucleotides_at_position

parser = argparse.ArgumentParser(description="Search multiple BAM files using positions from a CSV file.")
parser.add_argument('input_csv', type=str, help='The input CSV file containing positions and expected nucleotides.')
parser.add_argument('reference_csv', type=str, help='The reference CSV file containing positions and reference bases.')
parser.add_argument('bam_directory', type=str, help='The directory containing BAM files.')
parser.add_argument('output_file', type=str, help='The output CSV file.')
parser.add_argument('query_column', type=str, help='The name of the column to query for expected nucleotides.')
parser.add_argument('--chromosome', type=str, default=None, help='The chromosome name to use. If not provided, will use the first chromosome in each BAM file.')

args = parser.parse_args()

positions = []
other_mpi_dogs_nucleotides = {}
with open(args.input_csv, mode='r') as infile:
    reader = csv.DictReader(infile)
    for row in reader:
        if row['Position']:
            try:
                position = int(row['Position'])
                expected_nucleotide = row[args.query_column].upper()
                positions.append((position, expected_nucleotide))
                
                # Collect nucleotides from other columns
                other_nucleotides = set()
                for col, value in row.items():
                    if col != 'Position' and col != args.query_column and value.strip():
                        other_nucleotides.add(value.upper())
                other_mpi_dogs_nucleotides[position] = ' '.join(sorted(other_nucleotides))
            except ValueError:
                print(f"Skipping invalid position: {row['Position']}")
        else:
            print("Skipping row with empty position")

reference_bases = {}
with open(args.reference_csv, mode='r') as ref_file:
    ref_reader = csv.DictReader(ref_file)
    for row in ref_reader:
        if row['Position']:
            try:
                position = int(row['Position'])
                reference_base = row['Reference (NC_002008.4)'].upper()
                reference_bases[position] = reference_base
            except ValueError:
                print(f"Skipping invalid position in reference CSV: {row['Position']}")
        else:
            print("Skipping row with empty position in reference CSV")

bam_files = glob.glob(os.path.join(args.bam_directory, "*.bam"))
bam_files.sort(key=lambda x: sort_sample_names(os.path.basename(x)))

with open(args.output_file, mode='w', newline='') as outfile:
    fieldnames = ['Sample', 'Chromosome', 'Position', 'Matches', 'Total Reads', 'Expected Nucleotide',
                  'Nucleotides Found', 'Reference Base', 'Nucleotides Other MPI Dogs']
    writer = csv.DictWriter(outfile, fieldnames=fieldnames)
    writer.writeheader()

    for bam_file in bam_files:
        sample_name = os.path.basename(bam_file).split('.')[0]
        print(f"Processing {sample_name}...")

        samfile = pysam.AlignmentFile(bam_file, "rb")
        
        chromosome = args.chromosome if args.chromosome else next(iter(samfile.references))
        
        for position, expected_nucleotide in positions:
            reference_base = reference_bases.get(position, 'N/A')
            
            try:
                pileup_column = samfile.pileup(chromosome, position - 1, position)

                match_count = 0
                total_count = 0
                nucleotides_at_position = {}

                for pileup in pileup_column:
                    if pileup.pos == position - 1:
                        match_count, total_count, nucleotides_at_position = process_pileup(
                            pileup, position, match_count, total_count,
                            nucleotides_at_position, expected_nucleotide)

                writer.writerow({
                    'Sample': sample_name,
                    'Chromosome': chromosome,
                    'Position': position,
                    'Matches': match_count,
                    'Total Reads': total_count,
                    'Expected Nucleotide': expected_nucleotide,
                    'Nucleotides Found': ' '.join([f"{nuc}:{count}" for nuc,count in nucleotides_at_position.items()]),
                    'Reference Base': reference_base,
                    'Nucleotides Other MPI Dogs': other_mpi_dogs_nucleotides.get(position, '')
                })
            except ValueError as e:
                writer.writerow({
                    'Sample': sample_name,
                    'Chromosome': chromosome,
                    'Position': position,
                    'Matches': 0,
                    'Total Reads': 0,
                    'Expected Nucleotide': expected_nucleotide,
                    'Nucleotides Found': 'Position not found',
                    'Reference Base': reference_base,
                    'Nucleotides Other MPI Dogs': other_mpi_dogs_nucleotides.get(position, '')
                })

        samfile.close()

print(f"Processing complete. Results saved to {args.output_file}")
