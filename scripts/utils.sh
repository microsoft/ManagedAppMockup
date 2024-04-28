# Utilities for mockup and cleanup scripts

# Function to read config
read_config() {
    echo "$JSON" | jq -r "$1"
}

# Init checks and setup
init() {
    # Validate config file argument
    local config_file=$1
    if [ ! -f "$config_file" ]; then
        echo "Please specify a valid config.json"
        exit 1
    fi

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "jq is not installed. Please install it e.g., sudo apt install jq"
        exit 1
    fi

    # Substitute environment variables in the JSON config file
    JSON=$(envsubst < "$config_file")

    # Set output destination based on the output_verbose flag
    if [ $(read_config ".output_verbose") = true ]; then
        OUTPUT_DEST="/dev/stdout"   # Redirect to standard output
        ZIP_QUIET_FLAG=""           # Do not silence zip command
    else
        OUTPUT_DEST="/dev/null"     # Silence output
        ZIP_QUIET_FLAG="-q"         # Silence zip command
    fi
}


# Function to exit on error with a message
exit_on_error() {
    echo "Error: $1"
    exit 1
}

# Function to create a zip file from codebase
code2zip() {
    local code_path=$1
    local zip_file=$2
    pushd "$code_path" &> $OUTPUT_DEST || exit_on_error "Failed to change directory to $code_path"

    echo "Creating Zip File"
    zip -rj $ZIP_QUIET_FLAG "$zip_file" . || exit_on_error "Failed to create zip file"
    popd &> $OUTPUT_DEST || exit_on_error "Failed to change directory to original directory"
}

# Function to return the first k characters of the hash of an input string
hash_string() {
    echo -n "$1" | sha256sum | cut -d ' ' -f 1 | cut -c 1-$2
}

# Function to find the last dash in a string and return the substring after it
get_last_dash_substring() {
    local str=$1
    echo "${str##*-}"
}

# Function to set variable in place in json file
modify_json_in_place() {
    local key=$1
    local value=$2
    local json_file=$3
    local tmp_file="/tmp/$(basename $json_file)"
    jq ".$key = \"$value\"" "$json_file" > "$tmp_file" || exit_on_error "Failed to modify json file"
    mv "$tmp_file" "$json_file" || exit_on_error "Failed to move modified json file"
}
