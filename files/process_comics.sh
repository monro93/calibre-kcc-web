#!/bin/bash

# Variables
OUTPUT_DIR="/comics_to_add_to_db"
CALIBRE_DB="/database"
CONFIG_FILE="/kcc_worker_config.yaml"

# Ensure necessary tools are available
if ! command -v /lsiopy/bin/kcc-c2e &>/dev/null; then
    echo "[kcc_worker][error] Kindle Comic Converter (kcc) is not installed." >&2
    exit 1
fi

if ! command -v calibredb &>/dev/null; then
    echo "[kcc_worker][error] calibredb command is not installed." >&2
    exit 1
fi

# Check yaml file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[kcc_worker][error] Configuration file not found: $CONFIG_FILE. Exiting." >&2
    exit 1
fi

# Parse kcc_params_by_folder from YAML
mapfile -t KCC_PARAMS_BY_FOLDER < <(yq eval -j '.kcc_params_by_folder' "$CONFIG_FILE" | jq -c '.[]')

if [[ ${#KCC_PARAMS_BY_FOLDER[@]} -eq 0 ]]; then
    echo "[kcc_worker][error] No folder-to-params mappings found in configuration file. Exiting." >&2
    exit 1
fi


# Process each folder-to-params mapping
for entry in "${KCC_PARAMS_BY_FOLDER[@]}"; do
    # Extract fields
    folder=$(echo "$entry" | jq -r '.folder // empty')
    params=$(echo "$entry" | jq -r '.params // empty')
    delete_after=$(echo "$entry" | jq -r '.delete_after // false')

    # Validate folder and params
    if [[ -z "$folder" || -z "$params" ]]; then
        echo "[kcc_worker][error] Invalid mapping in configuration file: $entry. 'folder' and 'params' are required. Skipping." >&2
        continue
    fi

    # Find all matching files in this folder
    find "$folder" -type f \( -name '*.cbz' -o -name '*.cbr' -o -name '*.zip' \) | while read -r input_file; do
        # Calculate the output file path
        output_file="$OUTPUT_DIR${input_file#$folder}"
        output_dir=$(dirname "$output_file")

        # Create output directory if it doesn't exist
        mkdir -p "$output_dir"

        # Run kcc with dynamic parameters
        if /lsiopy/bin/kcc-c2e $params --output "$output_dir" "$input_file"; then
            echo "[kcc_worker][info] Converted: $input_file"

            # Delete the original file if delete_after is true
            if [[ "$delete_after" == "true" ]]; then
                rm -f "$input_file"
                echo "[kcc_worker][info] Deleted: $input_file"
            fi
        else
            echo "[kcc_worker][warning] Error converting $input_file. Skipping." >&2
        fi
    done
done

# Add processed comics to the Calibre database
echo "Adding comics to Calibre database..."
if calibredb add "$OUTPUT_DIR" --library-path "$CALIBRE_DB"; then
    echo "[kcc_worker][info] Comics added to the Calibre database successfully."
else
    echo "[kcc_worker][error] Error adding comics to the Calibre database." >&2
    exit 1
fi

# Clean up the output directory
echo "Cleaning up processed comics..."
if rm -rf "$OUTPUT_DIR"/*; then
    echo "[kcc_worker][info] Processed comics cleaned up successfully."
else
    echo "[kcc_worker][error] Error cleaning up processed comics." >&2
    exit 1
fi

echo "[kcc_worker][info] All tasks completed successfully!"
