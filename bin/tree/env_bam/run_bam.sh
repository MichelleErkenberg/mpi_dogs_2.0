#!/bin/bash

#creating and define new env_bam file as csv output file
mkdir -p "$BASE_PATH/data/dog_samples/env_bam"
env_bam="$BASE_PATH/data/dog_samples/env_bam"
export bam_file="$BASE_PATH/data/env_samples/quicksand.v2/out/Canidae/fixed/3-deduped/"
office_file="$BASE_PATH/data/dog_samples/ref/"

#creating *.bam.bai data for every bam to process
#bash env_bam/bam_to_bai.sh


#finding 
python3 env_bam/bam_finder_new.py "$office_file/office_container/5dogs.Heidi.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_Heidi.csv" "Heidi"
python3 env_bam/bam_finder_new.py "$office_file/office_container/5dogs.Fritzy.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_Fritzy.csv" "Fritzy"
python3 env_bam/bam_finder_new.py "$office_file/office_container/5dogs.Vito.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_Vito.csv" "Vito"
python3 env_bam/bam_finder_new.py "$office_file/office_container/5dogs.Urza.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_Urza.csv" "Urza"
python3 env_bam/bam_finder_new.py "$office_file/office_container/5dogs.Cami.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_Cami.csv" "Cami"

python3 env_bam/bam_finder_new.py "$office_file/office_thorA.lily/3dogs.Lily.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_Lily.csv" "Lily"
python3 env_bam/bam_finder_new.py "$office_file/office_thorA.lily/3dogs.ThorA.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_ThorA.csv" "ThorA"


python3 env_bam/bam_finder_new.py "$office_file/office_anda.charlie/3dogs.Anda.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_Anda.csv" "Anda"
python3 env_bam/bam_finder_new.py "$office_file/office_anda.charlie/3dogs.Charlie.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_Charlie.csv" "Charlie"

python3 env_bam/bam_finder_new.py "$office_file/office_anda.charlie/3dogs.Anda_Vito.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_Anda_Vito.csv" "Anda"

python3 env_bam/bam_finder_new.py "$office_file/all_dogs/all_dogs_AC.Anda.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_AC.Anda.csv" "Anda"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs/all_dogs_AC.Cami.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_AC.Cami.csv" "Cami"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs/all_dogs_AC.Charlie.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_AC.Charlie.csv" "Charlie"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs/all_dogs_AC.Fritzy.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_AC.Fritzy.csv" "Fritzy"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs/all_dogs_AC.Heidi.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_AC.Heidi.csv" "Heidi"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs/all_dogs_AC.Lily.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_AC.Lily.csv" "Lily"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs/all_dogs_AC.Urza.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_AC.Urza.csv" "Urza"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs/all_dogs_AC.Vito.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_AC.Vito.csv" "Vito"


mkdir -p "$env_bam/all_env_ACwoL"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs_AC_without_Lily/all_dogs_ACwoL.Anda.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_ACwoL/all_env_ACwoL.Anda.csv" "Anda"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs_AC_without_Lily/all_dogs_ACwoL.Cami.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_ACwoL/all_env_ACwoL.Cami.csv" "Cami"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs_AC_without_Lily/all_dogs_ACwoL.Charlie.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_ACwoL/all_env_ACwoL.Charlie.csv" "Charlie"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs_AC_without_Lily/all_dogs_ACwoL.Fritzy.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_ACwoL/all_env_ACwoL.Fritzy.csv" "Fritzy"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs_AC_without_Lily/all_dogs_ACwoL.Heidi.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_ACwoL/all_env_ACwoL.Heidi.csv" "Heidi"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs_AC_without_Lily/all_dogs_ACwoL.Urza.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_ACwoL/all_env_ACwoL.Urza.csv" "Urza"
python3 env_bam/bam_finder_new.py "$office_file/all_dogs_AC_without_Lily/all_dogs_ACwoL.Vito.csv" "$office_file/ref_coordinates.csv" "$bam_file" "$env_bam/all_env_ACwoL/all_env_ACwoL.Vito.csv" "Vito"

