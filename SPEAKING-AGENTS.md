# 🎤 AAA Speaking Agents

Alle Agenten im AAA-System können jetzt mit **HumeAI Text-to-Speech** sprechen!

## Features

- 🟠 **Claude** spricht wenn er Tasks übernimmt
- 🔵 **Codex** kommentiert seine Arbeit
- 🟣 **Qwen** meldet Fortschritte

## Setup

### 1. HumeAI API Key besorgen

1. Gehe zu https://platform.hume.ai/
2. Account erstellen
3. API Key generieren

### 2. API Key konfigurieren

**Option A: Environment Variable**
```bash
export HUME_API_KEY='dein-hume-api-key'
```

**Option B: .env Datei**
```bash
cd /Users/benjaminpoersch/Projects/codebase/AAA
cp .env.example .env
# API Key in .env eintragen
```

### 3. Speaking Agent starten

```bash
# Claude (Testing/Integration)
./speaking-agents.sh /path/to/project claude

# Codex (Build/Performance)
./speaking-agents.sh /path/to/project codex

# Qwen (Bug-Fixes/Polish)
./speaking-agents.sh /path/to/project qwen
```

### 4. Alle Agenten parallel starten

```bash
# Terminal 1: Claude
./speaking-agents.sh /path/to/project claude &

# Terminal 2: Codex
./speaking-agents.sh /path/to/project codex &

# Terminal 3: Qwen
./speaking-agents.sh /path/to/project qwen &
```

## Was die Agenten sagen

### Beim Task-Claimen
> "Ich übernehme Task TASK-030: E2E-Tests laufen lassen"

### Bei Erfolg
> "Tests erfolgreich abgeschlossen."
> "Task TASK-030 erfolgreich abgeschlossen."

### Bei Fehler
> "Tests sind fehlgeschlagen. Bitte überprüfen."
> "Build fehlgeschlagen."

## Audio Output

Der Agent verwendet automatisch den verfügbaren Audio-Player:

- **macOS:** `afplay` (system-eigen)
- **Linux:** `ffplay` (von FFmpeg)

## Stumm schalten

Wenn kein API Key gesetzt ist, arbeiten die Agenten stumm:
```
🔇 TTS deaktiviert (kein API Key)
```

## Beispiele

### Claude beim Testen
```
🟠 Claude Agent gestartet (mit Hume TTS)
📁 Projekt: /path/to/project
🎤 Hume TTS: ✅ aktiv

🟠 📌 Claimed: TASK-030
🟠 🔊 Spreche: "Ich übernehme Task TASK-030: E2E-Tests laufen lassen"
🟠 🧪 Führe E2E-Tests aus...
🟠 ✅ Tests erfolgreich
🟠 🔊 Spreche: "Tests erfolgreich abgeschlossen."
🟠 ✅ Markiere TASK-030 als DONE...
🟠 🔊 Spreche: "Task TASK-030 erfolgreich abgeschlossen."
```

## Troubleshooting

### "HUME_API_KEY nicht gesetzt"
→ API Key in .env Datei oder als Environment Variable setzen

### "TTS fehlgeschlagen"
→ API Key prüfen
→ Netzwerkverbindung prüfen
→ Hume API Status prüfen: https://status.hume.ai/

### Audio wird nicht abgespielt
→ Audio Player installieren:
  - macOS: `afplay` (vorinstalliert)
  - Linux: `sudo apt install ffmpeg` (für ffplay)

---

**Version:** 1.0  
**HumeAI Docs:** https://dev.hume.ai/docs/text-to-speech-tts
