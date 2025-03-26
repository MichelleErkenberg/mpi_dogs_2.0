import csv
import argparse
import os
import re

def sanitize_filename(name):
    # Replace special characters with underscore and remove leading/trailing spaces
    return re.sub(r'[^\w\-]', '_', name.strip())

def process_files(csv_file, txt_file, output_dir):
    # Read the TXT file and create a dictionary with sample_id, office, x, and y
    sample_data = {}
    offices = set()
    with open(txt_file, 'r') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            office = row['office'].strip()
            if office:  # Only process non-empty office names
                offices.add(office)
                sample_data[row['sample_id']] = {
                    'office': office,
                    'x': row['x'],
                    'y': row['y']
                }

    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Process the CSV file and write results for each office
    for office in offices:
        safe_office_name = sanitize_filename(office)
        output_file = os.path.join(output_dir, f"{safe_office_name}.csv")
        with open(csv_file, 'r') as f_in, open(output_file, 'w', newline='') as f_out:
            reader = csv.DictReader(f_in)
            fieldnames = ['Sample', 'office', 'x', 'y'] + reader.fieldnames[1:]
            writer = csv.DictWriter(f_out, fieldnames=fieldnames)
            writer.writeheader()

            for row in reader:
                if row['Sample'] in sample_data and sample_data[row['Sample']]['office'] == office:
                    new_row = {
                        'Sample': row['Sample'],
                        'office': office,
                        'x': sample_data[row['Sample']]['x'],
                        'y': sample_data[row['Sample']]['y']
                    }
                    new_row.update({k: row[k] for k in reader.fieldnames[1:]})
                    writer.writerow(new_row)

        print(f"Results for '{office}' have been saved to {output_file}.")

    print(f"Total number of offices processed: {len(offices)}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process CSV and TXT files and create separate CSV files for each office.")
    parser.add_argument("csv_file", help="Path to the CSV file")
    parser.add_argument("txt_file", help="Path to the TXT file")
    parser.add_argument("output_dir", help="Path to the output directory for CSV files")

    args = parser.parse_args()

    process_files(args.csv_file, args.txt_file, args.output_dir)