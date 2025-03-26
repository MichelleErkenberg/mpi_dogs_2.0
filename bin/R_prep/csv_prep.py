import pandas as pd
import sys
import re
import glob

def sort_sample_names(name):
    match = re.search(r'sample_(\d+)', name)
    return int(match.group(1)) if match else 0

def process_csv(input_pattern, output_file, threshold):
    input_files = glob.glob(input_pattern)
    
    all_results = []
    
    for file in input_files:
        env_name = re.search(r'all_env_(.+)\.csv', file).group(1)
        
        df = pd.read_csv(file)
        
        # Group the data by Sample and sum Matches and Total Reads
        grouped = df.groupby('Sample').agg({'Matches': 'sum', 'Total Reads': 'sum'})
        
        # Apply threshold to Total Reads
        grouped = grouped[grouped['Total Reads'] >= threshold]
        
        # Calculate the ratio of sums
        results = grouped['Matches'] / grouped['Total Reads']
        
        results_df = pd.DataFrame({env_name: results})
        
        all_results.append(results_df)
    
    final_df = pd.concat(all_results, axis=1)
    
    final_df.sort_index(key=lambda x: x.map(sort_sample_names), inplace=True)
    
    final_df.index.name = 'Sample'
    
    final_df.to_csv(output_file)
    
    print(f"Results have been saved to {output_file}")

# Check if correct number of arguments is provided
if len(sys.argv) != 4:
    print("Usage: python script.py <input_pattern> <output_file> <threshold>")
    sys.exit(1)

# Get input pattern, output file name, and threshold from command line arguments
input_pattern = sys.argv[1]
output_file = sys.argv[2]
threshold = int(sys.argv[3])

# Process the CSV files
process_csv(input_pattern, output_file, threshold)