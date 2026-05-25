---
schema: foundry-doc-v1
title: "Microsoft Entra ID — App Registration Setup"
slug: guide-msft-entra-id
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Microsoft Entra ID App Registration

This guide covers configuring Microsoft Entra ID (formerly Azure Active Directory) Enterprise App Registration credentials for the personnel cluster. Using app registrations rather than legacy app passwords provides modern OAuth 2.0 client-credentials authentication for the Graph API connection. Keys are stored only in the node-level `.env` file and never committed to version control.

## Prerequisites

- Microsoft 365 administrator access to create Enterprise App Registrations in the Woodfine tenant.
- SSH access to the cluster node to write the `.env` credentials file.

## Required credentials

Three values are required from the Entra ID app registration:

| Credential | Where to find it |
|---|---|
| Tenant ID | Azure portal → Entra ID → Overview |
| Client ID | Azure portal → Entra ID → App registrations → your app → Overview |
| Client Secret Value | Azure portal → Entra ID → App registrations → your app → Certificates & secrets |

## Procedure

### Step 1 — Create the app registration

1. Open the Azure portal and navigate to Microsoft Entra ID → App registrations.
2. Select **New registration**. Name the app (e.g., `woodfine-personnel-cluster`).
3. Set **Supported account types** to single-tenant.
4. Select **Register**.

### Step 2 — Create a client secret

1. In the app registration, navigate to **Certificates & secrets**.
2. Select **New client secret**. Set a description and expiry period.
3. Copy the **Value** immediately — it is not shown again after leaving the page.

### Step 3 — Grant API permissions

1. Navigate to **API permissions** → **Add a permission** → **Microsoft Graph**.
2. Add the permissions required for mailbox access (e.g., `Mail.Read`, `Mail.ReadBasic`).
3. Select **Grant admin consent** for the tenant.

### Step 4 — Write credentials to the node

Write the three values to `service-email/auth-credentials.env` on the cluster node with `0600` permissions. Do not commit this file to version control.

```bash
chmod 0600 service-email/auth-credentials.env
```

## Expected Outcome

The `service-email` service authenticates to the Graph API without prompting for user credentials. Confirm by checking the ingress pipeline logs for successful API responses.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
