#!/bin/sh

# Define variables
SAMPLE_FILE1="/Users/yac027/Gallo_lab/AGP_skin-gut/data/sample_info/AGP-samples_gut_no_skin.txt" 
SAMPLE_FILE2="/Users/yac027/Gallo_lab/AGP_skin-gut/data/sample_info/AGP-samples_gut_yes_skin.txt"
SAMPLE_FILE="/Users/yac027/Gallo_lab/AGP_skin-gut/data/sample_info/AGP-samples_all.txt" 
CTX1='Woltka-per-genome-WoLr2-3ab352'
CTX2='Woltka-KEGG-Ontology-WoLr2-7dd29a'
CTX3='Woltka-KEGG-Pathway-WoLr2-58cdd3'
TBL_FILE1="/Users/yac027/Gallo_lab/AGP_skin-gut/data/raw_data/per_genome.biom" 
TBL_FILE2="/Users/yac027/Gallo_lab/AGP_skin-gut/data/raw_data/KEGG_ort.biom" 
TBL_FILE3="/Users/yac027/Gallo_lab/AGP_skin-gut/data/raw_data/KEGG_path.biom" 
MD_FILE1="/Users/yac027/Gallo_lab/AGP_skin-gut/data/metadata/per_genome_metadata.tsv"
MD_FILE2="/Users/yac027/Gallo_lab/AGP_skin-gut/data/metadata/kegg_ort_metadata.tsv"
MD_FILE3="/Users/yac027/Gallo_lab/AGP_skin-gut/data/metadata/kegg_path_metadata.tsv"

# Define functions
search_metadata() {
    redbiom search metadata "$1" | grep -vi "blank" > "$2"
}

fetch_samples() {
    redbiom fetch samples \
        --from "$1" \
        --context "$2" \
        --output "$3" \
        --resolve-ambiguities "most-reads"
}

fetch_metadata() {
    redbiom fetch sample-metadata \
        --from "$1" \
        --context "$2" \
        --output "$3" \
        --resolve-ambiguities
}

# Activate conda environment and check redbiom version
source /Users/yac027/mambaforge3/etc/profile.d/conda.sh
conda activate redbiom
redbiom --version

# Search metadata
echo "Searching metadata via redbiom..."
search_metadata "where (qiita_study_id == 10317 and env_package=='human-gut') and (skin_condition == 'I do not have this condition')" "$SAMPLE_FILE1"
search_metadata "where (qiita_study_id == 10317 and env_package=='human-gut') and (skin_condition == 'Diagnosed by a medical professional (doctor, physician assistant)')" "$SAMPLE_FILE2"
cat "$SAMPLE_FILE1" "$SAMPLE_FILE2" > "$SAMPLE_FILE"

# Fetch samples
echo "Grabbing per-genome biom table..."
fetch_samples "$SAMPLE_FILE" "$CTX1" "$TBL_FILE1"
echo "Grabbing KEGG orthology biom table..."
fetch_samples "$SAMPLE_FILE" "$CTX2" "$TBL_FILE2"
echo "Grabbing KEGG pathway biom table..."
fetch_samples "$SAMPLE_FILE" "$CTX3" "$TBL_FILE3"
echo "All biom tables outputed!"

# Fetch metadata
echo "Fetching sample metadata via redbiom..."
fetch_metadata "$SAMPLE_FILE" "$CTX1" "$MD_FILE1"
fetch_metadata "$SAMPLE_FILE" "$CTX2" "$MD_FILE2"
fetch_metadata "$SAMPLE_FILE" "$CTX3" "$MD_FILE3"

echo "Finished!"