#!/bin/bash

# Path to the extraction script and reference coordinate file
extract_script="$MPI_BASE_PATH/bin/ref/extract.sh"
FILE="$MPI_BASE_PATH/data/dog_samples/ref/ref_coordinates.csv"
OUTDIR="$MPI_BASE_PATH/data/dog_samples/ref"

while true; do

read -p "Use all dogs for office 1 and 2 OR filtering data to exclude dogs (raw/exclude)?: " x

if [[ "$x" == "raw" ]]; then
    # Creating directories for dog office 1 and 2
    mkdir -p "$OUTDIR/all_dogs"          #all of our mpi dogs included
    mkdir -p "$OUTDIR/office_container"  #office 1
    mkdir -p "$OUTDIR/office_thorA.lily" #office 2

    # extraction for all of your dogs
    bash "$extract_script" "$FILE" "$OUTDIR/all_dogs/all_dogs.csv" "Heidi" "Vito" "Urza" "Fritzy" "Cami" "ThorA" "ThorB" "Anda" "Lily" "Charlie"

    # The references position is always extracted 
    # First extraction for office 1 and 4 dogs
    bash "$extract_script" "$FILE" "$OUTDIR/office_container/4dogs.csv" "Heidi" "Vito" "Urza" "Fritzy"
    # Second extraction for office 1 and 5 dogs (Cami as an outgroup)
    bash "$extract_script" "$FILE" "$OUTDIR/office_container/5dogs.csv" "Heidi" "Vito" "Urza" "Fritzy" "Cami"
    echo "Extractions for office 1 finished"

    # First extraction for office 2 with 2 dogs
    bash "$extract_script" "$FILE" "$OUTDIR/office_thorA.lily/2dogs.csv" "Lily" "ThorA"
    # Second extraction for office 2 with 3 dogs (Cami as an outgroup) 
    bash "$extract_script" "$FILE" "$OUTDIR/office_thorA.lily/3dogs.csv" "Lily" "ThorA" "Cami"
    echo "Extractions for office 2 finished"

    # Second step - comparing dogs
    echo "Continue to compare each dog office dog against each other."

    #all dogs
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs.csv" "$OUTDIR/all_dogs/all_dogs.Heidi.csv" "Heidi"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs.csv" "$OUTDIR/all_dogs/all_dogs.Vito.csv" "Vito"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs.csv" "$OUTDIR/all_dogs/all_dogs.Urza.csv" "Urza"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs.csv" "$OUTDIR/all_dogs/all_dogs.Fritzy.csv" "Fritzy"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs.csv" "$OUTDIR/all_dogs/all_dogs.Cami.csv" "Cami"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs.csv" "$OUTDIR/all_dogs/all_dogs.ThorA.csv" "ThorA"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs.csv" "$OUTDIR/all_dogs/all_dogs.ThorB.csv" "ThorB"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs.csv" "$OUTDIR/all_dogs/all_dogs.Lily.csv" "Lily"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs.csv" "$OUTDIR/all_dogs/all_dogs.Anda.csv" "Anda"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs.csv" "$OUTDIR/all_dogs/all_dogs.Charlie.csv" "Charlie"

    # Office 1
    # Comparing all the dogs in office 1 for 4 dogs
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/4dogs.csv" "$OUTDIR/office_container/4dogs.Heidi.csv" "Heidi"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/4dogs.csv" "$OUTDIR/office_container/4dogs.Vito.csv" "Vito"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/4dogs.csv" "$OUTDIR/office_container/4dogs.Urza.csv" "Urza"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/4dogs.csv" "$OUTDIR/office_container/4dogs.Fritzy.csv" "Fritzy"

    # Comparing all the dogs in office 1 for 5 dogs
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/5dogs.csv" "$OUTDIR/office_container/5dogs.Heidi.csv" "Heidi"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/5dogs.csv" "$OUTDIR/office_container/5dogs.Vito.csv" "Vito"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/5dogs.csv" "$OUTDIR/office_container/5dogs.Urza.csv" "Urza"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/5dogs.csv" "$OUTDIR/office_container/5dogs.Fritzy.csv" "Fritzy"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/5dogs.csv" "$OUTDIR/office_container/5dogs.Cami.csv" "Cami"

    # Office 2
    # Comparing all the dogs in office 2 for 2 dogs
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/2dogs.csv" "$OUTDIR/office_thorA.lily/2dogs.Lily.csv" "Lily"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/2dogs.csv" "$OUTDIR/office_thorA.lily/2dogs.ThorA.csv" "ThorA"

    # Comparing all the dogs in office 2 for 3 dogs
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/3dogs.csv" "$OUTDIR/office_thorA.lily/3dogs.Lily.csv" "Lily"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/3dogs.csv" "$OUTDIR/office_thorA.lily/3dogs.ThorA.csv" "ThorA"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/3dogs.csv" "$OUTDIR/office_thorA.lily/3dogs.Cami.csv" "Cami"

elif [[ "$x" == "exclude" ]]; then
    read -p "Please decide whether to keep ThorA or Anda and ThorB or Cami: " a b 
    echo "a='$a'" > "$MPI_BASE_PATH/tmp/user_input.sh"
    echo "b='$b'" >> "$MPI_BASE_PATH/tmp/user_input.sh" #to use this variables in other scripts
    # Extracting all dogs (always decide between closely related ones)
    mkdir -p "$OUTDIR/all_dogs_with_${a}_${b}"
    bash "$extract_script" "$FILE" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_with_${a}_${b}.csv" "$a" "$b" "Fritzy" "Heidi" "Urza" "Vito" "Lily" "Charlie" 

    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_with_${a}_${b}.csv" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.${a}.csv" "$a"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_with_${a}_${b}.csv" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.${b}.csv" "$b"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_with_${a}_${b}.csv" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Heidi.csv" "Heidi"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_with_${a}_${b}.csv" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Fritzy.csv" "Fritzy"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_with_${a}_${b}.csv" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Vito.csv" "Vito"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_with_${a}_${b}.csv" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Urza.csv" "Urza"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_with_${a}_${b}.csv" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Lily.csv" "Lily"
    python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_with_${a}_${b}.csv" "$OUTDIR/all_dogs_with_${a}_${b}/all_dogs_${a}${b}.Charlie.csv" "Charlie"

    read -p "Also merge Lily into Anda/ThorA data (n/y)?: " l
    if [[ "$l" == "y" ]]; then
        mkdir -p "$OUTDIR/all_dogs_${a}_${b}_without_Lily"
        bash "$extract_script" "$FILE" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}_${b}_without_Lily.csv" "$a" "$b" "Fritzy" "Heidi" "Urza" "Vito" "Charlie" 
        echo "Extraction without Lily and $a and $b completed."

        python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}_${b}_without_Lily.csv" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.${a}.csv" "$a"
        python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}_${b}_without_Lily.csv" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.${b}.csv" "$b"
        python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}_${b}_without_Lily.csv" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.Heidi.csv" "Heidi"
        python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}_${b}_without_Lily.csv" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.Fritzy.csv" "Fritzy"
        python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}_${b}_without_Lily.csv" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.Vito.csv" "Vito"
        python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}_${b}_without_Lily.csv" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.Urza.csv" "Urza"
        python3 "$MPI_BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}_${b}_without_Lily.csv" "$OUTDIR/all_dogs_${a}_${b}_without_Lily/all_dogs_${a}${b}woL.Charlie.csv" "Charlie"
    fi
else
    echo "Invalid option. Please choose 'raw' or 'exclude'."
fi

read -p "Continue filtering (y/n)?: " q
if [[ "$q" != "y" ]]; then
    break
fi

done
