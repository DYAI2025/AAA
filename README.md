# Autonomous Agentic Agility (AAA)

## Das Triple-A Framework für Multi-Agenten-Kollaboration

**Version:** 1.0 · 20. März 2026  
**Entwickelt von:** DYAI2025

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
1. Dokumente lesen (TRUENORTH.md + BRANDVOICE.md + GOAL.md)
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

## Setup (3 Dateien erstellen)

Bevor du AAA verwendest, erstelle diese **drei Dokumente** in deinem Projekt:

### 1. TRUENORTH.md

**Zweck:** Die übergeordneten Prinzipien und Werte deines Projekts.

**Inhalt:**
- Was ist dein Projekt? Was ist es nicht?
- Die 3-5 Kernprinzipien (wie "Die fünf Gesetze")
- Die Prüffrage für Entscheidungen
- Architektonische Schichten (Kern / Myzel / Membran)

**Beispiel-Struktur:**
```markdown
# [Projektname] — True North

## Was [Projekt] ist
[Ein-Satz-Definition]

## Was [Projekt] nicht ist
[Abgrenzung]

## Die [X] Gesetze
1. [Gesetz 1]
2. [Gesetz 2]
...

## Die Prüffrage
"[Entscheidungsfrage]"
```

### 2. BRANDVOICE.md

**Zweck:** Die Kommunikations- und Entscheidungsrichtlinien.

**Inhalt:**
- Voice Attribute (wie "Präzise", "Warm ohne Weich", "Souverän")
- Tonalität pro Kontext (Onboarding, Daily, Error, etc.)
- Terminologie (verwende X, nicht Y)
- Stil-Regeln (Grammatik, Formatierung)

**Beispiel-Struktur:**
```markdown
# [Projektname] — Brand Voice

## Voice Attribute
1. **[Attribut 1]**: [Beschreibung]
2. **[Attribut 2]**: [Beschreibung]
...

## Tonalitäts-Spektrum
| Kontext | Dial Up | Dial Down |
|---------|---------|-----------|
| Onboarding | Wärme | Präzision |
| Error | Präzision | Wärme |

## Terminologie
| Verwende | Nicht verwenden |
|----------|-----------------|
| Signatur | Profil |
| Muster | Eigenschaft |
```

### 3. GOAL.md

**Zweck:** Das aktuelle Ziel / Sprint-Ziel.

**Inhalt:**
- Übergeordnetes Ziel (1-2 Sätze)
- Erfolgskriterien (wann ist es erreicht?)
- Constraints (was ist tabu?)
- Timeline (optional)

**Beispiel-Struktur:**
```markdown
# [Projektname] — Current Goal

## Sprint-Ziel
[Übergeordnetes Ziel in 1-2 Sätzen]

## Erfolgskriterien
- [ ] Kriterium 1
- [ ] Kriterium 2
- [ ] Kriterium 3

## Constraints
- [Tabu 1]
- [Tabu 2]

## Timeline
[Start] → [Ende]
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

Entscheidungs-Matrix basierend auf deinen Prinzipien (TRUENORTH.md + BRANDVOICE.md).

**Decision Matrix:**
- **Schichten-Test:** Welche Schicht wird bedient?
- **Prinzipien-Check:** Verletzt es eines der Gesetze?
- **Voice-Check:** Entspricht es der Brand Voice?
- **Goal-Check:** Bringt es uns dem Ziel näher?

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

## Workflow

### Phase 1: Setup

```bash
# 1. Drei Dokumente erstellen
cat > TRUENORTH.md    # Prinzipien
cat > BRANDVOICE.md   # Kommunikation
cat > GOAL.md         # Aktuelles Ziel

# 2. Nuggets installieren
cd ~/Active/Claude-Workspace/nuggets
npm install

# 3. Ticket-Manager starten
nohup npx tsx src/pm/ticket-manager.ts > /tmp/ticket-manager.log 2>&1 &
```

### Phase 2: ClawTeam Brainstorming

```
User gibt Ziel (aus GOAL.md)
    ↓
Agents lesen TRUENORTH.md + BRANDVOICE.md
    ↓
ClawTeam Brainstorming (Agents diskutieren)
    ↓
Tasks identifizieren
    ↓
Jeder Task → SOFORT im Board anlegen
```

### Phase 3: Task-Abarbeitung

```bash
# 1. Task holen
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts next

# 2. Task starten
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts start TASK-XXX

# 3. Decision treffen (MetaClaw)
# - Dokumente lesen
# - Prüffrage stellen
# - Decision dokumentieren
nuggets remember metaclaw-decisions "TASK-XXX" "Beschreibung | Schicht | Begründung"

# 4. Arbeiten...

# 5. Task fertigstellen
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts done TASK-XXX

# 6. Pattern lernen
nuggets remember metaclaw-patterns "key" "Erfolgreiches Muster"
```

---

## Decision Template

**Vor JEDER Entscheidung ausfüllen:**

```markdown
## Decision: [Name]

### Dokumente gelesen
- [ ] TRUENORTH.md
- [ ] BRANDVOICE.md
- [ ] GOAL.md

### Prüffrage
"Bringt das den Organismus näher an sein Atmen — oder entfernt es ihn davon?"
Antwort: [Ja / Nein / Unklar]

### Schichten-Test
- [ ] Kern: Dient / Berührt / Neutral
- [ ] Myzel: Dient / Berührt / Neutral
- [ ] Membran: Dient / Berührt / Neutral

### Prinzipien-Check
- [ ] Gesetz 1: ✅ / ❌
- [ ] Gesetz 2: ✅ / ❌
- [ ] Gesetz 3: ✅ / ❌
- [ ] Gesetz 4: ✅ / ❌
- [ ] Gesetz 5: ✅ / ❌

### Voice-Check
- [ ] Attribut 1: ✅ / ❌
- [ ] Attribut 2: ✅ / ❌
- [ ] Attribut 3: ✅ / ❌

### Goal-Check
- [ ] Bringt uns näher an GOAL.md Ziel: ✅ / ❌

### Entscheidung
✅ BAUEN / ❌ NICHT BAUEN / ⚠️ ANPASSEN

### Begründung
[Kurze Erklärung]
```

---

## Commands Übersicht

### Board-Management

```bash
# Board anzeigen
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts show

# Nächste Task holen
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts next

# Task starten
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts start TASK-XXX

# Task fertigstellen (ohne Review)
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts done TASK-XXX

# Task fertigstellen (mit Review)
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts done TASK-XXX @reviewer

# Task blockieren
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts block TASK-XXX "Waiting for X"

# Neue Task hinzufügen
npx tsx ~/Active/Claude-Workspace/nuggets/src/pm/board-cli.ts add TASK-XXX "Beschreibung | priority:high | estimate:2"
```

### Nuggets CLI

```bash
# Fact speichern
nuggets remember <nugget> <key> <value>

# Fact abrufen
nuggets recall "<query>" [--nugget <name>]

# Facts auflisten
nuggets facts <nugget>

# Alle Nuggets auflisten
nuggets list
```

---

## Best Practices

### DOs

✅ **Drei Dokumente VOR Start erstellen** — Ohne Prinzipien keine konsistenten Entscheidungen  
✅ **Jeden Task SOFORT nach Brainstorming anlegen** — Nicht "später machen"  
✅ **Task-ID eindeutig** — TASK-001, TASK-002, ... fortlaufend  
✅ **Beschreibung klar** — Was + warum (nicht wie)  
✅ **Priority setzen** — high/medium/low  
✅ **Estimate setzen** — 1-5 Tage  
✅ **Nach Commit updaten** — DONE oder REVIEW  
✅ **Entscheidungen dokumentieren** — metaclaw-decisions  
✅ **Lernen aus Outcomes** — metaclaw-patterns / antipatterns  

### DON'Ts

❌ **Dokumente ignorieren** — Immer TRUENORTH.md + BRANDVOICE.md lesen  
❌ **Tasks mündlich vereinbaren** — Immer im Board  
❌ **Task-Beschreibungen vage** — "Fix bug" → "CloseButton aus Component X entfernen"  
❌ **Priority vergessen** — Ohne Priority kann nicht priorisiert werden  
❌ **Estimate zu hoch** — >5 Tage = Task aufteilen  
❌ **Entscheidungen nicht dokumentieren** — Lernen geht verloren  
❌ **Gegen eigene Prinzipien entscheiden** — Prüffrage immer stellen  

---

## Metriken

### Sprint-Velocity

```bash
# Tasks pro Woche zählen
nuggets facts board | grep "DONE" | wc -w
```

### Decision-Quality

```bash
# Positive Patterns vs Anti-Patterns
nuggets facts metaclaw-patterns | wc -l
nuggets facts metaclaw-antipatterns | wc -l
# Ziel: Mehr Patterns als Anti-Patterns
```

### Board-Health

```
Ideales Board:
- TODO: 5-15 Tasks (nicht überladen, nicht leer)
- IN_PROGRESS: 1-3 Tasks (Fokus)
- REVIEW: 0-2 Tasks (schnelles Feedback)
- DONE: Wächst kontinuierlich
- BLOCKED: 0 Tasks (oder schnell auflösen)
```

---

## Troubleshooting

### Ticket-Manager läuft nicht

```bash
# Prozess prüfen
ps aux | grep ticket-manager

# Neu starten
cd ~/Active/Claude-Workspace/nuggets
npx tsx src/pm/ticket-manager.ts &
```

### Board zeigt alte Tasks

```bash
# Board manuell aktualisieren
nuggets remember board "TODO" "TASK-001, TASK-002, ..."
```

### Nuggets CLI nicht gefunden

```bash
# Nuggets installieren
pip install nuggets

# Oder lokale Version verwenden
cd ~/Active/Claude-Workspace/nuggets
npm install
```

---

## License

MIT License — DYAI2025

---

## Links

- **Nuggets Memory:** https://github.com/nuggets-memory/nuggets
- **Bazodiac (Referenz-Implementierung):** https://bazodiac.space

---

*Autonomous Agentic Agility · DYAI2025 · v1.0 — 20.03.2026*
