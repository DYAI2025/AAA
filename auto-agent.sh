#!/bin/bash
# AAA Auto-Agent — Autonomous Task Execution
# Läuft kontinuierlich und arbeitet Tasks selbstständig ab

set -e

NUGGETS_DIR="$HOME/Active/Claude-Workspace/nuggets"
PROJECT_DIR="$1"

if [ -z "$PROJECT_DIR" ]; then
    echo "Usage: auto-agent.sh <project-dir>"
    echo "Example: auto-agent.sh /Users/benjaminpoersch/Projects/codebase/Bazodiac-WebApp/Astro-Noctum"
    exit 1
fi

echo "🤖 AAA Auto-Agent gestartet"
echo "📁 Projekt: $PROJECT_DIR"
echo "⏱️  Intervall: 60 Sekunden"
echo ""

while true; do
    cd "$NUGGETS_DIR"
    
    # Nächste Task holen
    NEXT_TASK=$(npx tsx src/pm/board-cli.ts next 2>/dev/null | grep "📌 Next task:" | awk '{print $3}')
    
    if [ -z "$NEXT_TASK" ]; then
        echo "⏸️  Keine Tasks im TODO-Board"
        sleep 60
        continue
    fi
    
    echo "📌 Nächste Task: $NEXT_TASK"
    
    # Task-Details holen
    TASK_DETAILS=$(nuggets facts sprint-tasks | grep "$NEXT_TASK:" | sed "s/.*$NEXT_TASK: //")
    echo "   $TASK_DETAILS"
    
    # Prüfen ob Task schon IN_PROGRESS ist (verhindert Doppelverarbeitung)
    IN_PROGRESS=$(nuggets facts board | grep "IN_PROGRESS:" | grep "$NEXT_TASK")
    if [ -n "$IN_PROGRESS" ]; then
        echo "⏳ Task ist bereits IN_PROGRESS (wird von anderem Agenten bearbeitet)"
        sleep 60
        continue
    fi
    
    # Task starten
    echo "▶️  Starte $NEXT_TASK..."
    npx tsx src/pm/board-cli.ts start "$NEXT_TASK"
    
    # Task-spezifische Logik ausführen
    cd "$PROJECT_DIR"
    
    case "$NEXT_TASK" in
        TASK-030)
            echo "   🧪 Führe E2E-Tests aus..."
            npm run test -- src/__tests__/encounter-quiz-phase.test.tsx > /tmp/task-030.log 2>&1 && \
                echo "   ✅ Tests erfolgreich" || \
                echo "   ❌ Tests fehlgeschlagen"
            ;;
        TASK-031)
            echo "   🔍 Prüfe App.tsx Integration..."
            grep -q "cosmic_encounter_v1" src/App.tsx && \
                echo "   ✅ Integration verifiziert" || \
                echo "   ❌ Integration nicht gefunden"
            ;;
        TASK-032)
            echo "   📦 Prüfe Bundle-Size..."
            npm run build > /tmp/task-032.log 2>&1 && \
                echo "   ✅ Build erfolgreich" || \
                echo "   ❌ Build fehlgeschlagen"
            ;;
        TASK-033)
            echo "   🐛 Bearbeite Bug-Fixes..."
            echo "   ⏳ Manuelle Prüfung erforderlich"
            ;;
        *)
            echo "   🔧 Allgemeine Task: $NEXT_TASK"
            echo "   ⏳ Manuelle Prüfung erforderlich"
            ;;
    esac
    
    # Task als DONE markieren
    cd "$NUGGETS_DIR"
    echo "✅ Markiere $NEXT_TASK als DONE..."
    npx tsx src/pm/board-cli.ts done "$NEXT_TASK"
    
    # MetaClaw Decision dokumentieren
    echo "🧠 Dokumentiere Decision..."
    nuggets remember metaclaw-decisions "$NEXT_TASK-AUTO" "Auto-Agent ausgeführt | $(date -Iseconds)"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 60 Sekunden warten bevor nächste Task
    sleep 60
done
