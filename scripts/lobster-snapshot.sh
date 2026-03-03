#!/bin/bash
# Lobster Snapshot Script
# 每日凌晨 4:00 执行，生成全量核心配置快照

BACKUP_ROOT="$HOME/.openclaw/backups/daily"
TIMESTAMP=$(date +"%Y-%m-%d")
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
mkdir -p "${BACKUP_DIR}"

# 原子复制核心路径
cp -v "$HOME/.openclaw/openclaw.json" "${BACKUP_DIR}/"
# 若存在授权配置文件，连带复制（注意：不含 workspace 下的大文件，仅关注灵魂与身份）
[ -f "$HOME/.openclaw/agents/main/agent/auth-profiles.json" ] && cp -v "$HOME/.openclaw/agents/main/agent/auth-profiles.json" "${BACKUP_DIR}/"

# 复制核心配置文件（AGENTS, SOUL, USER, TOOLS, IDENTITY）
cp -v "$HOME/.openclaw/workspace/"*.md "${BACKUP_DIR}/"

# 清理旧备份：保留最近 7 天
find "${BACKUP_ROOT}" -type d -mtime +7 -exec rm -rf {} +

echo "Snapshot [${TIMESTAMP}] Completed. 🦞"
