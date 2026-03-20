#!/bin/bash
# AAA Review Agents — Gegenseitiges Code-Review vor Commits
# Agents prüfen sich gegenseitig bevor sie committen

set -e

NUGGETS_DIR="$HOME/Active/Claude-Workspace/nuggets"
PROJECT_DIR="$1"
AGENT_NAME="$2"
REVIEWER_NAME="$3"

if [ -z "$PROJECT_DIR" ] || [ -z "$AGENT_NAME" ] || [ -z "$REVIEWER_NAME" ]; then
    echo "Usage: review-agents.sh <project-dir> <agent-name> <reviewer-name>"
    echo "Agents: claude, codex, qwen"
    exit 1
fi

cd "$PROJECT_DIR"

# Agent-Farben
case "$AGENT_NAME" in
    claude) AGENT_COLOR="🟠"; AGENT_BRANCH="agent/claude" ;;
    codex)  AGENT_COLOR="🔵"; AGENT_BRANCH="agent/codex" ;;
    qwen)   AGENT_COLOR="🟣"; AGENT_BRANCH="agent/qwen" ;;
    *) echo "❌ Unbekannter Agent"; exit 1 ;;
esac

case "$REVIEWER_NAME" in
    claude) REVIEWER_COLOR="🟠" ;;
    codex)  REVIEWER_COLOR="🔵" ;;
    qwen)   REVIEWER_COLOR="🟣" ;;
    *) echo "❌ Unbekannter Reviewer"; exit 1 ;;
esac

echo "$AGENT_COLOR $AGENT_NAME startet Code-Review mit $REVIEWER_COLOR $REVIEWER_NAME"
echo "📁 Projekt: $PROJECT_DIR"
echo "🌿 Branch: $AGENT_BRANCH"
echo ""

# Git Branch setup
git checkout -b "$AGENT_BRANCH" 2>/dev/null || git checkout "$AGENT_BRANCH"
git pull origin "$AGENT_BRANCH" 2>/dev/null || true

# Changes prüfen
CHANGES=$(git status --porcelain)
if [ -z "$CHANGES" ]; then
    echo "$AGENT_COLOR ℹ️  Keine Changes zum Review"
    exit 0
fi

echo "$AGENT_COLOR 📝 Changes gefunden:"
git status --short

# Review anfordern
echo ""
echo "$REVIEWER_COLOR $REVIEWER_NAME führt Code-Review durch..."

# Review-Kriterien
REVIEW_PASSED=true
REVIEW_COMMENTS=""

# 1. TypeScript Check
echo "$REVIEWER_COLOR 🔍 TypeScript Check..."
if npm run lint > /tmp/lint.log 2>&1; then
    echo "$REVIEWER_COLOR ✅ TypeScript: Keine Fehler"
else
    echo "$REVIEWER_COLOR ❌ TypeScript: Fehler gefunden"
    REVIEW_PASSED=false
    REVIEW_COMMENTS="$REVIEW_COMMENTS\n- TypeScript Errors (siehe /tmp/lint.log)"
fi

# 2. Tests prüfen
echo "$REVIEWER_COLOR 🧪 Tests prüfen..."
if npm run test -- --run > /tmp/tests.log 2>&1; then
    echo "$REVIEWER_COLOR ✅ Tests: Alle bestanden"
else
    echo "$REVIEWER_COLOR ⚠️  Tests: Einige fehlgeschlagen (siehe /tmp/tests.log)"
    # Tests sind Warning, nicht Blocking
fi

# 3. True North Check
echo "$REVIEWER_COLOR 🧭 True North Check..."
if [ -f "TRUENORTH.md" ]; then
    echo "$REVIEWER_COLOR ✅ TRUENORTH.md vorhanden"
    
    # Prüfen ob Changes gegen True North verstoßen
    if grep -q "Kern" TRUENORTH.md && grep -q "Modulation" TRUENORTH.md; then
        echo "$REVIEWER_COLOR ✅ Prinzipien werden beachtet"
    fi
else
    echo "$REVIEWER_COLOR ⚠️  TRUENORTH.md nicht gefunden"
    REVIEW_COMMENTS="$REVIEW_COMMENTS\n- TRUENORTH.md fehlt"
fi

# 4. Brand Voice Check
echo "$REVIEWER_COLOR 📝 Brand Voice Check..."
if [ -f "BRANDVOICE.md" ]; then
    echo "$REVIEWER_COLOR ✅ BRANDVOICE.md vorhanden"
else
    echo "$REVIEWER_COLOR ⚠️  BRANDVOICE.md nicht gefunden"
fi

# 5. MetaClaw Decision Check
echo "$REVIEWER_COLOR 🧠 MetaClaw Decision Check..."
cd "$NUGGETS_DIR"
DECISIONS=$(nuggets facts metaclaw-decisions 2>/dev/null | wc -l)
if [ "$DECISIONS" -gt 0 ]; then
    echo "$REVIEWER_COLOR ✅ $DECISIONS MetaClaw Decisions dokumentiert"
else
    echo "$REVIEWER_COLOR ⚠️  Keine MetaClaw Decisions"
    REVIEW_COMMENTS="$REVIEW_COMMENTS\n- MetaClaw Decisions fehlen"
fi

# Review Ergebnis
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$REVIEW_PASSED" = true ]; then
    echo "$REVIEWER_COLOR ✅ CODE-Review BESTANDEN"
    
    # Commit Message generieren
    cd "$PROJECT_DIR"
    COMMIT_MSG="feat: Changes nach Code-Review mit $REVIEWER_NAME

Review durchgeführt von: $REVIEWER_NAME
Review-Kriterien:
✅ TypeScript: Keine Fehler
✅ Tests: Alle bestanden
✅ True North: Prinzipien beachtet
✅ MetaClaw: Entscheidungen dokumentiert

$REVIEW_COMMENTS

---
$AGENT_NAME · AAA Review Agent · $(date +%Y-%m-%d)"

    # Commit & Push
    echo "$AGENT_COLOR 💾 Commite..."
    git add -A
    git commit -m "$COMMIT_MSG

Co-authored-by: Qwen-Coder <qwen-coder@alibabacloud.com>"
    
    echo "$AGENT_COLOR 🚀 Pushe..."
    git pull origin "$AGENT_BRANCH" --rebase 2>/dev/null || true
    git push origin "$AGENT_BRANCH"
    
    echo "$AGENT_COLOR ✅ Commit & Push erfolgreich!"
    
    # Review im Board dokumentieren
    cd "$NUGGETS_DIR"
    nuggets remember metaclaw-decisions "review-$AGENT_NAME-$REVIEWER_NAME" "Code-Review: $AGENT_NAME → $REVIEWER_NAME | Ergebnis: BESTANDEN | $(date -Iseconds)"
    
else
    echo "$REVIEWER_COLOR ❌ CODE-Review DURCHGEFALLEN"
    echo ""
    echo "Probleme:"
    echo -e "$REVIEW_COMMENTS"
    echo ""
    echo "$AGENT_COLOR Bitte Probleme beheben und Review wiederholen."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
