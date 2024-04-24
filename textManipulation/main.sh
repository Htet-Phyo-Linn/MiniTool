#!/bin/bash


# Define the functions
DataMasking() {

    read -p "Enter a filename : " file
    echo "You entered: $file"
    # file="info.txt"

    # Define a function to mask credit card numbers
    mask_cc() {
        # Using sed to replace the digits with 'X' except for the last four
        sed -E 's/([0-9]{4}[- ]?){3}([0-9]{4})/XXXX XXXX XXXX \2/g'
    }

    # Define a function to mask social security numbers
    mask_ssn() {
        # Using sed to replace the digits with 'X' except for the last four
        sed -E 's/[0-9]{3}-[0-9]{2}-([0-9]{4})/XXX-XX-\1/g'
    }

    # Define a function to mask email addresses
    mask_email() {
        # Using sed to replace the domain with 'masked.com'
        sed -E 's/([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.)([a-zA-Z]{2,})/\1@masked.com/g'
    }


    # Check if the file exists
    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        exit 1
    fi

    # Mask sensitive information
    echo "Masking sensitive information in $file..."

    masked_content=$(mask_cc < "$file" | mask_ssn | mask_email)

    # Write masked content to a new file
    masked_file="masked_$file"
    echo "$masked_content" > "$masked_file"

    echo "Masked file created: $masked_file"
}




SecureFileDeletion() {
    # Get the file name from command line arguments
    read -p "Enter a filename to delete : " file
    echo "You entered: $file"

    # Check if the file exists
    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        exit 1
    fi

    # Overwrite the file with random data 3 times
    for i in {1..3}; do
        dd if=/dev/urandom of="$file" bs=1M count=10 status=none
    done

    # Delete the file
    rm "$file"

    # Print a message
    echo "File securely deleted: $file"
}




FileIntegrityChecker() {
    # Define the file containing the list of files and their hashes
    read -p "Enter a hash filename : " hash_file
    echo "You entered: $hash_file"

    # Check if the hash file exists
    if [ ! -f "$hash_file" ]; then
        echo "Hash file not found: $hash_file"
        exit 1
    fi

    # Variable to track if any files are modified
    modified=false

    # List to store modified file names
    modified_files=""

    # Loop through each line in the hash file
    while IFS= read -r line; do
        # Split the line into the file name and hash
        expected_hash=$(echo "$line" | cut -d ' ' -f 1)
        file=$(echo "$line" | cut -d ' ' -f 2)

        # Check if the file exists
        if [ ! -f "$file" ]; then
            echo "File not found: $file"
            continue
        fi

        # Calculate the hash of the file
        actual_hash=$(sha256sum "$file" | cut -d ' ' -f 1)

        # Compare the actual hash to the expected hash
        if [ "$actual_hash" != "$expected_hash" ]; then
            echo "File has been modified: $file"
            # Set modified flag to true
            modified=true
            # Append the modified file name to the list
            modified_files+=" $file"
        fi

    done < "$hash_file"

    # Check if any files are modified
    if [ "$modified" = true ]; then
        echo "Modified files:$modified_files"
    else
        echo "No files have been modified."
    fi
}



# Get the input from the user
read -p "Enter the input (1 to Data Masking, 2 to File Itegrity Checker, or 3 to Secure File Deletion): " input

# Call the appropriate function based on the input
case $input in
    1)
        DataMasking
        ;;
    2)
        FileIntegrityChecker
        ;;
    3)
        SecureFileDeletion
        ;;
    *)
        echo "Invalid input. Please enter 1 to, 2, or 3."
        ;;
esac