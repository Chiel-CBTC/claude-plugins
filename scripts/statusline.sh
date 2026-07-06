#!/bin/bash
input=$(cat)

# Kleuren: groen voor labels, geel voor model, wit voor waarden, dim voor separators
GREEN='\033[32m'
YELLOW='\033[33m'
WHITE='\033[37m'
DIM='\033[2m'
RESET='\033[0m'

MODEL=$(echo "$input" | jq -r '.model.display_name')
CTX_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
USED_TOK=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0')
FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0')

EFFORT=$(echo "$input" | jq -r '.effort.level // "default"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
REPO=$(echo "$input" | jq -r '.workspace.repo.name // empty')

# Tokens formatteren naar k/M notatie
format_tokens() {
    local n=$1
    if [ "$n" -ge 1000000 ]; then
        awk -v n="$n" 'BEGIN { printf "%.1fM", n/1000000 }'
    elif [ "$n" -ge 1000 ]; then
        awk -v n="$n" 'BEGIN { printf "%dk", n/1000 }'
    else
        echo "$n"
    fi
}
USED_FMT=$(format_tokens "$USED_TOK")
SIZE_FMT=$(format_tokens "$CTX_SIZE")

CTX_LABEL=""
[ "$CTX_SIZE" -ge 1000000 ] && CTX_LABEL=" (1M context)"

# Progress bar, 28 tekens breed
BAR_WIDTH=28
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /█}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

# Git info
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
    [ -z "$BRANCH" ] && BRANCH="detached"
    GIT_STR="⎇ ${BRANCH}"
    [ -n "$REPO" ] && REPO_STR="(${REPO})" || REPO_STR="($(basename "$DIR"))"
else
    GIT_STR="no git"
    REPO_STR="(no git)"
fi

# Reset-tijd formatteren
if [ -n "$FIVE_H_RESET" ]; then
    DIFF=$(( FIVE_H_RESET - $(date +%s) ))
    if [ "$DIFF" -gt 0 ]; then
        RESET_STR="$((DIFF/3600))hr $(((DIFF%3600)/60))m"
    else
        RESET_STR="now"
    fi
else
    RESET_STR="n/a"
fi

LINE1=$(printf "${GREEN}Model:${RESET} ${YELLOW}%s%s${RESET} ${DIM}|${RESET} ${GREEN}Context:${RESET} ${WHITE}[%s]${RESET} ${WHITE}%s/%s (%s%%)${RESET} ${DIM}|${RESET} ${WHITE}%s${RESET} ${DIM}|${RESET} ${WHITE}%s${RESET}" \
  "$MODEL" "$CTX_LABEL" "$BAR" "$USED_FMT" "$SIZE_FMT" "$PCT" "$GIT_STR" "$REPO_STR")

LINE2=$(printf "${GREEN}Session:${RESET} ${WHITE}%.1f%%${RESET} ${DIM}|${RESET} ${GREEN}Reset:${RESET} ${WHITE}%s${RESET} ${DIM}|${RESET} ${GREEN}Weekly:${RESET} ${WHITE}%.1f%%${RESET}" \
  "$FIVE_H" "$RESET_STR" "$WEEK")

LINE3=$(printf "${GREEN}Thinking:${RESET} ${WHITE}%s${RESET} ${DIM}|${RESET} ${GREEN}cwd:${RESET} ${WHITE}%s${RESET}" \
  "$EFFORT" "$DIR")

echo -e "$LINE1"
echo -e "$LINE2"
echo -e "$LINE3"
