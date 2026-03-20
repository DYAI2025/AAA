# Autonomous Agentic Agility (AAA)

## Das Triple-A Framework für Multi-Agenten-Kollaboration

**Version:** 1.0 · 20. März 2026  
**Entwickelt von:** DYAI2025 · Bazodiac Team

---

## Überblick

AAA ist ein Framework für **autonome, agentische Agilität** in Multi-Agenten-Systemen. Es ermöglicht Agents, selbstständig Tasks zu generieren, zu priorisieren und abzuarbeiten — basierend auf übergeordneten Zielen, nicht auf mikromanagten Anweisungen.

---

## Die drei Säulen von AAA

### 1. **Autonomous** — Selbstständige Task-Generierung

Agents erhalten **Ziele**, nicht Tasks. Sie brainstormen im **ClawTeam-Modus** und identifizieren selbst die wahrscheinlichsten Aktionen zur Zielerreichung.

**Workflow:**
```
User gibt Ziel vor
    ↓
ClawTeam Brainstorming (Agents diskutieren)
    ↓
Tasks identifizieren (wahrscheinlichste Aktionen)
    ↓
Jeder Task → SOFORT im Board anlegen
```

### 2. **Agentic** — Agenten mit Entscheidungsfreiheit

Jeder Agent kann:
- Tasks generieren und priorisieren
- Entscheidungen treffen (basierend auf Framework-Prinzipien)
- Lernen aus Outcomes (MetaClaw Decision Framework)

**Decision Protocol:**
```
1. Dokumente lesen (BRAND_VOICE.md + TRUE_NORTH.md)
2. Prüffrage: "Bringt das den Organismus näher an sein Atmen?"
3. Drei-Schichten-Test (Kern / Myzel / Membran)
4. Fünf-Gesetze-Check
5. Brand-Voice-Check
6. Entscheidung dokumentieren (Nuggets)
```

### 3. **Agility** — Schnelle Iteration durch automatisiertes Board

Das **Nuggets Project Management System** automatisiert Board-Updates. Agents arbeiten Tasks ab, der Ticket-Manager aktualisiert alle 30 Sekunden.

**Board-Status:**
```
TODO → IN_PROGRESS → REVIEW → DONE
           ↓
       BLOCKED (mit Grund)
```

---

## Komponenten

### 1. ClawTeam Protocol

**Datei:** `CLAWTEAM-PROTOCOL.md`

Beschreibt den Workflow für Task-Generierung und Board-Management.

**Key Commands:**
```bash
# Task im Board anlegen
nuggets remember sprint-tasks "TASK-XXX" "Beschreibung | priority:high|medium|low | estimate:1-5"
nuggets remember board "TODO" "TASK-001, TASK-002, ..."

# Task starten
nuggets remember progress "TASK-XXX" "IN_PROGRESS:$(date -Iseconds)"

# Task fertigstellen
nuggets remember progress "TASK-XXX" "DONE:$(date -Iseconds):REVIEWER:none"
```

### 2. MetaClaw Decision Framework

**Datei:** `METACLAW-FRAMEWORK.md`

Entscheidungs-Matrix basierend auf True North + Brand Voice Prinzipien.

**Decision Matrix:**
- **Schichten-Test:** Obsidian-Kern / Neurales Myzel / Biolumineszente Membran
- **Fünf-Gesetze-Check:** Determinismus, Modulation, Kälte×Wärme, Prozess-Sprache, Z-Achse
- **Brand-Voice-Check:** Präzise, Warm ohne Weich, Souverän, Prozess nicht Urteil

**Learning Loop:**
```bash
# Decision dokumentieren
nuggets remember metaclaw-decisions "TASK-XXX" "Beschreibung | Schicht | Begründung"

# Pattern lernen (erfolgreich)
nuggets remember metaclaw-patterns "key" "Erfolgreiches Muster"

# Anti-Pattern lernen (zu vermeiden)
nuggets remember metaclaw-antipatterns "key" "Zu vermeidendes Muster"
```

### 3. Nuggets Project Management

**Location:** `~/Active/Claude-Workspace/nuggets/`

HRR-basiertes (Holographic Reduced Representations) Memory-System für Tasks und Board-Status.

**Ticket-Manager:**
- Läuft im Hintergrund (alle 30 Sekunden)
- Verarbeitet progress-Nuggets automatisch
- Aktualisiert Board-Spalten (TODO → IN_PROGRESS → REVIEW → DONE)

---

## Board-Struktur

### Sprint-Tasks (Bazodiac Live Space-Weather)

| Task | Beschreibung | Priority | Estimate |
|------|-------------|----------|----------|
| TASK-021 | DONKI CMEAnalysis + WSA-ENLIL anbinden | high | 3 |
| TASK-022 | NOAA SWPC X-ray/Protonen/Kp anbinden | high | 2 |
| TASK-023 | Solar Pressure Overlay: Ring-Modulation | high | 2 |
| TASK-024 | GET /api/space-weather/extended Endpoint | high | 2 |
| TASK-025 | Jieqi x Sky: Current Jieqi + Solar Activity | medium | 2 |
| TASK-026 | Geometry x Disturbance: Signifikante Events | medium | 1 |
| TASK-027 | Flare-to-Field Timeline Visualisierung | medium | 3 |
| TASK-028 | Aurora Response Layer: OVATION bei Kp >= 5 | low | 2 |
| TASK-029 | Quiz-Fixes: CloseButton entfernen | high | 2 |

---

## Usage Examples

### Beispiel 1: User gibt Ziel vor

**User:** "Ich möchte die Quiz-UX verbessern"

**ClawTeam Brainstorming → Tasks generieren → Agent arbeitet → Board aktualisiert**

### Beispiel 2: MetaClaw Decision

**Entscheidung:** "Du bist ein Paladin" vs "Deine Seele trägt den Paladin in sich"

**MetaClaw Check:** Option B erfüllt Gesetz #4 (Prozess, nicht Urteil) ✅

---

## Installation

```bash
# 1. Nuggets installieren
cd ~/Active/Claude-Workspace/nuggets
npm install

# 2. Ticket-Manager starten
nohup npx tsx src/pm/ticket-manager.ts > /tmp/ticket-manager.log 2>&1 &
```

---

## Commands

```bash
# Board anzeigen
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts show

# Task starten
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts start TASK-XXX

# Task fertigstellen
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts done TASK-XXX

# Nuggets CLI
nuggets remember <nugget> <key> <value>
nuggets recall "<query>"
nuggets facts <nugget>
```

---

## Philosophy

**Traditional PM:** Top-down (PM erstellt Tasks → Team arbeitet)  
**AAA:** Bottom-up (User gibt Ziele → Agents generieren Tasks)

**Vorteile:**
- Schnellere Iteration (kein PM-Bottleneck)
- Bessere Tasks (Agents kennen Codebase)
- Höhere Ownership (Agents entscheiden selbst)
- Kontinuierliches Lernen (MetaClaw speichert Patterns)

---

## Best Practices

✅ **DO:** Tasks SOFORT anlegen, klar beschreiben, dokumentieren, lernen  
❌ **DON'T:** Mündlich vereinbaren, vage sein, gegen True North entscheiden

---

## Links

- **Bazodiac:** https://bazodiac.space
- **Sky:** https://sky.bazodiac.space
- **Nuggets:** https://github.com/nuggets-memory/nuggets

---

*Autonomous Agentic Agility · DYAI2025 · v1.0 — 20.03.2026*
