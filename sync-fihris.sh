#!/bin/bash
# ═══════════════════════════════════════════════════════
# sync-fihris.sh — Scan repos dir and regenerate APPS array in index.html
# Usage: cd ~/Desktop/00_work/apps/repos/fihris && bash sync-fihris.sh
# ═══════════════════════════════════════════════════════

REPOS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIHRIS_DIR="$(cd "$(dirname "$0")" && pwd)"
INDEX="$FIHRIS_DIR/index.html"
TMPFILE="$FIHRIS_DIR/.apps_generated.tmp"

echo "=== Fihris Sync ==="
echo "Repos dir: $REPOS_DIR"
echo ""

# ─── Category detection ───
detect_category() {
  local name="$1"
  local readme_text="$2"

  # Islamic books — name patterns
  case "$name" in
    al-*|aqidat-*|fiqh-*|dustur-*|haqiqat-*|hasad-*|humum-*|huquq-*|iyadat-*|jaddid-*|jihad-*|kayfa-*|khuluq-*|khutab-*|kunuz-*|maa-*|marakah-*|miat-*|min-huna-*|mushkilat-*|nahwa-*|nazarat-*|qadhaaif-*|rakaiz-*|rihlati-*|sayhah-*|shahid-*|taamulat-*|tarbiyat-*|zalam-*|fan-al-*|fi-mawkib-*|difaa-*|qadaya-*|ayqidh-*|ramadan-wal-*)
      echo "books"; return ;;
  esac

  # micro:bit
  case "$name" in
    bit-bot|talking-robot|teachable-machine|face-tracking|bitmoji-lab|bit-playground|rxy|usb-logger|ble-logger|ble-dashboard)
      echo "microbit"; return ;;
  esac

  # Arabic & Islamic
  case "$name" in
    arabic-*|piper-arabic-tts|arabic-tts|ierab|elarabya|amthal|tethkir|kalami|jisr|al-maqlub|salat-times|tesbih|adhkari|islamic-*|luminaries-*|golden-age|builders-of-light|hajj-guide|eid|nusuk|halqa|sada|cowsay)
      echo "arabic"; return ;;
  esac

  # Camera
  case "$name" in
    magic-hands|face-quest) echo "camera"; return ;;
  esac

  # Classroom
  case "$name" in
    classroom|mission-control) echo "classroom"; return ;;
  esac

  # Network
  case "$name" in
    mqtt-lab|dhcp-lab|docker-lab|nodered-lab|avahi|tshark|pyshark|mdns|scapy|bonjour|wifi-dashboard|sniffers-sallae|hackrf-one)
      echo "network"; return ;;
  esac

  # Education
  case "$name" in
    wled-kids-lab|esp32-c3-kids-lab|crypto-academy|pentest-lab|linux-kids-lab|production-chain|circuit-lab|3d-lab|git-lab|code-kids|save-our-planet|makecode-adventures|bit-54-activities|crypto-vault|web-kids|AI-hacker-lab)
      echo "education"; return ;;
  esac

  # AI
  case "$name" in
    ollama-bot|prompt-hero|claude-toolkit|msa-arabic-tts|teachable-machine)
      echo "ai"; return ;;
  esac

  # Infra
  case "$name" in
    ocpp|sdr-lab|reddis|firebase|ota|firmware-update|evic-toolkit|nearpay)
      echo "infra"; return ;;
  esac

  # Fun
  case "$name" in
    time-machine|morse-code|satellites|flight-tracker)
      echo "fun"; return ;;
  esac

  # Meta
  case "$name" in
    workshop-diy|apps|fihris|hacktivist-kids|flyers|posts|presentation|warsha|sada)
      echo "meta"; return ;;
  esac
  case "$name" in
    ops-catalog*) echo "meta"; return ;;
  esac

  # Standalone / tools fallback
  case "$name" in
    callgraph|passassion-report|linkedin|PlanPilot|gmail-lab)
      echo "standalone"; return ;;
  esac

  # Default
  echo "tools"
}

# ─── Emoji extraction from README title ───
extract_emoji() {
  local line="$1"
  # Match first emoji (unicode ranges for common emoji)
  local emoji
  emoji=$(echo "$line" | perl -CS -ne 'print $1 if /^[#>\s*]*(\p{So}|\p{Emoji_Presentation})/' 2>/dev/null)
  echo "$emoji"
}

# ─── Default emoji per category ───
default_emoji() {
  case "$1" in
    books) echo "📚" ;;
    microbit) echo "🤖" ;;
    arabic) echo "🕌" ;;
    camera) echo "📸" ;;
    classroom) echo "🏫" ;;
    education) echo "📚" ;;
    network) echo "🌐" ;;
    ai) echo "🤖" ;;
    tools) echo "🛠️" ;;
    fun) echo "🎮" ;;
    infra) echo "🔧" ;;
    meta) echo "📦" ;;
    standalone) echo "💼" ;;
    planned) echo "📋" ;;
    *) echo "📁" ;;
  esac
}

# ─── Description extraction ───
extract_description() {
  local dir="$1"
  local desc=""

  # Try README.md
  if [[ -f "$dir/README.md" ]]; then
    # Read first 15 lines, skip empty/badge/bismillah lines, find first description-like line
    while IFS= read -r line; do
      # Skip empty, heading-only, badge, bismillah lines
      local stripped
      stripped=$(echo "$line" | sed 's/^[#>* ]*//' | sed 's/\*\*//g' | sed 's/^\s*//')
      [[ -z "$stripped" ]] && continue
      [[ "$stripped" =~ ^بِسْمِ ]] && continue
      [[ "$stripped" =~ ^!\[ ]] && continue
      [[ "$stripped" =~ ^\<img ]] && continue
      [[ "$stripped" =~ ^--- ]] && continue
      [[ "$stripped" =~ ^Live\ site ]] && continue
      # Skip if it's just the repo name as a title
      local name_only
      name_only=$(basename "$dir")
      [[ "$(echo "$stripped" | tr '[:upper:]' '[:lower:]')" == "$(echo "$name_only" | tr '[:upper:]' '[:lower:]')" ]] && continue
      # Skip very short lines (just emoji or one word)
      [[ ${#stripped} -lt 8 ]] && continue
      desc="$stripped"
      break
    done < <(head -15 "$dir/README.md")
  fi

  # Fallback: try <title> from index.html
  if [[ -z "$desc" && -f "$dir/index.html" ]]; then
    desc=$(grep -o '<title>[^<]*</title>' "$dir/index.html" | head -1 | sed 's/<[^>]*>//g' | sed 's/^\s*//')
  fi

  # Fallback
  [[ -z "$desc" ]] && desc="No description"

  # Truncate safely using Python (handles multi-byte UTF-8)
  desc=$(python3 -c "
import sys
s = sys.stdin.read().strip()
if len(s) > 80: s = s[:77] + '...'
print(s)
" <<< "$desc")

  # Escape double quotes for JS
  desc="${desc//\"/\\\"}"

  echo "$desc"
}

# ─── Status detection ───
detect_status() {
  local dir="$1"
  if [[ -f "$dir/README.md" ]]; then
    local content
    content=$(head -30 "$dir/README.md")
    if echo "$content" | grep -qi "planned\|roadmap\|coming soon"; then
      echo "planned"; return
    fi
    if echo "$content" | grep -qi "v[0-9]\|stable\|release\|production"; then
      echo "stable"; return
    fi
    if echo "$content" | grep -qi "dev\|wip\|work in progress\|alpha\|beta"; then
      echo "dev"; return
    fi
  fi
  # Check if there's meaningful content (index.html or multiple files)
  local file_count
  file_count=$(find "$dir" -maxdepth 1 -not -name '.git' -not -name '.' | wc -l)
  if [[ $file_count -gt 3 ]]; then
    echo "stable"
  else
    echo "new"
  fi
}

# ─── GitHub detection ───
has_github() {
  if [[ -f "$1/.git/config" ]] && grep -q "github.com" "$1/.git/config" 2>/dev/null; then
    echo "1"
  else
    echo "0"
  fi
}

# ═══ MAIN: Scan all repos ═══
echo "Scanning repos..."
> "$TMPFILE"

count=0
for dir in "$REPOS_DIR"/*/; do
  name=$(basename "$dir")

  # Skip fihris itself
  [[ "$name" == "fihris" ]] && continue
  # Skip hidden dirs
  [[ "$name" == .* ]] && continue

  readme_text=""
  [[ -f "$dir/README.md" ]] && readme_text=$(head -20 "$dir/README.md")

  cat=$(detect_category "$name" "$readme_text")
  desc=$(extract_description "$dir")
  status=$(detect_status "$dir")
  github=$(has_github "$dir")

  # Extract emoji from README title, or use default
  emoji=""
  if [[ -f "$dir/README.md" ]]; then
    title_line=$(head -3 "$dir/README.md" | grep "^#" | head -1)
    emoji=$(extract_emoji "$title_line")
  fi
  [[ -z "$emoji" ]] && emoji=$(default_emoji "$cat")

  # Write entry
  echo "${cat}|${name}|{e:\"${emoji}\",n:\"${name}\",c:\"${cat}\",d:\"${desc}\",s:\"${status}\",g:${github}}" >> "$TMPFILE"

  count=$((count + 1))
done

echo "Found $count repos"
echo ""

# ═══ Sort by category, then name ═══
sorted=$(sort -t'|' -k1,1 -k2,2 "$TMPFILE")

# ═══ Build JS APPS array → write directly to temp file ═══
JSFILE="$FIHRIS_DIR/.apps_generated.js"
{
  echo "const APPS=["
  current_cat=""
  while IFS='|' read -r cat name entry; do
    if [[ "$cat" != "$current_cat" ]]; then
      [[ -n "$current_cat" ]] && echo ""
      cat_info=""
      case "$cat" in
        ai) cat_info="ai" ;; arabic) cat_info="arabic & islamic" ;; books) cat_info="islamic books" ;;
        camera) cat_info="camera" ;; classroom) cat_info="classroom" ;; education) cat_info="education" ;;
        fun) cat_info="fun" ;; infra) cat_info="infra" ;; meta) cat_info="meta" ;;
        microbit) cat_info="micro:bit" ;; network) cat_info="network" ;; standalone) cat_info="standalone" ;;
        tools) cat_info="tools" ;; *) cat_info="$cat" ;;
      esac
      cat_count=$(echo "$sorted" | grep "^${cat}|" | wc -l | tr -d ' ')
      echo "// ${cat_info} (${cat_count})"
      current_cat="$cat"
    fi
    echo "${entry},"
  done <<< "$sorted"
  echo "];"
} > "$JSFILE"

# ═══ Patch index.html ═══
echo "Patching index.html..."

python3 -c "
import re
with open('$INDEX', 'r', encoding='utf-8') as f: content = f.read()
with open('$JSFILE', 'r', encoding='utf-8') as f: new_apps = f.read()
content = re.sub(r'const APPS=\[.*?\];', new_apps, content, flags=re.DOTALL)
with open('$INDEX', 'w', encoding='utf-8') as f: f.write(content)
print('APPS array replaced')
"

# ═══ Summary ═══
echo ""
echo "=== Sync Complete ==="
echo "Total repos: $count"

# Count per category
echo ""
echo "Categories:"
echo "$sorted" | cut -d'|' -f1 | sort | uniq -c | sort -rn | while read cnt cat; do
  echo "  $cat: $cnt"
done

# Cleanup
rm -f "$TMPFILE" "$JSFILE"

echo ""
echo "Done! Open index.html to verify."
