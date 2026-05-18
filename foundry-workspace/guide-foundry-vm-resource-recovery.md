---
schema: foundry-doc-v1
title: "Recovering the Foundry Workspace VM from Resource Pressure"
slug: guide-foundry-vm-resource-recovery
type: guide
status: active
bcsc_class: customer-internal
last_edited: 2026-05-18
editor: pointsav-engineering
---

When `bin/foundry-health.sh` reports CRITICAL or operators report the VM feels slow,
this is the recovery playbook. Tested 2026-05-18 against a load average of 70 with
two developers logged in.

## Diagnose first

```bash
uptime                     # load avg vs core count (4 vCPU on this VM)
free -h                    # memory + swap; >85% swap = thrash
swapon --show              # swap devices, used vs free
ps auxf --sort=-%cpu | head -20
ps auxf --sort=-%mem | head -20
systemctl --failed
foundry-health.sh          # the canonical status pass
```

Read the load average's three numbers: 1-min / 5-min / 15-min. A spike on 1-min that
has not reached 5-min may resolve on its own. Sustained 5-min/15-min above 2× vCPU
count is the actionable signal.

## Recover

The four steps that pulled load 70 → 8 on 2026-05-18:

```bash
# 1. Clean stale session locks (boot_id mismatch or PID dead)
find /srv/foundry -name session.lock -path '*.agent/engines/*' \
    | while read f; do cat "$f" | grep pid: ; echo "  $f"; done
# Inspect output, then remove dead ones manually.

# 2. Restart local-slm with --threads 2 if not already capped
# The drop-in at /etc/systemd/system/local-slm.service.d/threads.conf
# already applies this; sudo systemctl restart local-slm if needed.

# 3. Add zram swap if zram-config.service shows failed
sudo apt-get install -y linux-modules-extra-$(uname -r)
sudo systemctl restart zram-config.service
swapon --show              # expect /dev/zram0 added

# 4. Verify foundry-services.slice is enforcing
systemctl status foundry-services.slice
# Should show local-slm, local-doorman, local-content, local-fs, etc.
```

## When restart fails

If `sudo systemctl restart local-slm` hangs, check that the cgroup memory cap is not
being exceeded by the new process. Tighten the drop-in MemoryHigh and verify with:

```bash
cat /sys/fs/cgroup/foundry.slice/foundry-services.slice/local-slm.service/memory.current
```

## When swap is full

If `swapon --show` shows the primary `/swapfile` at 100% with no free swap and load
is still climbing, add a second swapfile rather than `swapoff`ing the original (which
requires fitting all swapped pages back into RAM first):

```bash
sudo fallocate -l 4G /swapfile2
sudo chmod 0600 /swapfile2
sudo mkswap /swapfile2
sudo swapon --priority 10 /swapfile2
echo "/swapfile2 none swap sw,pri=10 0 0" | sudo tee -a /etc/fstab
```

New allocations route to the higher-priority swap; the legacy swapfile drains naturally
as the kernel reclaims pages.

## Do not

- Do not `systemctl restart` public-facing services (local-knowledge-*, local-marketing-*,
  local-proofreader, local-bim-orchestration) during resource recovery unless customer-visible
  downtime is acceptable. Their slice and OOMScoreAdjust drop-ins take effect on the next
  natural restart (deploy, reboot, scheduled maintenance).

- Do not `chmod` against `/srv/foundry/identity/` to "fix" SSH signing failures. The keys
  are deliberately 0600. If signing fails, surface via outbox to the Command Session.

## After

Re-run `foundry-health.sh`. Status should drift from CRITICAL → WARNING → HEALTHY within
5–10 minutes as services settle.
