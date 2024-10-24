# json2orca Conversion Tool

This tool converts JSON files containing ORCA-originated data into valid/parseable ORCA input and output formats.

## Usage

To perform the conversion, you need to execute the json2orca.sh script with a JSON file as an input parameter.

All the conversions will automatically be saved in the results folder. Each molecule extracted from the input JSON will be stored in a subdirectory within the results directory. The subdirectory will contain the molecule's input and output files.

### Example of Execution

./json2orca.sh example.json

## Folder Structure

After running the script, the results folder will be structured as follows:

results/XX/[input.in && output.out]

Each subdirectory represents a molecule extracted from the JSON file, and contains:
- input.in: The ORCA input file.
- output.out: The resulting output file after processing.

## Requirements

- A Linux Bash

## How to Run

1. Place the JSON file you want to convert in the same directory as the json2orca.sh script.
2. Execute the script as shown in the example above.
3. The converted files will be available in the results folder.

## Notes

- Ensure that the JSON file is properly formatted for this conversion script.
- ORCA software must be installed and available in your system's PATH.
- These ORCAs are compatible with [ioChem-BD](https://www.iochem-bd.com/) software.

### Contact

If you have any issues or questions, please contact the developer or create an issue in the repository.
