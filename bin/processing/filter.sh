#!/bin/bash

# Path
bam_dir="$BASE_PATH/data/dog_samples/processing/bam_files"
chrM_dir="$BASE_PATH/data/dog_samples/processing/ChrM"

### Step 1: ChrM Extraction ###
mkdir -p "$chrM_dir"
echo "Starting ChrM extraction..."
for bam_file in $bam_dir/*.bam; do          
  base_name=$(basename "$bam_file" .bam)
  samtools view -b "$bam_file" "chrM" > "$chrM_dir/${base_name}_ChrM.bam"
  echo "Processed: $bam_file → $chrM_dir/${base_name}_ChrM.bam"
done

### Step 2: MAPQ25 Filtering ###
mkdir -p "$chrM_dir/MQ25"
echo -e "\nStarting MAPQ25 filtering..."
for bam_file in $chrM_dir/*.bam; do
  filename=$(basename "$bam_file" .bam)
  samtools view -bq 25 "$bam_file" > "$chrM_dir/MQ25/${filename}_MQ25.bam"
  samtools index "$chrM_dir/MQ25/${filename}_MQ25.bam"
  echo "Processed: $bam_file → $chrM_dir/MQ25/${filename}_MQ25.bam"
done

### Step 3: Deduplication (modernere Methode) ###
mkdir -p "$chrM_dir/MQ25/dedup"  # Pfadkorrektur: "ChrM/ChrM/" → "ChrM/"
echo -e "\nStarting deduplication..."
for bam_file in $chrM_dir/MQ25/*.bam; do  # Anführungszeichen entfernt
  filename=$(basename "$bam_file" .bam)
  samtools rmdup "$bam_file" "$chrM_dir/MQ25/dedup/${filename}_dedup.bam"
  samtools index "$chrM_dir/MQ25/dedup/${filename}_dedup.bam"
done
