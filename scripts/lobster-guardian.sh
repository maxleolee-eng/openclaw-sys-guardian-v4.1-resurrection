#!/bin/bash
# Lobster Guardian Script
# 核心逻辑：30min 心跳检测，异常时 1min 密集探测，连续 4 次失败自动执行强力自愈

# 配置信息
GATEWAY_URL="http://127.0.0.1:18789"
LOG_FILE="$HOME/.openclaw/lobster-guardian.log"
FEISHU_APP_ID="cli_a91a0a8798f8dcb0"
FEISHU_APP_SECRET="SrnYhDKBa6IfLnEw00QmzftspSbIikzk"
FAIL_COUNT=0
THRESHOLD=4
POLL_INTERVAL=1800 # 30 min
RETRY_INTERVAL=60  # 1 min

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

notify_feishu() {
    # 极简飞书消息推送逻辑 (通过 appId/Secret 获取 token 并发送)
    local msg=$1
    # 实际部署时此处可调用 openclaw message 工具或 curl
    log "FEISHU NOTIFY: $msg"
    # openclaw message send --message "🦞 [LOBSTER-GUARDIAN] $msg"
}

check_health() {
    # 探测 Gateway 健康接口
    local response=$(curl -s -m 5 -o /dev/null -w "%{http_code}" "${GATEWAY_URL}/health")
    if [ "$response" == "200" ]; then
        return 0
    else
        return 1
    fi
}

self_heal() {
    log "CRITICAL: Service Failure Detected. Initiating Self-Healing Pattern..."
    notify_feishu "检测到服务持续失效，正在启动强力自愈模式..."

    # 1. 强制强杀残留进程
    log "Action: Killing zombie processes on port 18789..."
    lsof -ti:18789 | xargs kill -9 2>/dev/null

    # 2. 调用 OpenClaw 官方重启指令
    log "Action: Restarting gateway --force..."
    /opt/homebrew/bin/openclaw gateway restart --force >> "$LOG_FILE" 2>&1

    sleep 10

    # 3. 验证是否恢复
    if check_health; then
        log "SUCCESS: Service Restored."
        notify_feishu "服务已成功自动修复，当前状态：OK。"
        FAIL_COUNT=0
    else
        log "ERROR: Restart failed. Attempting config rollback..."
        # 此处预留回滚逻辑：cp $HOME/.openclaw/backups/daily/$(date +%Y-%m-%d)/openclaw.json $HOME/.openclaw/
        notify_feishu "服务重启失败，可能需要人工干预！"
    fi
}

log "Guardian Started. Monitoring Lobster Commander..."

while true; do
    if check_health; then
        [ $FAIL_COUNT -gt 0 ] && log "Service Recovered (Transient Issue)."
        FAIL_COUNT=0
        sleep $POLL_INTERVAL
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        log "Warning: Health Check Failed ($FAIL_COUNT/$THRESHOLD)."
        
        if [ $FAIL_COUNT -ge $THRESHOLD ]; then
            self_heal
            sleep $POLL_INTERVAL
        else
            sleep $RETRY_INTERVAL
        fi
    fi
done
