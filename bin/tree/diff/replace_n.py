import csv
import sys

def process_csv(names_file, input_csv, output_csv):
    # Read the names file
    with open(names_file, 'r') as f:
        names = set(f.read().splitlines())
    print(f"Names read from file: {names}")

    # Read and process the CSV file
    with open(input_csv, 'r') as infile, open(output_csv, 'w', newline='') as outfile:
        reader = csv.reader(infile)
        writer = csv.writer(outfile)
        
        # Read the header
        header = next(reader)
        writer.writerow(header)
        print(f"Header: {header}")
        
        # Process the header to identify names and their associated columns
        name_columns = {}
        current_name = None
        for i, cell in enumerate(header):
            if cell in names:
                current_name = i
                name_columns[i] = []
            elif current_name is not None:
                name_columns[current_name].append(i)
        print(f"Name columns: {name_columns}")
        
        # Process the data rows
        for row_num, row in enumerate(reader, start=1):
            new_row = row.copy()
            for name_col, associated_cols in name_columns.items():
                if associated_cols and new_row[name_col] == 'n':
                    ref_values = [row[col] for col in associated_cols if col < len(row)]
                    valid_refs = [v for v in ref_values if v in ['a', 't', 'c', 'g']]
                    
                    if valid_refs:
                        unique_valid_refs = set(valid_refs)
                        if len(unique_valid_refs) == 1:
                            new_row[name_col] = valid_refs[0]
                            print(f"Row {row_num}, Column {name_col}: Replaced 'n' with {valid_refs[0]}")
            
            writer.writerow(new_row)
            if row_num <= 5:  # Print first 5 rows for debugging
                print(f"Row {row_num}: {new_row}")

    print(f"Processing completed. Result in '{output_csv}'")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <names_file> <input_csv> <output_csv>")
        sys.exit(1)
    
    names_file = sys.argv[1]
    input_csv = sys.argv[2]
    output_csv = sys.argv[3]
    
    process_csv(names_file, input_csv, output_csv)
