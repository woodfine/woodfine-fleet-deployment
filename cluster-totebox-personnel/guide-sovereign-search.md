# GUIDE: Sovereign Search Operations
**Customer:** Woodfine Management Corp.
**Target Environment:** cluster-totebox-personnel
**Operation:** Flat-File Indexing & Retrieval

## 1. Operational Overview
The Sovereign Search architecture decouples data persistence from data retrieval. It operates in two phases: The Forge (Indexing) and The Strike (Querying).

## 2. The Forge (Automated Indexing)
When new assets (`.md` artifacts from `service-content` or `.json` ledgers from `service-people`) are written to the Totebox, the Tantivy-based indexer automatically awakens.
1. It reads the physical files once.
2. It mathematically maps the vocabulary to byte-coordinates.
3. It compresses this map into the `/search-index/` binary folder.
4. It terminates immediately to release system memory.

## 3. The Strike (Operator Querying)
To search the Totebox Archive:
1. Access the `app-interface-command` terminal.
2. Input the boolean query (e.g., `Arthur AND domain:PROJECTS`).
3. The engine parses the `/search-index/` binaries and returns the exact physical file paths in microseconds.

## 4. DARP Extraction Protocol
To extract the archive for an auditor:
1. Securely mount an encrypted external volume.
2. Execute: `cp -r /opt/woodfine/cluster-totebox-personnel/ /mnt/encrypted_usb/`
3. The search index travels with the raw files, ensuring immediate operability off-site.
