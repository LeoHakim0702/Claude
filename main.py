#!/usr/bin/env python3
"""Google Drive Tool — CLI for accessing Google Drive documents.

Usage:
    python main.py list [--folder FOLDER_ID] [--type doc|sheet|slide]
    python main.py search QUERY
    python main.py read FILE_ID
    python main.py download FILE_ID [--dest DIR]
    python main.py info FILE_ID
"""

import argparse
import sys
import json

from google_drive_tool.drive import (
    GoogleDriveClient,
    GOOGLE_DOC_MIME,
    GOOGLE_SHEET_MIME,
    GOOGLE_SLIDES_MIME,
)

MIME_SHORTCUTS = {
    "doc": GOOGLE_DOC_MIME,
    "sheet": GOOGLE_SHEET_MIME,
    "slide": GOOGLE_SLIDES_MIME,
}


def _print_file_table(files: list[dict]) -> None:
    if not files:
        print("  (no files found)")
        return
    print(f"  {'Name':<45} {'Type':<35} {'Modified':<22} {'ID'}")
    print("  " + "-" * 130)
    for f in files:
        name = f["name"][:44]
        mime = f["mimeType"][:34]
        modified = f.get("modifiedTime", "")[:21]
        print(f"  {name:<45} {mime:<35} {modified:<22} {f['id']}")


def cmd_list(args, client: GoogleDriveClient) -> None:
    mime = MIME_SHORTCUTS.get(args.type) if args.type else None
    files = client.list_files(folder_id=args.folder, mime_type=mime)
    print(f"\nFiles in Drive (most recent first):\n")
    _print_file_table(files)


def cmd_search(args, client: GoogleDriveClient) -> None:
    files = client.search_files(args.query)
    print(f"\nSearch results for '{args.query}':\n")
    _print_file_table(files)


def cmd_read(args, client: GoogleDriveClient) -> None:
    result = client.read_doc_structured(args.file_id)
    print(f"\n{'=' * 60}")
    print(f"  Title: {result['title']}")
    print(f"{'=' * 60}\n")
    print(result["content"])


def cmd_download(args, client: GoogleDriveClient) -> None:
    path = client.download_file(args.file_id, dest_dir=args.dest)
    print(f"Downloaded to: {path}")


def cmd_info(args, client: GoogleDriveClient) -> None:
    info = client.get_file_info(args.file_id)
    print(json.dumps(info, indent=2, ensure_ascii=False))


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Google Drive Tool — access your Drive documents from the CLI"
    )
    sub = parser.add_subparsers(dest="command", required=True)

    # list
    p_list = sub.add_parser("list", help="List files in Drive")
    p_list.add_argument("--folder", help="Folder ID to list")
    p_list.add_argument("--type", choices=["doc", "sheet", "slide"], help="Filter by type")

    # search
    p_search = sub.add_parser("search", help="Search files by keyword")
    p_search.add_argument("query", help="Search query")

    # read
    p_read = sub.add_parser("read", help="Read a Google Doc as plain text")
    p_read.add_argument("file_id", help="Google Doc file ID")

    # download
    p_download = sub.add_parser("download", help="Download a file")
    p_download.add_argument("file_id", help="File ID to download")
    p_download.add_argument("--dest", default="downloads", help="Destination directory")

    # info
    p_info = sub.add_parser("info", help="Show file metadata")
    p_info.add_argument("file_id", help="File ID")

    args = parser.parse_args()

    try:
        client = GoogleDriveClient()
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    commands = {
        "list": cmd_list,
        "search": cmd_search,
        "read": cmd_read,
        "download": cmd_download,
        "info": cmd_info,
    }
    commands[args.command](args, client)


if __name__ == "__main__":
    main()
