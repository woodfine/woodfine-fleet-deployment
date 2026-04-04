# 🧭 GUIDE: PHYSICAL EGRESS (COLD STORAGE BACKUP)
**Operational Tier:** 3 (Fleet Deployment)
**Target Node:** cluster-totebox-personnel

---

## I. EXECUTIVE SUMMARY
This guide outlines the Terminal Priority commands required to execute a physical egress of the Immutable Ledger. 

Because the Totebox Architecture utilizes flat-file Entity Bundles (Files over Databases), the Customer maintains absolute custodial ownership of the data. No proprietary export tools or vendor approvals are required to back up the corporate history.

## II. EXECUTION PROTOCOL
To execute a quarterly cold-storage mirror, plug a secure hard drive into the Tier 1 Command Authority (iMac 12.1) and execute the following network sync command:

```bash
rsync -avz --progress admin@136.117.130.104:/assets/personnel-maildir/ /Volumes/Woodfine-Cold-Storage/personnel-maildir/
```

This mathematical transfer guarantees an exact 1:1 physical clone of the entire operational communication history, ensuring complete disaster recovery capability even if the cloud relay is destroyed.
