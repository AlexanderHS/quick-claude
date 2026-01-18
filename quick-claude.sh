#!/bin/bash
# quick-claude - Quick launcher to get coding in your repos
# Usage: source quick-claude.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load .env if it exists
if [[ -f "$SCRIPT_DIR/.env" ]]; then
    source "$SCRIPT_DIR/.env"
fi

# Default repos directory
REPOS_DIR="${REPOS_DIR:-$HOME/repos}"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Check if repos directory exists
if [[ ! -d "$REPOS_DIR" ]]; then
    echo -e "${YELLOW}Directory not found: $REPOS_DIR${NC}"
    echo -e "${DIM}Set REPOS_DIR in $SCRIPT_DIR/.env${NC}"
    return 1 2>/dev/null || exit 1
fi

# Gather repos with their last activity date
declare -a repos=()
declare -a dates=()
declare -a display_dates=()

for dir in "$REPOS_DIR"/*/; do
    [[ -d "$dir" ]] || continue
    repo_name=$(basename "$dir")

    # Try to get last commit date if it's a git repo
    if [[ -d "$dir/.git" ]]; then
        timestamp=$(git -C "$dir" log -1 --format=%ct 2>/dev/null)
        if [[ -n "$timestamp" ]]; then
            display_date=$(date -d "@$timestamp" "+%Y-%m-%d" 2>/dev/null || date -r "$timestamp" "+%Y-%m-%d" 2>/dev/null)
        else
            timestamp=$(stat -c %Y "$dir" 2>/dev/null || stat -f %m "$dir" 2>/dev/null)
            display_date="no commits"
        fi
    else
        timestamp=$(stat -c %Y "$dir" 2>/dev/null || stat -f %m "$dir" 2>/dev/null)
        display_date="not git"
    fi

    repos+=("$repo_name")
    dates+=("$timestamp")
    display_dates+=("$display_date")
done

# Check if we found any repos
if [[ ${#repos[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No repos found in $REPOS_DIR${NC}"
    return 1 2>/dev/null || exit 1
fi

# Sort by date (oldest first, so newest appears at bottom of screen)
indices=($(for i in "${!dates[@]}"; do echo "$i ${dates[$i]}"; done | sort -k2 -n | cut -d' ' -f1))

# Find max repo name length for alignment
max_name_len=0
for name in "${repos[@]}"; do
    [[ ${#name} -gt $max_name_len ]] && max_name_len=${#name}
done

# Build sorted list (most recent first for display)
total=${#indices[@]}
declare -a sorted_repos=()
declare -a sorted_dates=()
for ((j=total-1; j>=0; j--)); do
    i="${indices[$j]}"
    sorted_repos+=("${repos[$i]}")
    sorted_dates+=("${display_dates[$i]}")
done

# Two-digit mode for selecting items 10+
two_digit_mode=0

# Function to draw menu
draw_menu() {
    local selected=$1
    local start_line=$2

    if [[ $start_line -gt 0 ]]; then
        printf "\033[%dA" "$total"
    fi

    for ((i=0; i<total; i++)); do
        local padded_name=$(printf "%-${max_name_len}s" "${sorted_repos[$i]}")
        local num_label
        local num=$((i+1))
        if [[ $two_digit_mode -eq 1 ]]; then
            if [[ $num -lt 100 ]]; then
                num_label="${DIM}$(printf "%2d" $num)${NC} "
            else
                num_label="   "
            fi
        else
            if [[ $num -le 9 ]]; then
                num_label="${DIM}${num}${NC} "
            else
                num_label="  "
            fi
        fi
        printf "\r\033[K"
        if [[ $i -eq $selected ]]; then
            echo -e "${num_label}${GREEN}${BOLD}>${NC} ${BOLD}${padded_name}${NC}  ${DIM}(${sorted_dates[$i]})${NC}"
        else
            echo -e "${num_label}  ${padded_name}  ${DIM}(${sorted_dates[$i]})${NC}"
        fi
    done
}

echo ""
echo -e "${CYAN}${BOLD}Ready to code?${NC}"
echo -e "${DIM}Use ↑/↓ or 1-9 to select, n for two-digit mode:${NC}"
echo ""

current=0
draw_menu $current 0

printf "\033[?25l"

cleanup() {
    printf "\033[?25h"
}
trap cleanup EXIT

while true; do
    read -rsn1 key

    if [[ $key == $'\033' ]]; then
        read -rsn2 -t 0.1 key
        if [[ -z $key ]]; then
            # Bare escape pressed - exit
            printf "\033[?25h"
            trap - EXIT
            echo ""
            return 0 2>/dev/null || exit 0
        fi
        case "$key" in
            '[A') ((current > 0)) && ((current--)) ;;
            '[B') ((current < total - 1)) && ((current++)) ;;
        esac
        draw_menu $current 1
    elif [[ $key == '' ]]; then
        break
    elif [[ $key == 'n' ]]; then
        two_digit_mode=$((1 - two_digit_mode))
        draw_menu $current 1
    elif [[ $two_digit_mode -eq 1 && $key =~ ^[0-9]$ ]]; then
        printf "\r\033[K${DIM}> ${key}_${NC}"
        read -rsn1 -t 2 key2
        printf "\r\033[K"
        if [[ $key2 =~ ^[0-9]$ ]]; then
            target=$((key * 10 + key2 - 1))
            if [[ $target -ge 0 && $target -lt $total ]]; then
                current=$target
                break
            fi
        fi
    elif [[ $two_digit_mode -eq 0 && $key =~ ^[1-9]$ ]]; then
        target=$((key - 1))
        if [[ $target -lt $total ]]; then
            current=$target
            break
        fi
    fi
done

printf "\033[?25h"
trap - EXIT

selected="${sorted_repos[$current]}"
target_dir="$REPOS_DIR/$selected"

echo ""
echo -e "${DIM}Jumping into ${selected}...${NC}"
echo ""

cd "$target_dir" || { echo "Failed to cd"; return 1 2>/dev/null || exit 1; }
claude
