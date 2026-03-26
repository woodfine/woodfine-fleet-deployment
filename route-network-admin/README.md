<div align="center">

# Node 3: PointSav Command Centre™ (Brain)
### *Hardware Forensics & Cryptographic Authority*
**Status: Active | Tier: 4. Gateway (Type-II Hypervisor)**

</div>

---

## 💻 Silicon Profile | Perfil de Silicio
This node operates as the **Command Authority** for the entire Woodfine Fleet. It holds the cryptographic keys (MBA) and serves as the single point of entry for infrastructure orchestration.

| Component | Specification | Hardware ID | Sovereign Notes |
| :--- | :--- | :--- | :--- |
| **System Model** | iMac 12,1 (Mid-2011) | N/A | Apple SMC & UEFI Boot Architecture. |
| **Host OS** | Linux Mint (Foundry) | N/A | The physical host compiling the Tier-1 Rust logic. |
| **Guest OS** | PointSav `os-network-admin` | VM | Type-II Hypervisor running the Command Authority. |
| **Network (NIC)** | Virtualized Bridge | `wg0` | Dials OUT to the GCP Relay. Public internet cannot dial IN. |

## 🛡️ Architectural Constraints
To ensure absolute custodial control and eliminate hyperscaler vulnerabilities, this routing node is physically located on the Executive's desk. If the Tier-2 Cloud Relay is destroyed, this node retains the master cryptographic keys and can instantly rebuild the mesh by dialing into a new cloud IP.
