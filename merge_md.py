#!/usr/bin/env python3
"""
Merge all Markdown files in a directory into a single file.

Usage:
    python merge_md.py "path/to/Bibliography_MD"

Output: Bibliography_MD_merged.md (in the same parent directory)
"""

import os
import sys
from pathlib import Path


def main():
    if len(sys.argv) < 2:
        print("Usage: python merge_md.py <directory>")
        sys.exit(1)

    input_dir = os.path.abspath(sys.argv[1])
    if not os.path.isdir(input_dir):
        print(f"Error: {input_dir} is not a directory")
        sys.exit(1)

    # Find all .md files
    md_files = sorted(Path(input_dir).glob("*.md"))
    if not md_files:
        print("No .md files found.")
        sys.exit(0)

    output_path = os.path.join(
        os.path.dirname(input_dir),
        Path(input_dir).name + "_merged.md"
    )

    print(f"Found {len(md_files)} markdown files.")
    print(f"Merging into: {output_path}")

    with open(output_path, "w", encoding="utf-8") as out:
        for i, md_file in enumerate(md_files, 1):
            content = md_file.read_text(encoding="utf-8", errors="replace")
            out.write(f"\n{'=' * 80}\n")
            out.write(f"FILE {i}/{len(md_files)}: {md_file.name}\n")
            out.write(f"{'=' * 80}\n\n")
            out.write(content)
            out.write("\n")

    size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"Done! Output: {output_path} ({size_mb:.1f} MB)")


if __name__ == "__main__":
    main()
