#!/usr/bin/env bash
# Simple macOS ping sweep: auto-detects local prefix, scans selected IP range
set -Eeuo pipefail

# --- Option flags ---
show_only_up=false
parallel_mode=false
compare_mode=false

# --- Parse CLI flags ---
for arg in "$@"; do
  case "$arg" in
    -u|--up-only)
      show_only_up=true
      ;;
    -p|--parallel)
      parallel_mode=true
      ;;
    -c|--compare)
      compare_mode=true
      ;;
    *)
      echo "❌ Unknown option: $arg"
      echo "Usage: $0 [-u|--up-only] [-p|--parallel] [-c|--compare]"
      exit 1
      ;;
  esac
done

# --- Detect IP ---
ip=$(ipconfig getifaddr en0 || echo "127.0.0.1")
echo "✅ Your IP address: $ip"

# --- Extract prefix ---
prefix=$(echo "$ip" | awk -F. '{print $1"."$2"."$3}')
echo "📡 Detected network prefix: $prefix"

# --- Ask for range ---
read -p "Start host (default: 120): " start
start=${start:-120}
read -p "End host   (default: 130): " end
end=${end:-130}

echo "🔍 Scanning $prefix.$start to $prefix.$end ..."

# --- Prepare output file ---
timestamp=$(date +%Y%m%d_%H%M%S)
outfile="$(dirname "$0")/tmp/scan_${prefix}_${start}-${end}.txt"
mkdir -p "$(dirname "$outfile")"
echo "📝 Results will be saved to: $outfile"
touch "$outfile"

# --- Optional compare setup ---
previous_file="$(dirname "$0")/tmp/last_scan_${prefix}_${start}-${end}.txt"
curr_up_list=$(mktemp)

# --- Ping logic ---
scan_host() {
  ip="$1"
  if ping -c 1 -W 1 "$ip" &>/dev/null; then
    ms=$(ping -c 1 -W 1 "$ip" | grep 'time=' | sed -n 's/.*time=\([0-9.]*\).*/\1/p')
    result="🟢 $ip is UP (${ms} ms)"
    echo "$result"
    echo "$result" >> "$outfile"
    echo "$ip" >> "$curr_up_list"
  else
    result="🔴 $ip is DOWN"
    if [[ "$show_only_up" == false ]]; then
      echo "$result"
      echo "$result" >> "$outfile"
    fi
  fi
}

# --- Main scanning loop ---
if [[ "$parallel_mode" == true ]]; then
  job_count=0
  max_jobs=20
  for i in $(seq "$start" "$end"); do
    ip="$prefix.$i"
    scan_host "$ip" &
    ((job_count++))
    if (( job_count % max_jobs == 0 )); then
      wait
    fi
  done
  wait
else
  for i in $(seq "$start" "$end"); do
    ip="$prefix.$i"
    scan_host "$ip"
  done
fi

# --- Optional comparison logic ---
if [[ "$compare_mode" == true ]]; then
  if [[ ! -f "$previous_file" ]]; then
    echo "🆕 No previous scan found. Saving current as baseline."
    cp "$curr_up_list" "$previous_file"
  else
    echo "📊 Comparing against: $previous_file"
    echo ""

    echo "🆕 New hosts (not in previous):"
    comm -13 <(sort "$previous_file") <(sort "$curr_up_list") || echo "None"

    echo ""
    echo "❌ Missing hosts (were UP last time):"
    comm -23 <(sort "$previous_file") <(sort "$curr_up_list") || echo "None"

    cp "$curr_up_list" "$previous_file"
  fi
fi

