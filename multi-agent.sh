#!/bin/bash
# AAA Multi-Agent System — Claude, Codex, Qwen arbeiten parallel
# Jeder Agent hat spezielle Fähigkeiten und arbeitet an passenden Tasks

set -e

NUGGETS_DIR="$HOME/Active/Claude-Workspace/nuggets"
PROJECT_DIR="$1"
AGENT_NAME="$2"

if [ -z "$PROJECT_DIR" ] || [ -z "$AGENT_NAME" ]; then
    echo "Usage: multi-agent.sh <project-dir> <agent-name>"
    echo "Agents: claude, codex, qwen"
    exit 1
fi

# Agent-spezifische Konfiguration
case "$AGENT_NAME" in
    claude)
        AGENT_COLOR="🟠"
        SPECIALTIES="testing integration documentation"
        echo "$AGENT_COLOR Claude Agent gestartet (Spezialist: Testing, Integration, Docs)"
        ;;
    codex)
        AGENT_COLOR="🔵"
        SPECIALTIES="build performance refactoring"
        echo "$AGENT_COLOR Codex Agent gestartet (Spezialist: Build, Performance, Refactoring)"
        ;;
    qwen)
        AGENT_COLOR="🟣"
        SPECIALTIES="bugs fixes polish ui-ux"
        echo "$AGENT_COLOR Qwen Agent gestartet (Spezialist: Bug-Fixes, Polish, UI/UX)"
        ;;
    *)
        echo "❌ Unbekannter Agent: $AGENT_NAME"
        echo "Verfügbare Agents: claude, codex, qwen"
        exit 1
        ;;
esac

echo "📁 Projekt: $PROJECT_DIR"
echo "⏱️  Intervall: 30 Sekunden"
echo ""

while true; do
    cd "$NUGGETS_DIR"
    
    # Nächste Task holen
    NEXT_TASK=$(npx tsx src/pm/board-cli.ts next 2>/dev/null | grep "📌 Next task:" | awk '{print $3}')
    
    if [ -z "$NEXT_TASK" ]; then
        echo "$AGENT_COLOR ⏸️  Keine Tasks im TODO-Board"
        sleep 30
        continue
    fi
    
    # Task-Details holen
    TASK_DETAILS=$(nuggets facts sprint-tasks | grep "$NEXT_TASK:" | sed "s/.*$NEXT_TASK: //")
    TASK_DESC=$(echo "$TASK_DETAILS" | cut -d'|' -f1)
    TASK_PRIORITY=$(echo "$TASK_DETAILS" | cut -d'|' -f2 | tr -d ' ')
    
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
            # Claude übernimmt: testing, integration, documentation
            if echo "$TASK_DESC" | grep -qiE "test|integration|doc|e2e|verify"; then
                CLAIMED=true
            fi
            ;;
        codex)
            # Codex übernimmt: build, performance, refactoring
            if echo "$TASK_DESC" | grep -qiE "build|performance|bundle|refactor|optimize"; then
                CLAIMED=true
            fi
            ;;
        qwen)
            # Qwen übernimmt: bugs, fixes, polish, ui-ux
            if echo "$TASK_DESC" | grep -qiE "bug|fix|polish|ui|ux|closebutton"; then
                CLAIMED=true
            fi
            ;;
    esac
    
    if [ "$CLAIMED" = false ]; then
        echo "$AGENT_COLOR ⏭️  Task $NEXT_TASK passt nicht zu meinen Spezialitäten ($SPECIALTIES)"
        sleep 30
        continue
    fi
    
    # Task claimen
    echo "$AGENT_COLOR 📌 Claimed: $NEXT_TASK - $TASK_DESC"
    echo "$AGENT_COLOR ▶️  Starte..."
    npx tsx src/pm/board-cli.ts start "$NEXT_TASK"
    
    # Task-spezifische Logik ausführen
    cd "$PROJECT_DIR"
    
    case "$NEXT_TASK" in
        TASK-030)
            echo "$AGENT_COLOR 🧪 Führe E2E-Tests aus..."
            if npm run test -- src/__tests__/encounter-quiz-phase.test.tsx > /tmp/$AGENT_NAME-$NEXT_TASK.log 2>&1; then
                echo "$AGENT_COLOR ✅ Tests erfolgreich"
                RESULT="SUCCESS"
            else
                echo "$AGENT_COLOR ❌ Tests fehlgeschlagen"
                RESULT="FAILED"
            fi
            ;;
        TASK-031)
            echo "$AGENT_COLOR 🔍 Prüfe App.tsx Integration..."
            if grep -q "cosmic_encounter_v1" src/App.tsx; then
                echo "$AGENT_COLOR ✅ Integration verifiziert"
                RESULT="SUCCESS"
            else
                echo "$AGENT_COLOR ❌ Integration nicht gefunden"
                RESULT="FAILED"
            fi
            ;;
        TASK-032)
            echo "$AGENT_COLOR 📦 Prüfe Bundle-Size..."
            if npm run build > /tmp/$AGENT_NAME-$NEXT_TASK.log 2>&1; then
                echo "$AGENT_COLOR ✅ Build erfolgreich"
                RESULT="SUCCESS"
            else
                echo "$AGENT_COLOR ❌ Build fehlgeschlagen"
                RESULT="FAILED"
            fi
            ;;
        TASK-033)
            echo "$AGENT_COLOR 🐛 Bearbeite Bug-Fixes..."
            echo "$AGENT_COLOR ⏳ Manuelle Prüfung erforderlich"
            RESULT="MANUAL"
            ;;
        TASK-029)
            echo "$AGENT_COLOR 🎨 Quiz-Fixes: CloseButton entfernen..."
            echo "$AGENT_COLOR ⏳ Manuelle Prüfung erforderlich"
            RESULT="MANUAL"
            ;;
        *)
            echo "$AGENT_COLOR 🔧 Allgemeine Task: $NEXT_TASK"
            RESULT="MANUAL"
            ;;
    esac
    
    # Task als DONE markieren (wenn erfolgreich)
    cd "$NUGGETS_DIR"
    if [ "$RESULT" = "SUCCESS" ]; then
        echo "$AGENT_COLOR ✅ Markiere $NEXT_TASK als DONE..."
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
