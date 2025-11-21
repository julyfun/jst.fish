#!/usr/bin/env python3
import os
import argparse
import datetime
from dataclasses import dataclass
import sys
from typing import List, Optional, Set
from operator import abs


@dataclass
class FileInfo:
    """Class for storing file information."""
    filename: str # relative from args.path
    mdate: datetime.datetime
    size: int
    type: str  # 'f' for file, 'd' for directory


def get_all_files(path: str, ignore_paths: Optional[Set[str]] = None, file_types: str = 'fd') -> List[FileInfo]:
    """
    Recursively get all files and/or directories under the given path.
    Returns a list of FileInfo objects containing filename, modification date, size, and type.

    Args:
        path: Directory path to scan
        ignore_paths: Set of paths to exclude from results
        file_types: String containing 'f' for files, 'd' for directories, or both
    """
    file_list = []
    ignore_paths = ignore_paths or set()

    include_files = 'f' in file_types
    include_dirs = 'd' in file_types

    for root, dirs, files in os.walk(path):
        # Process directories if requested
        relroot = os.path.relpath(root, path)
        if include_dirs:
            for dir_name in dirs:
                dir_path = os.path.join(root, dir_name)
                # Skip ignored directories
                if any(dir_path.startswith(ignore) for ignore in ignore_paths):
                    continue

                try:
                    stats = os.stat(dir_path)
                    dir_info = FileInfo(
                        filename=os.path.join(relroot, dir_name),
                        mdate=datetime.datetime.fromtimestamp(stats.st_mtime),
                        size=0,  # Directories have size 0
                        type='d'
                    )
                    file_list.append(dir_info)
                except Exception as e:
                    print(f"Error processing directory {dir_path}: {e}", file=sys.stderr)

        # Process files if requested
        if include_files:
            for file in files:
                file_path = os.path.join(root, file)
                # Skip ignored files
                if any(file_path.startswith(ignore) for ignore in ignore_paths):
                    continue

                try:
                    stats = os.stat(file_path)
                    file_info = FileInfo(
                        filename=os.path.join(relroot, file),
                        mdate=datetime.datetime.fromtimestamp(stats.st_mtime),
                        size=stats.st_size,
                        type='f'
                    )
                    file_list.append(file_info)
                except Exception as e:
                    print(f"Error processing file {file_path}: {e}", file=sys.stderr)

    return file_list


def sort_files(file_list: List[FileInfo], sort_criteria: str) -> List[FileInfo]:
    """
    Sort file list based on provided criteria.
    d: date, s: size

    Directories always have lower priority than files when sorting.
    """

    def key(x: FileInfo):
        tup = []
        tup.append(x.type == 'f' if 'r' in sort_criteria else x.type == 'd')
        for criterion in sort_criteria:
            if criterion == 'd':
                tup.append(x.mdate.timestamp())
            elif criterion == 's':
                tup.append(x.size)
        return tuple(tup)

    return sorted(file_list, key=key, reverse='r' in sort_criteria)


def format_output(file_list: List[FileInfo], output_format: Optional[str]) -> None:
    """
    Print file information according to output format.
    n: name, s: size, d: date, t: type
    """
    if not output_format:
        # Default detailed output
        print(f"Found {len(file_list)} items:")
        for file in file_list:
            print(f"Filename: {file.filename}")
            print(f"Type: {'Directory' if file.type == 'd' else 'File'}")
            print(f"Modified: {file.mdate}")
            print(f"Size: {file.size} bytes")
            print("-" * 40)
        return

    # Concise output with one file per line
    for file in file_list:
        parts = []
        for field in output_format:
            if field == 'n':
                parts.append(file.filename)
            elif field == 's':
                parts.append(f"{file.size}")
            elif field == 'd':
                parts.append(str(file.mdate))
            elif field == 't':
                parts.append(file.type)
        print("\t".join(parts))


def main():
    parser = argparse.ArgumentParser(description='Recursively list files with their information')
    parser.add_argument('path', help='Directory path to scan recursively')
    parser.add_argument(
        '-s',
        '--sort',
        help='Sort order: d (date), s (size), r(reverse), or combination (e.g., dsr)',
        default='d',
    )
    parser.add_argument('-o', '--output', help='Output fields: n (name), s (size), d (date), t (type), or combination', default=None)
    parser.add_argument('-i', '--ignore', nargs='+', help='Paths to ignore when listing files', default=[])
    parser.add_argument('-t', '--type', help='Types to include: f (files), d (directories), or fd (both)', default='fd')

    args = parser.parse_args()

    if not os.path.exists(args.path):
        print(f"Error: Path '{args.path}' does not exist", file=sys.stderr)
        sys.exit(1)

    # Convert relative paths to absolute paths for consistent comparison
    ignore_paths = set([os.path.join(args.path, ignore) for ignore in args.ignore])
    file_list = get_all_files(args.path, ignore_paths, args.type)
    file_list = sort_files(file_list, args.sort)
    format_output(file_list, args.output)


if __name__ == "__main__":
    main()
