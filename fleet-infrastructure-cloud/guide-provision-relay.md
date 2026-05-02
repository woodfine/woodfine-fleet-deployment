# Cloud Relay Provisioning Guide

Covers provisioning the GCP cloud node as the static WireGuard hub for the Woodfine private network. This node has a fixed public IP address and acts as the central relay that all fleet nodes dial into.

This guide is in development. The steps below reflect the provisioning approach and will be filled in as the fleet-infrastructure-cloud cluster moves from Scaffold-coded to Active state.

## Overview

The cloud relay runs WireGuard on the GCP compute instance. Other fleet nodes — on-premises hardware and leased endpoints — dial out to this relay. The relay does not dial in to nodes; all traffic initiates from the nodes.

For WireGuard mesh key generation and subnet assignment, see `route-network-admin/guide-mesh-orchestration.md`.

## Prerequisites

- GCP compute instance provisioned with a static external IP
- GCP firewall rule allowing UDP on the WireGuard port (default: 51820) from all sources
- WireGuard installed: `sudo apt-get install wireguard`

## Steps

Steps to be documented when exact network parameters are ratified (IP range, port, peer list).

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
