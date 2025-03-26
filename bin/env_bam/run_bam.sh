#!/bin/bash
source "$BASE_PATH/tmp/user_input.sh"

# Creating and defining new env_bam file as csv output file
mkdir -p "$BASE_PATH/data/dog_samples/env_bam"
env_bam="$BASE_PATH/data/dog_samples/env_bam"
export bam_file="$BASE_PATH/data/env_samples/quicksand.v2/out/Canidae/fixed/3-deduped/"
office_file="$BASE_PATH/data/dog_samples/ref"


while true; do
    read -p "Only compare offices or excluded files (raw/exclude)?: " e 
    if [[ "$e" == "raw" ]]; then
        # All dogs office files
        declare -A dogs=(
            ["Heidi"]="$office_file/office_container/5dogs.Heidi.csv"
            ["Fritzy"]="$office_file/office_container/5dogs.Fritzy.csv"
            ["Vito"]="$office_file/office_container/5dogs.Vito.csv"
            ["Urza"]="$office_file/office_container/5dogs.Urza.csv"
            ["Cami"]="$office_file/office_container/5dogs.Cami.csv"
            ["Lily"]="$office_file/office_thorA.lily/3dogs.Lily.csv"
            ["ThorA"]="$office_file/office_thorA.lily/3dogs.ThorA.csv" 
        )

        # Loop for all dogs
        for dog in "${!dogs[@]}"; do
            input_file="${dogs[$dog]}"
            output_file="$env_bam/all_dogs/all_env_${dog}.csv"
            python3 bin/env_bam/bam_finder_new.py "$input_file" "$office_file/ref_coordinates.csv" "$bam_file" "$output_file" "$dog"
        done

    elif [[ "$e" == "exclude" ]]; then
        # All excluded files
        declare -A dogs_ex=(
            ["$a"]="$office_file/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.${a}.csv"
            ["$b"]="$office_file/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.${b}.csv" 
            ["Heidi"]="$office_file/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Heidi.csv" 
            ["Fritzy"]="$office_file/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Fritzy.csv"
            ["Vito"]="$office_file/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Vito.csv" 
            ["Urza"]="$office_file/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Urza.csv" 
            ["Lily"]="$office_file/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Lily.csv" 
            ["Charlie"]="$office_file/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Charlie.csv" 
        )

        mkdir -p "$env_bam/all_dogs_with_${a}_${b}"
        # Loop for all dogs
        for dog_ex in "${!dogs_ex[@]}"; do
            input_file="${dogs_ex[$dog_ex]}"
            output_file="$env_bam/all_dogs_with_${a}_${b}/all_env_${dog_ex}.csv"
            python3 bin/env_bam/bam_finder_new.py "$input_file" "$office_file/ref_coordinates.csv" "$bam_file" "$output_file" "$dog_ex"
        done

        # Lily
        read -p "Also process data without Lily (n/y)?: " l
        if [[ "$l" == "y" ]]; then
            mkdir -p "$env_bam/all_dogs_with_${a}_${b}_without_Lily"

            # All excluded files without lily
            declare -A dogs_exl=(
                ["$a"]="$office_file/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.${a}.csv"
                ["$b"]="$office_file/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.${b}.csv" 
                ["Heidi"]="$office_file/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.Heidi.csv" 
                ["Fritzy"]="$office_file/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.Fritzy.csv"
                ["Vito"]="$office_file/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.Vito.csv" 
                ["Urza"]="$office_file/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.Urza.csv" 
                ["Charlie"]="$office_file/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.Charlie.csv" 
            )

            # Loop for all dogs without lily
            for dog_exl in "${!dogs_exl[@]}"; do
                input_file="${dogs_exl[$dog_exl]}"
                output_file="$env_bam/all_dogs_with_${a}_${b}_without_Lily/all_env_${dog_exl}.csv"
                python3 bin/env_bam/bam_finder_new.py "$input_file" "$office_file/ref_coordinates.csv" "$bam_file" "$output_file" "$dog_exl"
            done
        fi
    else
        echo "Invalid option. Please choose 'raw' or 'exclude'."
        continue
    fi

    read -p "Continue searching for SNPs (y/n)?: " s
    if [[ "$s" != "y" ]]; then
        break
    fi
done
