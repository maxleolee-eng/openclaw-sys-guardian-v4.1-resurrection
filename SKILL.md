---
name: lobster-guardian
description: Manage the OpenClaw "Lobster-Guardian" self-healing and disaster recovery system. Use when you need to (1) Setup health monitoring, (2) Perform configuration snapshots, (3) Execute emergency self-healing or config rollbacks, or (4) Terminate the guardian watchdog.
---

# Lobster-Guardian

This skill manages the resilience layer of OpenClaw, ensuring the agent can recover from crashes, deadlocks, or config corruption.

## Core Workflows

### 1. Monitor & Heal
The guardian runs as a macOS LaunchAgent and performs the following:
- **Ping**: Every 30m (normal) or 1m (on failure).
- **Restart**: If 4 consecutive pings fail, it forces a gateway restart.
- **Rollback**: If restart fails, it restores `openclaw.json` from the latest daily snapshot.

### 2. Manual Emergency Ops
- **Terminate**: Run `~/.openclaw/workspace/scripts/lobster-terminate.sh` to stop the watchdog.
- **Validate**: Run `~/.openclaw/workspace/scripts/lobster-validator.sh` to trigger a simulated disaster test.
- **Snapshot**: Run `~/.openclaw/workspace/scripts/lobster-snapshot.sh` to sync current config to the archive.

## References
- See [lobster-guardian-design.md](../docs/lobster-guardian-design.md) for full architecture and test cases.
