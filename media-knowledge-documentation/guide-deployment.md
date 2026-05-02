# Deployment Guide — media-knowledge-documentation

Covers the initial bring-up of `app-mediakit-knowledge` as the `local-knowledge.service` systemd unit, serving `documentation.pointsav.com`. Initial deployment completed at workspace v0.1.29.

For day-2 operations (content updates, search, service restarts), see `guide-operate-knowledge-wiki.md`.

## Prerequisites

- Node provisioned per `guide-provision-node.md`
- Binary built from `pointsav-monorepo/app-mediakit-knowledge/` and installed to `/usr/local/bin/app-mediakit-knowledge`
- Content tree cloned from `content-wiki-documentation` and available locally
- DNS A record for `documentation.pointsav.com` pointing to the VM public IP
- GCP and OS (ufw) firewalls open on TCP 80 and TCP 443

## 1. System user and state directory

```bash
sudo useradd --system --no-create-home --shell /usr/sbin/nologin local-knowledge
sudo mkdir -p /var/lib/local-knowledge/state
sudo chown -R local-knowledge:local-knowledge /var/lib/local-knowledge
```

## 2. Install and start the systemd unit

The canonical unit is at `vault-privategit-source-1/infrastructure/local-knowledge/local-knowledge.service` on the Foundry workspace VM. Copy it to `/etc/systemd/system/local-knowledge.service`, then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable local-knowledge.service
sudo systemctl start local-knowledge.service
sudo systemctl status local-knowledge.service
```

## 3. TLS certificate

```bash
sudo certbot --nginx -d documentation.pointsav.com
```

Certbot modifies the nginx vhost to add TLS. Renewal is automatic via the certbot systemd timer.

## 4. Smoke test

```bash
curl -s https://documentation.pointsav.com/healthz
```

Expect HTTP 200. The wiki is live. See `guide-operate-knowledge-wiki.md` for ongoing operations.

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
