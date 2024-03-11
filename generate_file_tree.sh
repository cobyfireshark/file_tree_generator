#!/bin/bash
# generate_file_tree.sh

find_highest_index_directory() {
  local pattern="${today}_[0-9][0-9]"  # Pattern for directories with today's date and two-digit index
  local max_index=0
  local highest_dir=""

  # Loop through directories matching the pattern
  for dir in $(find ./${running_directory_prefix} -maxdepth 1 -type d -name "$pattern"); do
    # Extract the index from the directory name
    local index=${dir##*_}

    # Check if index is numeric and greater than max_index
    if [[ "$index" =~ ^[0-9]+$ ]] && (( index > max_index )); then
      max_index="$index"
      highest_dir="$dir"
    fi
  done

  # Return the directory with the highest index
  echo "$highest_dir"
}

# Function to validate input file
validate_input_file() {
    # local input_filepath="$1"
    if [ -z "$input_filepath" ]; then
        echo "Error: No input file provided."
        return 1
    fi

    if [ ! -f "$input_filepath" ]; then
        echo "Error: Input file '$input_filepath' does not exist."
        return 1
    fi
}

read_input_file() {
    # Read the base directory from line 2
    base_directory=$(sed -n '2p' "$input_filepath")

    # Clear files array before populating
    files=()
    # Read the file names starting from line 4 into the array
    while IFS= read -r line; do
        files+=("$line")
    done < <(sed -n '4,$p' "$input_filepath")
}

escape_special_chars() {
    echo "$1" | sed 's/[][\.*^$/]/\\&/g'
}

find_relative_paths() {
    for filename in "${files[@]}"; do

        escaped_filename=$(escape_special_chars "$filename")

        found_filepath=$(find "$base_directory" -type f -name "$escaped_filename" -printf "%P\n")
        if [[ -z "$found_filepath" ]]; then
            echo "File not found: $filename"
        else
            echo "$found_filepath" >> $relative_paths_filepath
        fi
    done
}

# Get today's date in the format mm_dd_yyyy
today=$(date +%m_%d_%Y)

# Load the running_directory value from parameters.json
running_directory_prefix=$(jq -r '.running_directory' parameters.json)

echo "running_directory_prefix ${running_directory_prefix}"

# Find the directory with the highest index for today
working_directory=$(find_highest_index_directory)

echo "Highest index directory set to working directory $working_directory"

input_filename="input.txt"
input_filepath="${working_directory}/${input_filename}"

echo "input filepath: $input_filepath"

# Validate input file
validate_input_file

# Read the input file to base_directory variable and files variable
read_input_file

echo "Base directory set to $base_directory"
# Diagnostic echo to show all files read
echo "Files set to:"
for file in "${files[@]}"; do
    echo "$file"
done

relative_paths_filepath="$working_directory/relative_paths.txt"
>"$relative_paths_filepath"

find_relative_paths

output_filepath="$working_directory/output.txt"
>"$output_filepath"

echo "relative_paths_filepath $relative_paths_filepath and output_filepath $output_filepath"
python3 create_file_tree.py "$relative_paths_filepath" "$output_filepath"