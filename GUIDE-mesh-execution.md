# 🧭 GUIDE: PPN MESH EXECUTION (THE F8 TERMINAL)
**Operational Tier:** 3 (Fleet Deployment)
**Interface:** `os-network-admin` (https://network.woodfinegroup.com)

---

## I. OPERATIONAL POSTURE
The F8 Terminal is the primary steering wheel for the PointSav Private Network (PPN). It utilizes a Zero-Broker UDP broadcast matrix to execute commands across distributed fleet nodes simultaneously. 

Because the terminal utilizes the `system-slm` Semantic Router, operators are not required to memorize POSIX flags. They may type natural English intent.

## II. EXECUTION PROTOCOLS

### A. Infrastructure Telemetry (Fleet Health)
To query the hardware state of the entire decentralized fleet:
* **Standard Input:** `ppn mesh --status`
* **Semantic Input:** `Check the health of the network.`
* **Result:** Broadcasts a UDP signal to port `8090`. All active nodes reply with their current CPU, RAM, and WireGuard tunnel statuses.

### B. Fleet Node Isolation (Security)
To quarantine a suspected compromised edge node:
* **Standard Input:** `ppn node --isolate --target=NODE-LAPTOP-A`
* **Semantic Input:** `Lock down the laptop node immediately.`
* **Result:** The target node drops all WireGuard tunnels except the master link to Node 3, freezing its ledgers in place.

### C. Ledger Interrogation (Totebox Verification)
To query the asset state of a localized Totebox Archive without logging into the UI:
* **Standard Input:** `ppn query service-content --all`
* **Semantic Input:** `What is currently inside the content ledger?`
* **Result:** Triggers a remote RPC call over the mesh to query the JSON state of the target container.
