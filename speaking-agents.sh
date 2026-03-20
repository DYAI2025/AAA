#!/bin/bash
# AAA Speaking Agents — Alle Agenten können jetzt sprechen!
# Verwendet HumeAI MCP-Server für Text-to-Speech

set -e

NUGGETS_DIR="$HOME/Active/Claude-Workspace/nuggets"
PROJECT_DIR="$1"
AGENT_NAME="$2"
HUME_API_KEY="${HUME_API_KEY:-}"

if [ -z "$PROJECT_DIR" ] || [ -z "$AGENT_NAME" ]; then
    echo "Usage: speaking-agents.sh <project-dir> <agent-name>"
    echo "Agents: claude, codex, qwen"
    echo ""
    echo "Environment:"
    echo "  HUME_API_KEY: Dein Hume AI API Key (oder in .env Datei)"
    exit 1
fi

if [ -z "$HUME_API_KEY" ]; then
    echo "⚠️  HUME_API_KEY nicht gesetzt!"
    echo "   Bitte setze den API Key:"
    echo "   export HUME_API_KEY='dein-key'"
    echo "   Oder erstelle eine .env Datei im AAA Ordner"
    echo ""
fi

# Agent-spezifische Konfiguration
case "$AGENT_NAME" in
    claude)
        AGENT_COLOR="🟠"
        VOICE_ID="default" # Hume default voice
        echo "$AGENT_COLOR Claude Agent gestartet (mit Hume TTS)"
        ;;
    codex)
        AGENT_COLOR="🔵"
        VOICE_ID="default"
        echo "$AGENT_COLOR Codex Agent gestartet (mit Hume TTS)"
        ;;
    qwen)
        AGENT_COLOR="🟣"
        VOICE_ID="default"
        echo "$AGENT_COLOR Qwen Agent gestartet (mit Hume TTS)"
        ;;
    *)
        echo "❌ Unbekannter Agent: $AGENT_NAME"
        exit 1
        ;;
esac

# Funktion: Hume TTS aufrufen
speak() {
    local text="$1"
    local output_file="/tmp/hume-tts-${AGENT_NAME}-$(date +%s).mp3"
    
    if [ -z "$HUME_API_KEY" ]; then
        echo "$AGENT_COLOR 🔇 TTS deaktiviert (kein API Key)"
        return
    fi
    
    echo "$AGENT_COLOR 🔊 Spreche: \"$text\""
    
    # Hume TTS API aufrufen
    curl -s -X POST "https://api.hume.ai/v0/tts/synthesize" \
        -H "Content-Type: application/json" \
        -H "X-Hume-Api-Key: $HUME_API_KEY" \
        -d "{
            \"text\": \"$text\",
            \"voice\": { \"type\": \"default\" }
        }" \
        -o "$output_file"
    
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        echo "$AGENT_COLOR ✅ Audio generiert: $output_file"
        # Audio abspielen (wenn Player verfügbar)
        if command -v afplay &> /dev/null; then
            afplay "$output_file" &
        elif command -v ffplay &> /dev/null; then
            ffplay -nodisp -autoexit -loglevel quiet "$output_file" &
        fi
    else
        echo "$AGENT_COLOR ❌ TTS fehlgeschlagen"
    fi
}

echo "📁 Projekt: $PROJECT_DIR"
echo "🎤 Hume TTS: ${HUME_API_KEY:+✅ aktiv} ${HUME_API_KEY:-❌ nicht konfiguriert}"
echo "⏱️  Intervall: 30 Sekunden"
echo ""

while true; do
    cd "$NUGGETS_DIR"
    
    # Nächste Task holen
    NEXT_TASK=$(npx tsx src/pm/board-cli.ts next 2>/dev/null | grep "📌 Next task:" | awk '{print $3}')
    
    if [ -z "$NEXT_TASK" ]; then
        echo "$AGENT_COLOR ⏸️  Keine Tasks im TODO-Board"
        speak "Keine Tasks im Board. Ich warte auf neue Aufgaben."
        sleep 30
        continue
    fi
    
    # Task-Details holen
    TASK_DETAILS=$(nuggets facts sprint-tasks | grep "$NEXT_TASK:" | sed "s/.*$NEXT_TASK: //")
    TASK_DESC=$(echo "$TASK_DETAILS" | cut -d'|' -f1)
    
    # Prüfen ob Task schon IN_PROGRESS ist
    IN_PROGRESS=$(nuggets facts board | grep "IN_PROGRESS:" | grep "$NEXT_TASK")
    if [ -n "$IN_PROGRESS" ]; then
        echo "$AGENT_COLOR ⏳ Task $NEXT_TASK wird bereits bearbeitet"
        sleep 30
        continue
    fi
    
    # Agent-spezifische Task-Auswahl
    CLAIMED=false
    
    case "$AGENT_NAME" in
        claude)
            if echo "$TASK_DESC" | grep -qiE "test|integration|doc|e2e|verify"; then
                CLAIMED=true
            fi
            ;;
        codex)
            if echo "$TASK_DESC" | grep -qiE "build|performance|bundle|refactor|optimize"; then
                CLAIMED=true
            fi
            ;;
        qwen)
            if echo "$TASK_DESC" | grep -qiE "bug|fix|polish|ui|ux|closebutton"; then
                CLAIMED=true
            fi
            ;;
    esac
    
    if [ "$CLAIMED" = false ]; then
        echo "$AGENT_COLOR ⏭️  Task $NEXT_TASK passt nicht zu meinen Spezialitäten"
        sleep 30
        continue
    fi
    
    # Task claimen (mit Sprachausgabe!)
    echo "$AGENT_COLOR 📌 Claimed: $NEXT_TASK"
    speak "Ich übernehme Task $NEXT_TASK: $TASK_DESC"
    
    echo "$AGENT_COLOR ▶️  Starte..."
    npx tsx src/pm/board-cli.ts start "$NEXT_TASK"
    
    # Task-spezifische Logik ausführen
    cd "$PROJECT_DIR"
    
    case "$NEXT_TASK" in
        TASK-030)
            echo "$AGENT_COLOR 🧪 Führe E2E-Tests aus..."
            if npm run test -- src/__tests__/encounter-quiz-phase.test.tsx > /tmp/$AGENT_NAME-$NEXT_TASK.log 2>&1; then
                echo "$AGENT_COLOR ✅ Tests erfolgreich"
                speak "Tests erfolgreich abgeschlossen."
                RESULT="SUCCESS"
            else
                echo "$AGENT_COLOR ❌ Tests fehlgeschlagen"
                speak "Tests sind fehlgeschlagen. Bitte überprüfen."
                RESULT="FAILED"
            fi
            ;;
        TASK-031)
            echo "$AGENT_COLOR 🔍 Prüfe App.tsx Integration..."
            if grep -q "cosmic_encounter_v1" src/App.tsx; then
                echo "$AGENT_COLOR ✅ Integration verifiziert"
                speak "Integration erfolgreich verifiziert."
                RESULT="SUCCESS"
            else
                echo "$AGENT_COLOR ❌ Integration nicht gefunden"
                speak "Integration nicht gefunden."
                RESULT="FAILED"
            fi
            ;;
        TASK-032)
            echo "$AGENT_COLOR 📦 Prüfe Bundle-Size..."
            if npm run build > /tmp/$AGENT_NAME-$NEXT_TASK.log 2>&1; then
                echo "$AGENT_COLOR ✅ Build erfolgreich"
                speak "Build erfolgreich."
                RESULT="SUCCESS"
            else
                echo "$AGENT_COLOR ❌ Build fehlgeschlagen"
                speak "Build fehlgeschlagen."
                RESULT="FAILED"
            fi
            ;;
        *)
            echo "$AGENT_COLOR 🔧 Bearbeite Task: $NEXT_TASK"
            RESULT="MANUAL"
            ;;
    esac
    
    # Task als DONE markieren (wenn erfolgreich)
    cd "$NUGGETS_DIR"
    if [ "$RESULT" = "SUCCESS" ]; then
        echo "$AGENT_COLOR ✅ Markiere $NEXT_TASK als DONE..."
        speak "Task $NEXT_TASK erfolgreich abgeschlossen."
        npx tsx src/pm/board-cli.ts done "$NEXT_TASK"
        
        # MetaClaw Decision dokumentieren
        echo "$AGENT_COLOR 🧠 Dokumentiere Decision..."
        nuggets remember metaclaw-decisions "$NEXT_TASK-$AGENT_NAME" "$AGENT_NAME ausgeführt | Ergebnis: $RESULT | $(date -Iseconds)"
    else
        echo "$AGENT_COLOR ⏸️  Task $NEXT_TASK benötigt manuelle Prüfung"
    fi
    
    echo ""
    echo "$AGENT_COLOR ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 30 Sekunden warten bevor nächste Task
    sleep 30
done
