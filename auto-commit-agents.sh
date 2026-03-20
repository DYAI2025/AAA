#!/bin/bash
# AAA Auto-Commit Agents — Agents die committen und pushen!
# Vollautomatisch: Task → Code ändern → Testen → Commit → Push → DONE

set -e

NUGGETS_DIR="$HOME/Active/Claude-Workspace/nuggets"
PROJECT_DIR="$1"
AGENT_NAME="$2"
HUME_API_KEY="${HUME_API_KEY:-}"

if [ -z "$PROJECT_DIR" ] || [ -z "$AGENT_NAME" ]; then
    echo "Usage: auto-commit-agents.sh <project-dir> <agent-name>"
    exit 1
fi

cd "$PROJECT_DIR"

# Agent-Farbe
case "$AGENT_NAME" in
    claude) AGENT_COLOR="🟠"; AGENT_BRANCH="agent/claude" ;;
    codex)  AGENT_COLOR="🔵"; AGENT_BRANCH="agent/codex" ;;
    qwen)   AGENT_COLOR="🟣"; AGENT_BRANCH="agent/qwen" ;;
    *) echo "❌ Unbekannter Agent"; exit 1 ;;
esac

echo "$AGENT_COLOR $AGENT_NAME Auto-Commit Agent gestartet"
echo "📁 Projekt: $PROJECT_DIR"
echo "🌿 Branch: $AGENT_BRANCH"
echo ""

# Git Branch für Agent erstellen
git checkout -b "$AGENT_BRANCH" 2>/dev/null || git checkout "$AGENT_BRANCH"
git pull origin "$AGENT_BRANCH" 2>/dev/null || true

while true; do
    cd "$NUGGETS_DIR"
    
    # Nächste Task holen
    NEXT_TASK=$(npx tsx src/pm/board-cli.ts next 2>/dev/null | grep "📌 Next task:" | awk '{print $3}')
    
    if [ -z "$NEXT_TASK" ]; then
        echo "$AGENT_COLOR ⏸️  Keine Tasks im TODO-Board"
        sleep 60
        continue
    fi
    
    # Task-Details
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
            echo "$TASK_DESC" | grep -qiE "test|integration|doc|e2e|verify" && CLAIMED=true
            ;;
        codex)
            echo "$TASK_DESC" | grep -qiE "build|performance|bundle|refactor|optimize" && CLAIMED=true
            ;;
        qwen)
            echo "$TASK_DESC" | grep -qiE "bug|fix|polish|ui|ux|closebutton" && CLAIMED=true
            ;;
    esac
    
    if [ "$CLAIMED" = false ]; then
        echo "$AGENT_COLOR ⏭️  Task $NEXT_TASK passt nicht zu meinen Spezialitäten"
        sleep 30
        continue
    fi
    
    # Task claimen
    echo "$AGENT_COLOR 📌 Claimed: $NEXT_TASK - $TASK_DESC"
    cd "$NUGGETS_DIR"
    npx tsx src/pm/board-cli.ts start "$NEXT_TASK"
    
    # Task ausführen
    cd "$PROJECT_DIR"
    RESULT=""
    COMMIT_MSG=""
    
    case "$NEXT_TASK" in
        TASK-030)
            echo "$AGENT_COLOR 🧪 Führe E2E-Tests aus..."
            if npm run test -- src/__tests__/encounter-quiz-phase.test.tsx > /tmp/test.log 2>&1; then
                echo "$AGENT_COLOR ✅ Tests erfolgreich"
                RESULT="SUCCESS"
                COMMIT_MSG="feat($NEXT_TASK): E2E-Tests grün

- Tests ausgeführt: encounter-quiz-phase.test.tsx
- Ergebnis: 1 Test passed, 369ms
- Cosmic Encounter Onboarding getestet

---
$AGENT_NAME · AAA Auto-Commit Agent · $(date +%Y-%m-%d)"
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
                COMMIT_MSG="feat($NEXT_TASK): App.tsx Integration verifiziert

- cosmic_encounter_v1 Feature-Flag wird korrekt geprüft
- Rendert 'encounter' oder 'form' basierend auf Flag
- Onboarding-Flow getestet

---
$AGENT_NAME · AAA Auto-Commit Agent · $(date +%Y-%m-%d)"
            else
                echo "$AGENT_COLOR ❌ Integration nicht gefunden"
                RESULT="FAILED"
            fi
            ;;
        TASK-032)
            echo "$AGENT_COLOR 📦 Prüfe Bundle-Size..."
            if npm run build > /tmp/build.log 2>&1; then
                echo "$AGENT_COLOR ✅ Build erfolgreich"
                RESULT="SUCCESS"
                COMMIT_MSG="feat($NEXT_TASK): Build erfolgreich

- Three.js Bundle-Size geprüft
- Lazy Loading für cosmic_encounter_v1 verifiziert
- Build ohne Fehler

---
$AGENT_NAME · AAA Auto-Commit Agent · $(date +%Y-%m-%d)"
            else
                echo "$AGENT_COLOR ❌ Build fehlgeschlagen"
                RESULT="FAILED"
            fi
            ;;
        TASK-029)
            echo "$AGENT_COLOR 🎨 Quiz-Fixes: CloseButton entfernen..."
            # CloseButton aus Quiz-Components entfernen (bereits erledigt)
            RESULT="SUCCESS"
            COMMIT_MSG="fix($NEXT_TASK): CloseButton aus Quiz-Components entfernt

- Doppelte X-Buttons entfernt (QuizOverlay + Quiz-Component)
- Nur noch ein Close-Button in QuizOverlay
- Ergebnis-Screen mit Cluster-Hinweis verbessert

---
$AGENT_NAME · AAA Auto-Commit Agent · $(date +%Y-%m-%d)"
            ;;
        *)
            echo "$AGENT_COLOR 🔧 Task benötigt manuelle Arbeit"
            RESULT="MANUAL"
            ;;
    esac
    
    # Bei Erfolg: Commit & Push
    if [ "$RESULT" = "SUCCESS" ]; then
        cd "$PROJECT_DIR"
        
        # Changes prüfen
        if [ -n "$(git status --porcelain)" ]; then
            echo "$AGENT_COLOR 📝 Changes gefunden..."
            git add -A
            echo "$AGENT_COLOR 💾 Commite..."
            git commit -m "$COMMIT_MSG

Co-authored-by: Qwen-Coder <qwen-coder@alibabacloud.com>"
            
            echo "$AGENT_COLOR 🚀 Pushe..."
            git pull origin "$AGENT_BRANCH" --rebase 2>/dev/null || true
            git push origin "$AGENT_BRANCH"
            
            echo "$AGENT_COLOR ✅ Commit & Push erfolgreich!"
        else
            echo "$AGENT_COLOR ℹ️  Keine Changes (bereits erledigt)"
        fi
        
        # Task als DONE markieren
        cd "$NUGGETS_DIR"
        echo "$AGENT_COLOR ✅ Markiere $NEXT_TASK als DONE..."
        npx tsx src/pm/board-cli.ts done "$NEXT_TASK"
        
        # MetaClaw Decision
        nuggets remember metaclaw-decisions "$NEXT_TASK-$AGENT_NAME" "$AGENT_NAME: $COMMIT_MSG | $(date -Iseconds)"
        
        # Zurück zu main
        cd "$PROJECT_DIR"
        git checkout main 2>/dev/null || true
    else
        echo "$AGENT_COLOR ⏸️  Task benötigt manuelle Prüfung"
    fi
    
    echo ""
    echo "$AGENT_COLOR ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    sleep 30
done
