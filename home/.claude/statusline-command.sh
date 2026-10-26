#!/bin/sh
# Claude Code status line — minimalist
# Segments (only shown when data is available): model, subscription usage
# (5h/7d), session duration, context window used, next limit reset, session cost.

input=$(cat)

reset='\033[0m'

# Muted 256-color palette — reads well once Claude Code dims the status line.
c_project='\033[38;5;67m'    # muted blue
c_model='\033[38;5;140m'     # muted purple
c_usage='\033[38;5;108m'     # muted sage green
c_session='\033[38;5;109m'   # muted cyan
c_ctx='\033[38;5;73m'        # muted teal
c_resettime='\033[38;5;180m' # muted tan
c_cost='\033[38;5;173m'      # muted rust

get() { echo "$input" | jq -r "$1 // empty"; }

# --- Project (current project directory name) ------------------------------
project_dir=$(get '.workspace.project_dir')
project=""
[ -n "$project_dir" ] && project=$(basename "$project_dir")

# --- Model ---------------------------------------------------------------
model=$(get '.model.display_name')

# --- Subscription usage (5h / 7d rate limits) -----------------------------
five_pct=$(get '.rate_limits.five_hour.used_percentage')
week_pct=$(get '.rate_limits.seven_day.used_percentage')
usage=""
if [ -n "$five_pct" ]; then
  usage="5h $(printf '%.0f' "$five_pct")%"
fi
if [ -n "$week_pct" ]; then
  week_r=$(printf '%.0f' "$week_pct")
  if [ -n "$usage" ]; then usage="${usage} / 7d ${week_r}%"; else usage="7d ${week_r}%"; fi
fi

# --- Session duration (wall-clock time this session has been running) ----
dur_ms=$(get '.cost.total_duration_ms')
session=""
if [ -n "$dur_ms" ]; then
  session=$(echo "$dur_ms" | awk '{
    s=int($1/1000); h=int(s/3600); m=int((s%3600)/60)
    if (h > 0) printf "%dh%dm", h, m; else printf "%dm", m
  }')
fi

# --- Context window usage --------------------------------------------------
ctx_pct=$(get '.context_window.used_percentage')
ctx=""
[ -n "$ctx_pct" ] && ctx="ctx $(printf '%.0f' "$ctx_pct")%"

# --- Next rate-limit reset (soonest of the 5h / 7d windows) ---------------
five_reset=$(get '.rate_limits.five_hour.resets_at')
week_reset=$(get '.rate_limits.seven_day.resets_at')
five_reset_i=${five_reset%.*}
week_reset_i=${week_reset%.*}
reset_epoch=""
if [ -n "$five_reset_i" ] && [ -n "$week_reset_i" ]; then
  if [ "$five_reset_i" -le "$week_reset_i" ]; then reset_epoch="$five_reset_i"; else reset_epoch="$week_reset_i"; fi
elif [ -n "$five_reset_i" ]; then
  reset_epoch="$five_reset_i"
elif [ -n "$week_reset_i" ]; then
  reset_epoch="$week_reset_i"
fi
reset_str=""
if [ -n "$reset_epoch" ]; then
  reset_str="resets $(date -r "$reset_epoch" '+%H:%M' 2>/dev/null)"
fi

# --- Session cost ------------------------------------------------------------
cost_usd=$(get '.cost.total_cost_usd')
cost_str=""
[ -n "$cost_usd" ] && cost_str=$(printf '$%.2f' "$cost_usd")

# --- Assemble line, skipping empty segments, joined by a dim middle dot -----
line=""
started=0
add() {
  val="$1"; color="$2"
  [ -z "$val" ] && return
  if [ "$started" -eq 1 ]; then
    line="${line} \033[2m·\033[0m "
  fi
  line="${line}${color}${val}${reset}"
  started=1
}

add "$project"  "$c_project"
add "$model"    "$c_model"
add "$usage"    "$c_usage"
add "$session"  "$c_session"
add "$ctx"      "$c_ctx"
add "$reset_str" "$c_resettime"
add "$cost_str" "$c_cost"

printf "%b\n" "$line"
