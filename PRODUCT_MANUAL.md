# OpenClaw 龙虾守护 (OpenClaw-Sys-Guardian) 产品技术白皮书

> **版本：** v4.1.2 "Resurrection"  
> **状态：** Dragon-class High Availability (龙级高可用)  
> **核心使命：** 确保龙虾指挥官的人格、记忆与技能集群在任何极端环境下均可实现“秒级复活”与“逻辑一致性”。

---

## 一、 设计背景与目标 (Vision)
在高度复杂的 AI 自动化环境中，系统的脆弱性往往源于：环境崩溃导致配置丢失、技能删除导致记忆错位。
**龙虾守护** 的目标是构建一个脱离主进程运行的、具备自主权和镜像能力的“影子中枢”，实现：
1. **物理隔离备份**：将灵魂（记忆/设定）镜像至本机非系统目录。
2. **逻辑闭环自愈**：不仅恢复文件，更要对齐技能与记忆的对应关系。
3. **极限灾难复原**：系统全挂后，通过外部指令实现“一键灵魂搬迁”。

---

## 二、 系统架构 (Architecture)
采用“三位一体”分层保护架构：
1. **Snapshot 层**：每日凌晨 05:00 捕获 workspace、config、memory 的全量二进制/文本快照。
2. **Buffer 层**：在 `/storage/` 子目录建立多级缓冲区，解耦“生产”与“投递”环节。
3. **Resurrection 层**：独立于主进程的 shell 脚本集，负责在系统重启或初始化阶段执行强力注入。

---

## 三、 功能详情与描述 (Features)

### 1. 龙镜同步 (Lobster-Mirror)
- **描述**：使用增量 rsync 算法将 `~/.openclaw` 同步至用户下载目录的 `OpenClaw_Mirror`。
- **价值**：利用 macOS 用户级高频备份特性（如 iCloud）实现二次冗余。

### 2. 技能树感知审计 (Skill-Tree Alignment)
- **描述**：`lobster-validator.sh` 扫描记忆设定中的技能关键词。
- **功能**：对比 `clawhub list`。若缺失，主动提示补装；若用户放弃，执行“记忆清创”（剪枝），抹除相关 SOP，防止调用报错。

### 3. 终极复活协议 (Ultimate Restore)
- **描述**：`lobster-ultimate-restore.sh` 提供“强力模式”。
- **操作**：从外部镜像镜像回导全量数据，覆盖崩溃的旧系统。

---

## 四、 关键逻辑代码流程 (Workflow & Key Logic)

### 1. 外部恢复核心逻辑 (`lobster-ultimate-restore.sh`)：
```bash
# 原子级搬运逻辑
rsync -av --delete "$MIRROR_SOURCE/workplace/" "$SYSTEM_TARGET/workspace/"
cp "$MIRROR_SOURCE/config/config.json" "$SYSTEM_TARGET/config.json"

# 自动对齐审计
sh ./lobster-validator.sh
```

### 2. 技能-记忆对齐伪代码：
```javascript
// 如果记录存在但技能缺失
if (memory.contains("reddit-tool") && !system.hasSkill("reddit-readonly")) {
    prompt_user("发现技能缺失，是否补装？");
    if (user_decline) {
        agents_md.prune("reddit-readonly SOP");
    }
}
```

---

## 五、 操作流程 (SOP)

### 1. 部署阶段
- `clawhub install openclaw-sys-guardian-v4.1.2`
- 系统会自动建立 `/storage/` 和 `/Downloads/OpenClaw_Mirror/`。

### 2. 恢复阶段 (崩溃后)
- 执行：`sh ./scripts/lobster-ultimate-restore.sh`
- 此脚本会引导您完成灵魂注入与技能重塑。

---

## 六、 风险对策与注意事项 (Risk & Mitigation)

| 潜在风险 | 预防/对策 |
| :--- | :--- |
| **磁盘空间溢出** | 镜像采用 `rsync` 增量模式，且设有 50MB 自动清理警报。 |
| **镜像文件被用户误删** | 将同步任务挂载至心跳自检，缺失目录时自动补全。 |
| **配置冲突** | 恢复前强制执行备份校验，配置版本号不对齐时不予覆盖。 |

---
*龙虾指挥官 🦞 - 踏实、客观、认真，数据永存。*
