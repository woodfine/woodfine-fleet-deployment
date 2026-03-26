# GUIDE: Physical Egress (service-message-courier)

**Customer:** Woodfine Management Corp.
**Target Environment:** cluster-GCP-free (Private Cloud)
**Operation:** LinkedIn Automation Adapter Injection

## 1. Operational Overview
This document governs the physical egress of automated messaging from Woodfine's Private Cloud into the LinkedIn network. We utilize the generic `service-message-courier` provided by PointSav Digital Systems and inject our proprietary LinkedIn execution adapter.

## 2. The Injection Protocol
Before synchronizing this deployment to the GCP cluster (via `node_sync.sh`), you must place the physical execution script into the isolated adapter directory.

**Target Location:** `/home/mathew/deployments/woodfine-fleet-deployment/cluster-totebox-personnel/service-message-courier/private-adapters/linkedin-egress.py`

## 3. Operational Constraints (Risk Mitigation)
* **Volume Cap:** The adapter is hard-coded to process a maximum of 75-100 operations per execution cycle to prevent heuristic detection by the target network.
* **Data Ledger:** The adapter queries the master `service-people` database. It does not store contact data locally, ensuring that if the GCP node is destroyed, no personnel data is compromised.
