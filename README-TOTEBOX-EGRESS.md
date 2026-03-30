# POINT SAV DIGITAL SYSTEMS 
# ASYMMETRIC STORAGE & PHYSICAL EGRESS: OPERATIONAL PROTOCOL
# CLASSIFICATION: TIER 3 (INSTITUTIONAL SHOWCASE)
--------------------------------------------------------------------------------

## 1. STRATEGIC OVERVIEW (THE FLOW-THROUGH PROTOCOL)
This repository contains the `service-egress` logic required to execute the Sovereign Release Valve. It permanently decouples the lightweight semantic search index (`/ledger`) from the heavy payload (`/source`), physically extracting massive archives directly to local 3TB cold-storage drives.

It strictly enforces the Vendor/Customer operational model:
* **Vendor (PointSav Digital Systems):** Provides the `service-egress` bridging logic, chunking algorithms, and zstd-compression mechanics.
* **Customer (Woodfine Management Corp):** Operates the physical egress, maintains the cold-storage vault, and commands absolute zero vendor lock-in.

---

## 2. THE CHUNKED BRIDGE ARCHITECTURE
To guarantee successful extraction over degraded internet connections, `service-egress` mathematically slices heavy assets into strictly sized 50MB blocks. 

* **The Compression:** Utilizes Zstandard (`zstd`) for hyper-fast decompression ratios perfect for low-resource endpoint hardware.
* **The Asymmetric Wipe:** Once the local machine confirms cryptographic receipt of all chunks, the cloud node issues a secure `rm -rf` wipe command on the source data, returning the SSD to a state of absolute zero while maintaining the 2KB Markdown search index.

---

## 3. EXECUTION PROTOCOL (PHYSICAL EGRESS)
To execute a quarterly cold-storage mirror, plug the secure 3TB hard drive into the Tier 1 Command Authority (iMac 12.1) and execute the Asymmetric Pull Diode.

    cd /opt/pointsav/service-egress
    # Ignite the Asymmetric Storage Engine
    cargo run --release -- --target /Volumes/Woodfine-Cold-Storage/vault-ingress/

*Note: The system logs every physical sector transfer to `egress_ledger.log` for a complete forensic receipt.*
