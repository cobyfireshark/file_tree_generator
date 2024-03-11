#!/bin/bash
# create_input_file.sh

determine_index() {
    today="$1"

    index=1
    formatted_index=$(printf "%02d" "$index")
    # Loop until a unique directory name is found
    while [[ -d "${running_directory_prefix}/${today}_${formatted_index}" ]]; do
        # Increment index and update formatted index
        ((index++))
        formatted_index=$(printf "%02d" "$index")
    done

    echo "$formatted_index"
}

# Get today's date in the format mm_dd_yyyy
today=$(date +%m_%d_%Y)

# Load the running_directory value from parameters.json
running_directory_prefix=$(jq -r '.running_directory' parameters.json)

unique_index=$(determine_index "$today")

echo "$unique_index"

run_directory="${running_directory_prefix}/${today}_${unique_index}"

# filepath of template for input data from user
template_filepath="input_template.txt"

input_filepath="$run_directory/input.txt"

# Create the run directory named today's date
mkdir -p "$run_directory"
echo "Created directory $run_directory"

# Copy the template file into run directory as input file
cp "$template_filepath" "$input_filepath"

echo "Fill in the input file $input_filepath"

exit 1