#!/bin/bash

# Path to the extraction script and reference coordinate file
extract_script="$BASE_PATH/bin/ref/extract.sh"
FILE="$BASE_PATH/data/dog_samples/ref/ref_coordinates.csv"
OUTDIR="$BASE_PATH/data/dog_samples/ref/"

mkdir -p "$OUTDIR/office_container"  #office 1
mkdir -p "$OUTDIR/office_thorA.lily" #office 2
mkdir -p "$OUTDIR/office_anda.charlie" #office 

#the references position is always extracted 
# First extraction for office 1 and 4 dogs
bash "$extract_script" "$FILE" "$OUTDIR/office_container/4dogs.csv" "Heidi" "Vito" "Urza" "Fritzy"

#second extraction for office 1 and 5 dogs (Cami as an outgroup)
bash "$extract_script" "$FILE" "$OUTDIR/office_container/5dogs.csv" "Heidi" "Vito" "Urza" "Fritzy" "Cami"

# first extraction for office 2 with 2 dogs
bash "$extract_script" "$FILE" "$OUTDIR/office_thorA.lily/2dogs.csv" "Lily" "ThorA"

# 2nd extraction for office 2 with 3 dogs (Cami as an outgroup) 
bash "$extract_script" "$FILE" "$OUTDIR/office_thorA.lily/3dogs.csv" "Lily" "ThorA" "Cami"

#Anda as a substitute for ThorA
mkdir -p "$OUTDIR/office_thorA.lily/Anda"
# 3rd extraction for office 2 with 2 dogs, using Anda as a substitute for ThorA
bash "$extract_script" "$FILE" "$OUTDIR/office_thorA.lily/Anda/2dogs_Anda.as.ThorA.csv" "Lily" "Anda"

# 4th extraction for office 2 with 3 dogs (Cami as an outgroup) using Anda as a substitute for ThorA
bash "$extract_script" "$FILE" "$OUTDIR/office_thorA.lily/Anda/3dogs_Anda.as.ThorA.csv" "Lily" "Anda" "Cami"


#office with Anda and Charlie with Cami as an outgroup, Anda = A1a; Charlie = C; and Cami = B

bash "$extract_script" "$FILE" "$OUTDIR/office_anda.charlie/3dogs_Anda_Charlie_Cami.csv" "Anda" "Charlie" "Cami" 

bash "$extract_script" "$FILE" "$OUTDIR/office_anda.charlie/3dogs_Anda_Charlie_Cami_Vito.csv" "Anda" "Charlie" "Vito" "Cami"
echo "All extractions completed."

#extracting all dogs (always decide between closely related once)
mkdir -p "$OUTDIR/all_dogs"
bash "$extract_script" "$FILE" "$OUTDIR/all_dogs/all_dogs_with_Anda_Cami.csv" "Anda" "Cami" "Fritzy" "Heidi" "Urza" "Vito" "Lily" "Charlie" 

mkdir -p "$OUTDIR/all_dogs_AC_without_Lily"
bash "$extract_script" "$FILE" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_AC_without_Lily.csv" "Anda" "Cami" "Fritzy" "Heidi" "Urza" "Vito" "Charlie" 
echo "All extractions completed."

#---------------second step --------------------------------


# Comparing all the dogs in office 1 for 4 dogs
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/4dogs.csv" "$OUTDIR/office_container/4dogs.Heidi.csv" "Heidi"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/4dogs.csv" "$OUTDIR/office_container/4dogs.Vito.csv" "Vito"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/4dogs.csv" "$OUTDIR/office_container/4dogs.Urza.csv" "Urza"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/4dogs.csv" "$OUTDIR/office_container/4dogs.Fritzy.csv" "Fritzy"

# comparing all the dogs in office 1 for 5 dogs
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/5dogs.csv" "$OUTDIR/office_container/5dogs.Heidi.csv" "Heidi"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/5dogs.csv" "$OUTDIR/office_container/5dogs.Vito.csv" "Vito"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/5dogs.csv" "$OUTDIR/office_container/5dogs.Urza.csv" "Urza"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/5dogs.csv" "$OUTDIR/office_container/5dogs.Fritzy.csv" "Fritzy"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_container/5dogs.csv" "$OUTDIR/office_container/5dogs.Cami.csv" "Cami"

# comparing all the dogs in office 2 for 2 dogs
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/2dogs.csv" "$OUTDIR/office_thorA.lily/2dogs.Lily.csv" "Lily"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/2dogs.csv" "$OUTDIR/office_thorA.lily/2dogs.ThorA.csv" "ThorA"

# comparing all the dogs in office 2 for 3 dogs
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/3dogs.csv" "$OUTDIR/office_thorA.lily/3dogs.Lily.csv" "Lily"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/3dogs.csv" "$OUTDIR/office_thorA.lily/3dogs.ThorA.csv" "ThorA"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/3dogs.csv" "$OUTDIR/office_thorA.lily/3dogs.Cami.csv" "Cami"

#Anda as a substitute for ThorA
# comparing all the dogs in office 2 for 2 dogs
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/Anda/2dogs_Anda.as.ThorA.csv" "$OUTDIR/office_thorA.lily/Anda/2dogs_Anda.as.ThorA.Lily.csv" "Lily"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/Anda/2dogs_Anda.as.ThorA.csv" "$OUTDIR/office_thorA.lily/Anda/2dogs_Anda.as.ThorA.Anda.csv" "Anda"

# comparing all the dogs in office 2 for 3 dogs
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/Anda/3dogs_Anda.as.ThorA.csv" "$OUTDIR/office_thorA.lily/Anda/3dogs_Anda.as.ThorA.Lily.csv" "Lily"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/Anda/3dogs_Anda.as.ThorA.csv" "$OUTDIR/office_thorA.lily/Anda/3dogs_Anda.as.ThorA.Anda.csv" "Anda"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_thorA.lily/Anda/3dogs_Anda.as.ThorA.csv" "$OUTDIR/office_thorA.lily/Anda/3dogs_Anda.as.ThorA.Cami.csv" "Cami"

#comparing all the dogs in office 3 for 3 dogs
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_anda.charlie/3dogs_Anda_Charlie_Cami.csv" "$OUTDIR/office_anda.charlie/3dogs.Anda.csv" "Anda"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_anda.charlie/3dogs_Anda_Charlie_Cami.csv" "$OUTDIR/office_anda.charlie/3dogs.Charlie.csv" "Charlie"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_anda.charlie/3dogs_Anda_Charlie_Cami.csv" "$OUTDIR/office_anda.charlie/3dogs.Cami.csv" "Cami"

python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/office_anda.charlie/3dogs_Anda_Charlie_Cami_Vito.csv" "$OUTDIR/office_anda.charlie/3dogs.Anda_Vito.csv" "Anda"

#comparing all dogs (minus closely related once)

python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs_with_Anda_Cami.csv" "$OUTDIR/all_dogs/all_dogs_AC.Anda.csv" "Anda"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs_with_Anda_Cami.csv" "$OUTDIR/all_dogs/all_dogs_AC.Cami.csv" "Cami"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs_with_Anda_Cami.csv" "$OUTDIR/all_dogs/all_dogs_AC.Heidi.csv" "Heidi"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs_with_Anda_Cami.csv" "$OUTDIR/all_dogs/all_dogs_AC.Fritzy.csv" "Fritzy"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs_with_Anda_Cami.csv" "$OUTDIR/all_dogs/all_dogs_AC.Vito.csv" "Vito"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs_with_Anda_Cami.csv" "$OUTDIR/all_dogs/all_dogs_AC.Urza.csv" "Urza"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs_with_Anda_Cami.csv" "$OUTDIR/all_dogs/all_dogs_AC.Lily.csv" "Lily"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs/all_dogs_with_Anda_Cami.csv" "$OUTDIR/all_dogs/all_dogs_AC.Charlie.csv" "Charlie"

python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_AC_without_Lily.csv" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_ACwoL.Anda.csv" "Anda"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_AC_without_Lily.csv" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_ACwoL.Cami.csv" "Cami"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_AC_without_Lily.csv" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_ACwoL.Heidi.csv" "Heidi"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_AC_without_Lily.csv" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_ACwoL.Fritzy.csv" "Fritzy"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_AC_without_Lily.csv" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_ACwoL.Vito.csv" "Vito"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_AC_without_Lily.csv" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_ACwoL.Urza.csv" "Urza"
python3 "$BASE_PATH/bin/ref/diff_finder.py" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_AC_without_Lily.csv" "$OUTDIR/all_dogs_AC_without_Lily/all_dogs_ACwoL.Charlie.csv" "Charlie"