# create_file_tree.py
import os
import argparse

def build_tree(paths):
    tree = {}
    for path in paths:
        parts = path.strip().split('/')
        current_level = tree
        for part in parts:
            if part not in current_level:
                current_level[part] = {}
            current_level = current_level[part]
    return tree

def print_tree(tree, prefix='', output_file=None):
    for key, value in tree.items():
        line = f"{prefix}|--> {key}\n"
        if output_file:
            output_file.write(line)
        else:
            print(line, end='')
        if isinstance(value, dict):
            print_tree(value, prefix + '    ', output_file)

def read_paths_from_file(file_path):
    with open(file_path, 'r') as file:
        return file.readlines()

def main(input_file_path, output_file_path):
    paths = read_paths_from_file(input_file_path)
    file_tree = build_tree(paths)
    if output_file_path:
        with open(output_file_path, 'w') as output_file:
            print_tree(file_tree, output_file=output_file)
    else:
        print_tree(file_tree)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate and print a file tree from a list of file paths.')
    parser.add_argument('input_filepath', type=str, help='Input file path containing list of file paths.')
    parser.add_argument('output_filepath', type=str, help='Output file path to save the file tree.')
    args = parser.parse_args()

    main(args.input_filepath, args.output_filepath)