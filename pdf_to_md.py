#!/usr/bin/env python3
"""
PDF to Markdown Batch Converter
================================
将 Bibliography 文件夹中的所有 PDF 批量转换为 Markdown 文本文件。

Usage:
    python pdf_to_md.py <input_dir> [--output <output_dir>] [--workers <n>]

Examples:
    # Windows (PowerShell):
    python pdf_to_md.py "C:\\Users\\10787\\OneDrive - National University of Singapore\\Thesis\\Bibliography"

    # Custom output directory:
    python pdf_to_md.py "path/to/Bibliography" --output "path/to/Bibliography_MD"

    # Use 8 parallel workers for speed:
    python pdf_to_md.py "path/to/Bibliography" --workers 8

Requirements:
    pip install pymupdf
"""

import argparse
import os
import sys
import time
import traceback
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

try:
    import fitz  # PyMuPDF
except ImportError:
    print("Error: PyMuPDF is required. Install it with:")
    print("  pip install pymupdf")
    sys.exit(1)


def pdf_to_markdown(pdf_path: str) -> str:
    """Extract text from a PDF and format it as Markdown.

    Preserves document structure by detecting headings (bold/large font),
    paragraphs, and page breaks.
    """
    doc = fitz.open(pdf_path)
    md_parts = []

    filename = Path(pdf_path).stem
    md_parts.append(f"# {filename}\n")
    md_parts.append(f"*Source: {Path(pdf_path).name}*\n")
    md_parts.append("---\n")

    for page_num in range(len(doc)):
        page = doc[page_num]
        md_parts.append(f"\n## Page {page_num + 1}\n")

        blocks = page.get_text("dict", flags=fitz.TEXT_PRESERVE_WHITESPACE)["blocks"]

        for block in blocks:
            if block["type"] != 0:  # skip image blocks
                continue

            block_text_parts = []
            for line in block.get("lines", []):
                line_text = ""
                is_bold = False
                max_font_size = 0

                for span in line.get("spans", []):
                    text = span.get("text", "")
                    font = span.get("font", "")
                    size = span.get("size", 12)
                    flags = span.get("flags", 0)

                    if not text.strip():
                        line_text += text
                        continue

                    max_font_size = max(max_font_size, size)
                    # flags: bit 0 = superscript, bit 1 = italic, bit 2 = serif,
                    #         bit 3 = monospace, bit 4 = bold
                    if flags & (1 << 4) or "Bold" in font or "bold" in font:
                        is_bold = True

                    line_text += text

                line_text = line_text.rstrip()
                if not line_text.strip():
                    continue

                # Detect headings: bold text with larger font size
                if is_bold and max_font_size >= 14 and len(line_text.strip()) < 200:
                    block_text_parts.append(f"\n### {line_text.strip()}\n")
                elif is_bold and max_font_size >= 12 and len(line_text.strip()) < 150:
                    block_text_parts.append(f"**{line_text.strip()}**")
                else:
                    block_text_parts.append(line_text)

            if block_text_parts:
                paragraph = " ".join(
                    p for p in block_text_parts if not p.startswith("\n###")
                )
                headings = [p for p in block_text_parts if p.startswith("\n###")]
                for h in headings:
                    md_parts.append(h)
                if paragraph.strip():
                    md_parts.append(paragraph.strip() + "\n")

    doc.close()
    return "\n".join(md_parts)


def convert_single_pdf(args: tuple) -> dict:
    """Convert a single PDF file. Used by multiprocessing pool."""
    pdf_path, output_dir = args
    result = {
        "source": pdf_path,
        "success": False,
        "output": None,
        "error": None,
        "size_before": 0,
        "size_after": 0,
    }

    try:
        result["size_before"] = os.path.getsize(pdf_path)

        md_content = pdf_to_markdown(pdf_path)

        # Create output path preserving relative structure
        rel_path = Path(pdf_path).name
        md_filename = Path(rel_path).stem + ".md"
        output_path = os.path.join(output_dir, md_filename)

        # Handle duplicate filenames
        if os.path.exists(output_path):
            base = Path(rel_path).stem
            counter = 1
            while os.path.exists(output_path):
                md_filename = f"{base}_{counter}.md"
                output_path = os.path.join(output_dir, md_filename)
                counter += 1

        with open(output_path, "w", encoding="utf-8") as f:
            f.write(md_content)

        result["success"] = True
        result["output"] = output_path
        result["size_after"] = os.path.getsize(output_path)

    except Exception as e:
        result["error"] = f"{type(e).__name__}: {e}"
        traceback.print_exc()

    return result


def find_pdfs(input_dir: str) -> list[str]:
    """Recursively find all PDF files in the input directory."""
    pdfs = []
    for root, _dirs, files in os.walk(input_dir):
        for f in files:
            if f.lower().endswith(".pdf"):
                pdfs.append(os.path.join(root, f))
    pdfs.sort()
    return pdfs


def format_size(size_bytes: int) -> str:
    """Format bytes into human-readable size."""
    for unit in ["B", "KB", "MB", "GB"]:
        if size_bytes < 1024:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.1f} TB"


def main():
    parser = argparse.ArgumentParser(
        description="Batch convert PDF files to Markdown for academic reading"
    )
    parser.add_argument("input_dir", help="Directory containing PDF files")
    parser.add_argument(
        "--output",
        default=None,
        help="Output directory (default: <input_dir>_MD)",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=4,
        help="Number of parallel workers (default: 4)",
    )
    args = parser.parse_args()

    input_dir = os.path.abspath(args.input_dir)
    if not os.path.isdir(input_dir):
        print(f"Error: Input directory not found: {input_dir}")
        sys.exit(1)

    output_dir = args.output or (input_dir.rstrip(os.sep) + "_MD")
    os.makedirs(output_dir, exist_ok=True)

    print(f"Input:   {input_dir}")
    print(f"Output:  {output_dir}")
    print(f"Workers: {args.workers}")
    print()

    # Find all PDFs
    pdfs = find_pdfs(input_dir)
    if not pdfs:
        print("No PDF files found in the input directory.")
        sys.exit(0)

    print(f"Found {len(pdfs)} PDF files. Starting conversion...\n")

    # Convert in parallel
    tasks = [(pdf, output_dir) for pdf in pdfs]
    success_count = 0
    fail_count = 0
    total_before = 0
    total_after = 0
    start_time = time.time()

    with ProcessPoolExecutor(max_workers=args.workers) as executor:
        futures = {executor.submit(convert_single_pdf, t): t for t in tasks}

        for i, future in enumerate(as_completed(futures), 1):
            result = future.result()
            total_before += result["size_before"]

            if result["success"]:
                success_count += 1
                total_after += result["size_after"]
                status = "OK"
                detail = format_size(result["size_after"])
            else:
                fail_count += 1
                status = "FAIL"
                detail = result["error"]

            filename = Path(result["source"]).name
            # Truncate long filenames for display
            if len(filename) > 50:
                filename = filename[:47] + "..."
            print(f"  [{i:3d}/{len(pdfs)}] {status:4s} | {filename:<55s} | {detail}")

    elapsed = time.time() - start_time
    print(f"\n{'=' * 70}")
    print(f"Conversion complete!")
    print(f"  Succeeded: {success_count}/{len(pdfs)}")
    if fail_count:
        print(f"  Failed:    {fail_count}")
    print(f"  Time:      {elapsed:.1f}s")
    print(f"  Size:      {format_size(total_before)} -> {format_size(total_after)} "
          f"({total_after / max(total_before, 1) * 100:.1f}%)")
    print(f"\nOutput directory: {output_dir}")
    print(f"\nNext step: Upload the '{Path(output_dir).name}' folder and I can read all files.")


if __name__ == "__main__":
    main()
