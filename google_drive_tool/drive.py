"""Google Drive file operations: list, search, download, and read documents."""

import io
import os
from typing import Optional

from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload

from .auth import get_credentials

# MIME types for Google Workspace documents
GOOGLE_DOC_MIME = "application/vnd.google-apps.document"
GOOGLE_SHEET_MIME = "application/vnd.google-apps.spreadsheet"
GOOGLE_SLIDES_MIME = "application/vnd.google-apps.presentation"

# Export MIME mappings for Google Workspace files
EXPORT_MIME_MAP = {
    GOOGLE_DOC_MIME: ("application/pdf", ".pdf"),
    GOOGLE_SHEET_MIME: (
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        ".xlsx",
    ),
    GOOGLE_SLIDES_MIME: ("application/pdf", ".pdf"),
}


class GoogleDriveClient:
    """Client for interacting with Google Drive."""

    def __init__(self, credentials_path: str = None, token_path: str = None):
        kwargs = {}
        if credentials_path:
            kwargs["credentials_path"] = credentials_path
        if token_path:
            kwargs["token_path"] = token_path

        creds = get_credentials(**kwargs)
        self.drive_service = build("drive", "v3", credentials=creds)
        self.docs_service = build("docs", "v1", credentials=creds)

    # ── File listing ──────────────────────────────────────────────

    def list_files(
        self,
        folder_id: str = None,
        page_size: int = 20,
        mime_type: str = None,
    ) -> list[dict]:
        """List files in Drive, optionally filtered by folder or MIME type.

        Returns a list of dicts with keys: id, name, mimeType, modifiedTime.
        """
        query_parts = ["trashed = false"]
        if folder_id:
            query_parts.append(f"'{folder_id}' in parents")
        if mime_type:
            query_parts.append(f"mimeType = '{mime_type}'")

        results = (
            self.drive_service.files()
            .list(
                q=" and ".join(query_parts),
                pageSize=page_size,
                fields="files(id, name, mimeType, modifiedTime)",
                orderBy="modifiedTime desc",
            )
            .execute()
        )
        return results.get("files", [])

    def search_files(self, query: str, page_size: int = 20) -> list[dict]:
        """Full-text search across file names and contents."""
        q = f"fullText contains '{query}' and trashed = false"
        results = (
            self.drive_service.files()
            .list(
                q=q,
                pageSize=page_size,
                fields="files(id, name, mimeType, modifiedTime)",
                orderBy="modifiedTime desc",
            )
            .execute()
        )
        return results.get("files", [])

    # ── Download / Export ─────────────────────────────────────────

    def download_file(self, file_id: str, dest_dir: str = "downloads") -> str:
        """Download a file from Drive to a local directory.

        Google Workspace files (Docs, Sheets, Slides) are automatically
        exported to a portable format (PDF / XLSX).

        Returns the path to the downloaded file.
        """
        meta = (
            self.drive_service.files()
            .get(fileId=file_id, fields="name, mimeType")
            .execute()
        )
        name = meta["name"]
        mime = meta["mimeType"]

        os.makedirs(dest_dir, exist_ok=True)

        if mime in EXPORT_MIME_MAP:
            export_mime, ext = EXPORT_MIME_MAP[mime]
            dest_path = os.path.join(dest_dir, name + ext)
            request = self.drive_service.files().export_media(
                fileId=file_id, mimeType=export_mime
            )
        else:
            dest_path = os.path.join(dest_dir, name)
            request = self.drive_service.files().get_media(fileId=file_id)

        fh = io.BytesIO()
        downloader = MediaIoBaseDownload(fh, request)
        done = False
        while not done:
            _, done = downloader.next_chunk()

        with open(dest_path, "wb") as f:
            f.write(fh.getvalue())

        return dest_path

    # ── Google Docs content reading ───────────────────────────────

    def read_doc(self, doc_id: str) -> str:
        """Read a Google Doc and return its plain-text content."""
        doc = self.docs_service.documents().get(documentId=doc_id).execute()
        return self._extract_text(doc)

    def read_doc_structured(self, doc_id: str) -> dict:
        """Read a Google Doc and return title + structured sections."""
        doc = self.docs_service.documents().get(documentId=doc_id).execute()
        title = doc.get("title", "")
        text = self._extract_text(doc)
        return {"title": title, "content": text}

    @staticmethod
    def _extract_text(doc: dict) -> str:
        """Extract plain text from a Google Docs API document resource."""
        text_parts: list[str] = []
        for element in doc.get("body", {}).get("content", []):
            paragraph = element.get("paragraph")
            if not paragraph:
                continue
            for run in paragraph.get("elements", []):
                text_run = run.get("textRun")
                if text_run:
                    text_parts.append(text_run.get("content", ""))
        return "".join(text_parts)

    # ── File metadata ─────────────────────────────────────────────

    def get_file_info(self, file_id: str) -> dict:
        """Return metadata for a single file."""
        return (
            self.drive_service.files()
            .get(
                fileId=file_id,
                fields="id, name, mimeType, modifiedTime, size, webViewLink",
            )
            .execute()
        )
