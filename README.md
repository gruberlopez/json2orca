# json2orca Conversion Tool

This tool allows you to convert JSON files into ORCA input and output formats for molecule processing.

## Usage

To perform the conversion, you need to execute the json2orca.sh script with a JSON file as an input parameter.

All the conversions will automatically be saved in the results folder. Each molecule extracted from the input JSON will be stored in a subdirectory within the results directory. The subdirectory will contain the molecule's input and output files.

### Example of Execution

./json2orca.sh example.json

## Folder Structure

After running the script, the results folder will be structured as follows:

results/molecule1/[orca.in && orca.out]

Each subdirectory (molecule_1, molecule_2, ...) represents a molecule extracted from the JSON file, and contains:
- input.orca: The input file for ORCA.
- output.orca: The resulting output file after processing.

## Requirements

- Bash
- ORCA software

## How to Run

1. Place the JSON file that you want to convert in the same directory as the json2orca.sh script.
2. Execute the script as shown in the example above.
3. The converted files will be available in the results folder.

## Notes

- Ensure that the JSON file is properly formatted for this conversion script.
- ORCA software must be installed and available in your system's PATH.
- This ORCAs are compatible with [ioChem-BD](https://www.iochem-bd.com/)


### Contact

For any issues or questions, feel free to contact the developer or create an issue in the repository.
