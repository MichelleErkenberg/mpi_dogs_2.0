import csv
import sys

def is_different(value1, value2):
    """
    Compare two values and return True if they are different.
    This function treats "-" as a regular value.
    """
    return value1 != value2

def find_unique_positions(file_path, reference_column):
    """
    Find positions where the reference column has unique values compared to all other columns.
    
    Args:
    file_path (str): Path to the input CSV file.
    reference_column (str): Name of the column to use as reference.
    
    Returns:
    list: List of row numbers where the reference column has unique values.
    """
    unique_positions = []
    with open(file_path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        headers = reader.fieldnames
        
        if reference_column not in headers:
            raise ValueError(f"Reference column '{reference_column}' not found in CSV.")
        
        # Get all columns except 'Position' and the reference column
        comparison_columns = [col for col in headers if col != 'Position' and col != reference_column]
        
        # Iterate through rows, starting from row 2 (accounting for header)
        for row_num, row in enumerate(reader, start=2):
            reference_value = row[reference_column]
            # Check if reference value is different from all other columns
            if all(is_different(row[col], reference_value) for col in comparison_columns):
                unique_positions.append(row_num)
    
    return unique_positions

# Check command line arguments
if len(sys.argv) < 4:
    print("Usage: python script.py <input_csv_file> <output_csv_file> <reference_column>")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]
reference_column = sys.argv[3]

try:
    # Find unique positions
    unique_positions = find_unique_positions(input_file, reference_column)
    
    print(f"Unique positions for reference column '{reference_column}':")
    print(unique_positions)
    
    # Write unique rows to the output file
    with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
        reader = csv.DictReader(infile)
        writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
        writer.writeheader()
        
        for row_num, row in enumerate(reader, start=2):
            if row_num in unique_positions:
                writer.writerow(row)
    
    print(f"Processing complete. Check '{output_file}' for unique rows.")

except FileNotFoundError:
    print(f"Error: File '{input_file}' not found.")
    sys.exit(1)
except Exception as e:
    print(f"Error processing file: {e}")
    sys.exit(1)

