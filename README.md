<div align="center">

# Woodfine Management Corp.
### *Fleet Manifest*

[![Entity](https://img.shields.io/badge/Entity-Enterprise_Customer-164679?style=flat-square)](#)
[![Asset](https://img.shields.io/badge/Asset-Institutional_Real_Estate-164679?style=flat-square)](#)

[ **Organization Profile** ](https://github.com/woodfine) | [ **Fleet Manifest** ](https://github.com/woodfine/woodfine-fleet-deployment) | [ **Corporate Wiki** ](https://github.com/woodfine/content-wiki-corporate) | [ **Projects Wiki** ](https://github.com/woodfine/content-wiki-projects) | [ **Media Assets** ](https://github.com/woodfine/woodfine-media-assets)
<br>↳ External Vendor: [ **PointSav Monorepo ↗** ](https://github.com/pointsav/pointsav-monorepo)

</div>

---

## 1. THE HARDWARE MANIFEST

**[ EN ]** This repository documents the active physical hardware and network configurations deployed by Woodfine Management Corp. Administration records are committed to Write-Once, Read-Many (WORM) physical ledgers.

> **[ ES ]** *Este repositorio documenta el hardware físico activo y las configuraciones de red desplegadas por Woodfine Management Corp. Los registros de administración se consignan en libros mayores físicos WORM (Escribir una vez, Leer muchas).*

## 2. TERMINAL ACCESS

**[ EN ]** Operational personnel interact with the cyberphysical infrastructure via Type I Terminals (dedicated bare-metal workstations running PointSav Workplace OS) or Type II Terminals (secure hosted applications).

> **[ ES ]** *El personal operativo interactúa con la infraestructura ciberfísica a través de Terminales Tipo I (estaciones de trabajo físicas dedicadas que ejecutan PointSav Workplace OS) o Terminales Tipo II (aplicaciones alojadas seguras).*

| Target Environment | Operating System | Deployment Role | Status |
| :--- | :--- | :--- | :--- |
| **`fleet-infrastructure-onprem`** | PointSav Infrastructure OS | Physical Office Servers. | 🟢 Active |
| **`cluster-totebox-corporate`** | Totebox OS | Internal personnel and event records. | 🟡 Staging |
| **`cluster-totebox-real-property`**| Totebox OS | Real estate property records. | 🟡 Staging |

---

<div align="left">
<sub><em>Woodfine Capital Projects, Woodfine Management Corp., PointSav Digital Systems, Totebox Orchestration, and Totebox Archive are trademarks owned by Woodfine Capital Projects Inc. This notice serves as a formal declaration of intellectual property rights, asserting continuous use in commerce regardless of the omission of the ™ or ® symbols in the accompanying text. All operational and architectural system designations (including but not limited to PointSav Console OS, PointSav Infrastructure OS, PointSav MediaKit OS, PointSav Network OS, PointSav PrivateGit OS, PointSav Workplace OS, Totebox Integration OS, and Totebox OS) are proprietary structural wordmarks utilized exclusively within the PointSav Digital Systems architecture.</em></sub>
</div>
