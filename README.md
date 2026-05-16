<div align="center">

<img src="https://raw.githubusercontent.com/woodfine/woodfine-media-assets/main/ASSET-SIGNET-MASTER.svg" width="72" alt="Woodfine Management Corp.">

# Woodfine Management Corp.
### *The Live Institutional Deployment of the PointSav Platform*
### *El Despliegue Institucional en Vivo de la Plataforma PointSav*

[![Status: Active Deployment](https://img.shields.io/badge/Status-Active_Deployment-22863a.svg?style=flat-square)](#active-fleet-inventory)
[![Compliance: SOC 3 / DARP](https://img.shields.io/badge/Compliance-SOC_3_%2F_DARP-0075ca.svg?style=flat-square)](#compliance--governance)
[![Infrastructure: Zero-Touch](https://img.shields.io/badge/Infrastructure-Zero--Touch-6f42c1.svg?style=flat-square)](#the-operational-model)

<br/>

**[→ woodfinegroup.com](https://woodfinegroup.com)** &nbsp;·&nbsp; **[→ Corporate Governance Wiki](https://github.com/woodfine/content-wiki-corporate)** &nbsp;·&nbsp; **[→ PointSav Engineering](https://github.com/pointsav/pointsav-monorepo)**

</div>

<br/>

> [!NOTE]
> This repository contains no live financial accounts, active personnel data, or proprietary network payloads. The Sovereign Data Foundation's intended oversight role has not yet been formally executed.

---

## The Problem No One Has Solved

The market for tokenised real estate is approaching $30 trillion. Institutional investors can now purchase fractional ownership of commercial buildings on digital exchanges. What transfers in those transactions is a title — the legal right to own the asset.

What does not transfer is the building's history.

The lease register — every tenancy agreement, amendment, and expiry date that defines the asset's income stream — lives in a property manager's CRM. The maintenance record — every repair, every capital expenditure, every liability event — lives in a facilities management platform. The BIM drawings that describe the physical structure sit in an architect's file server. The IoT data that records the building's operational performance in real time flows into a sensor vendor's cloud.

Each of these records is owned by a third party. When the asset changes hands, the buyer receives the title and begins the process of reconstructing the history from scratch. The value of the asset — its income-generating capacity, its physical condition, its regulatory compliance — is documented only in systems the buyer does not inherit.

This is the gap Woodfine is closing.

---

## What a PropertyArchive Changes

Woodfine is deploying a PointSav PropertyArchive for each asset under management — a self-contained operating environment that holds all records relating to that property in a single, cryptographically sealed, portable archive.

A PropertyArchive maintained from the point of first permit holds simultaneously:

| Record Type | What it captures | Commercial significance |
|:---|:---|:---|
| Legal records | Title, permits, statutory compliance | The right to operate the asset |
| BIM drawings | Physical structure, spatial data, as-built specifications | The geometry of the asset |
| Lease register | Every tenancy agreement, amendment, payment history, and expiry | The income-generating capacity — what institutional investors underwrite |
| IoT data | Continuous sensor readings: HVAC, access, utilities, environmental | The operational performance of the asset in real time |
| Financial ledger | Capital expenditure, maintenance spend, service contracts | The cost structure of the asset |
| Maintenance history | Every repair, upgrade, and service event | The physical condition and liability profile |
| Personnel records | Service providers, contractors, key relationships | The operational network of the asset |

The lease register is the most commercially significant dimension. A building's value is its income stream. That income stream is defined by its leases — their terms, their renewal options, their rent escalation provisions, their expiry dates. Tokenising a title without the lease register is tokenising the shell and leaving the value off-chain.

When Woodfine sells a building, the buyer receives a Bootable Disk Image of the complete PropertyArchive — a self-contained virtual machine containing the unbroken, cryptographically verified history of the asset from inception. It boots on any standard hypervisor. It requires no ongoing relationship with Woodfine's systems. The institutional memory of the building transfers permanently and completely.

An archive maintained from first permit creates an unbroken chain of custody. By the time the asset trades, it is the most comprehensive due diligence record in the market.

---

## The Operational Model

### Zero-Touch Deployment

Managing institutional-grade records should not require an IT department. Woodfine's fleet is deployed through a Zero-Touch provisioning cycle: a one-click Launcher prepares host hardware, a keyboard-driven Text User Interface handles archive management, and cryptographic key exchange handles hardware pairing. No usernames. No passwords. No IT administrator.

### Machine-Based Authorization

Access to Woodfine's archives is not granted through credentials. It is granted through the physical topology of the network. If two machines are not cryptographically paired, they cannot communicate. There is no credentials database to steal because there are no credentials. Access control is defined by the wiring diagram — an architecture Woodfine describes as Geometric Security.

### Cold Storage Entanglement

Heavy archive data — high-resolution architectural drawings, IoT logs, extensive media assets — is managed through cryptographic splitting and physical egress. External drives are mathematically locked to specific archives. Those drives are unreadable on any other system. The core operating environment remains lightweight while overflow data stays under physical custody.

---

## Active Fleet Inventory

### Edge Delivery

| Directory | Function | Status |
|:---|:---|:---|
| `media-marketing-landing` | Public-facing website — zero-cookie telemetry | 🟢 Active |
| `media-knowledge-corporate` | Corporate governance wiki | 🟡 Provisioning |
| `media-knowledge-projects` | Real estate projects wiki | 🟡 Provisioning |
| `media-knowledge-distribution` | Newsroom and media distribution | 🟡 Provisioning |

### Infrastructure

| Directory | Function | Status |
|:---|:---|:---|
| `route-network-admin` | Private network routing | 🟡 Provisioning |
| `fleet-infrastructure-cloud` | GCP cloud relay — active testing | 🟡 Active Testing |
| `fleet-infrastructure-leased` | Dedicated leased server nodes | 🟡 Provisioning |
| `fleet-infrastructure-onprem` | On-premises hardware — MacBook Pro (NODE-LAPTOP-A) | 🟡 Provisioning |

The master routing node — iMac 12.1 (NODE-IMAC-12) on the executive's desk — holds the cryptographic keys for the entire network. It dials outbound to the cloud relay. The public internet cannot dial inbound to it. Physical custody of network keys is retained by Woodfine regardless of any cloud provider decision.

There is no central MBA registry. The topology is recorded in the Command Session's `pairings.yaml` and `MANIFEST.md`.

### Totebox Archives

| Directory | Archive Type | Status |
|:---|:---|:---|
| `cluster-totebox-corporate` | CorporateArchive — financial records, minute books, statutory ledgers | 🟡 Provisioning |
| `cluster-totebox-personnel` | PersonnelArchive — identity records, contact history | 🟢 Active |
| `cluster-totebox-property` | PropertyArchive — property records, permits, BIM, IoT, lease register | 🟡 Provisioning |
| `vault-privategit-source` | Air-gapped internal source control | 🟡 Provisioning |

### Operator Consoles

| Directory | Function | Status |
|:---|:---|:---|
| `gateway-interface-command` | CommandCentre — aggregates archives for administration | 🟡 Provisioning |
| `node-console-operator` | FKeysConsole — primary operator terminal | 🟡 Provisioning |
| `node-console-content` | Headless publishing and document processing | 🟡 Provisioning |
| `node-console-email` | Microsoft 365 mail extraction | 🟡 Provisioning |
| `node-console-keys` | Cryptographic authorisation management | 🟡 Provisioning |
| `node-console-people` | Personnel ledger execution | 🟡 Provisioning |

---

## Compliance & Governance

All operational nodes are being deployed to enforce SOC 3 and DARP compliance standards. DARP requires that all data be searchable without proprietary software — this is satisfied by the PointSav `service-search` inverted index, which operates independently of any running database engine and can be searched on an air-gapped machine.

The F12 Input Machine is the mandatory human checkpoint for all record ingestion. Nothing enters long-term storage without a human operator manually authorising the ledger entry. Automated AI publishing to verified records is prohibited.

All operational configurations, corporate frameworks, and digital assets contained in this repository are strictly reserved by Woodfine Capital Projects Inc. Refer to the `LICENSE` file in this directory.

---

## The Vendor Relationship

Woodfine Management Corp. is the first institutional customer of PointSav Digital Systems. Both are subsidiaries of Woodfine Capital Projects Inc. PointSav follows a cost-plus model: development time is charged at cost plus a fixed margin, not at value-add pricing. This keeps vendor and customer incentives structurally aligned.

The platform that Woodfine deploys is the same platform that any institution can deploy. The architecture is open. The data formats are universal. The export path requires no ongoing relationship with either Woodfine or PointSav.

**[→ PointSav Engineering Monorepo](https://github.com/pointsav/pointsav-monorepo)** &nbsp;·&nbsp; **[→ github.com/woodfine](https://github.com/woodfine)**

---

*© 2026 Woodfine Management Corp. All rights reserved.*

*→ Versión en español: [README.es.md](./README.es.md)*

<!-- BEGIN: factory-release-engineering license-section -->
<!-- ================================================================== -->
<!-- This section is generated from factory-release-engineering.         -->
<!-- Do not edit here. Propose changes upstream.                          -->
<!-- ================================================================== -->

## License

This repository is licensed under the **PointSav-ARR**. See the
`LICENSE` file in the root of this repository for the full legal text,
which is authoritative.

If the terms of the PointSav-ARR do not accommodate your use case, a commercial alternative is available under the **PointSav-Commercial**. Contact corporate.secretary@woodfinegroup.com for details.

Copyright (c) 2026 Woodfine Capital Projects Inc.. All rights not expressly
granted by the license are reserved.

<!-- ================================================================== -->
<!-- Esta sección se genera desde factory-release-engineering.           -->
<!-- No editar aquí. Proponga cambios río arriba.                         -->
<!-- ================================================================== -->

## Licencia

Este repositorio se distribuye bajo la **PointSav-ARR**. Véase el
archivo `LICENSE` en la raíz del repositorio para consultar el texto
legal completo, el cual es la versión autoritativa.

Si los términos de la PointSav-ARR no se ajustan a su caso de uso, existe una alternativa comercial disponible bajo la **PointSav-Commercial**. Para más información, escriba a corporate.secretary@woodfinegroup.com.

Copyright (c) 2026 Woodfine Capital Projects Inc.. Se reservan todos los
derechos no concedidos expresamente por la licencia.
<!-- END: factory-release-engineering license-section -->


---

*Copyright © 2026 Woodfine Capital Projects Inc. See [LICENSE](LICENSE) for terms.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*