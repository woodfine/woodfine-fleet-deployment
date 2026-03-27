# 🧭 GUIDE: PPN MESH EXECUTION (THE F8 TERMINAL)
**Operational Tier:** 3 (Fleet Deployment)
**Interface:** `os-network-admin` (https://network.woodfinegroup.com)

---

## I. OPERATIONAL POSTURE
The F8 Terminal is the primary interface for managing the PointSav Private Network (PPN). It utilizes a Zero-Broker UDP broadcast matrix to execute commands across distributed fleet nodes simultaneously. 

Because the terminal utilizes the `system-slm` Semantic Router, operators may input commands in natural English. To ensure operational safety, all inputs are subject to a mandatory Human-in-the-Loop (HITL) verification sequence.

## II. THE TWO-STEP EXECUTION PROTOCOL
Every command issued to the network follows a strict proposal and authorization flow:

1. **Submit Intent:** The operator types an instruction (e.g., `Lock down the laptop node`).
2. **Verify Translation:** The terminal halts and displays the machine-translated payload proposed by the SLM (e.g., `ACTION: ISOLATE, TARGET: NODE-LAPTOP-A`).
3. **Authorize Execution:** The operator must visually verify the accuracy of the translation and actively click `EXECUTE` to broadcast the command to the physical network.

## III. COMMAND EXAMPLES

### A. Infrastructure Telemetry (Fleet Health)
* **Intent:** `Check the health of the network.`
* **Verification Prompt:** `[PROPOSED] ACTION: PING, TARGET: ALL`
* **Result:** Broadcasts a UDP signal to port `8090`. All active nodes reply with their current CPU, RAM, and routing statuses.

### B. Fleet Node Isolation (Security)
* **Intent:** `Lock down the laptop node immediately.`
* **Verification Prompt:** `[PROPOSED] ACTION: ISOLATE, TARGET: NODE-LAPTOP-A`
* **Result:** The target node drops all routing tables except the master link to Node 3, freezing its ledgers in place.
