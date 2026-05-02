# 🧭 GUIDE: PROVISIONING THE NETWORK LEDGER (LXC)
**Operational Tier:** 3 (Fleet Deployment)
**Target Node:** fleet-infrastructure-onprem (Laptop A)
**Subdomain Target:** network.woodfinegroup.com

---

## I. ARCHITECTURAL MANDATE
This guide governs the deployment of the `os-network-admin` Type-II command terminal. By deploying this interface inside a mathematically sealed Linux Container (LXC) on Laptop A, we ensure the infrastructure forge remains completely portable and independent of legacy office servers.

## II. EXECUTION PROTOCOL
The deployment script executes a 4-phase sequence:
1. **Container Forge:** Initializes an isolated Ubuntu/Debian LXC container named `pointsav-network-ledger`.
2. **Network Bridge:** Bridges the container to the host's PointSav Private Network (PPN) `wg0` interface, granting it secure line-of-sight to the `10.50.0.x` mesh.
3. **Payload Injection:** Mounts the Light Mode UI Cartridges (`app-network-*`) and the Chassis from the engineering monorepo into the container's `/var/www/html/` directory.
4. **Web Server Ignition:** Installs and configures NGINX to serve the interface on an internal port, preparing it for the external HTTPS reverse proxy.

## III. LIVE RADAR MAINTENANCE
The `mesh-state.json` file is initially seeded as a static ledger. During standard operations, a cron-based script within the LXC container actively surveys the 2-Node mesh to dynamically update the radar JSON.


---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
