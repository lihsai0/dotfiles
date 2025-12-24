#!/usr/bin/env bash

# Proxy environment variable detection and display

# Proxy status bitmask constants
readonly STATE_ALL_PROXY=1      # bit 0: all_proxy is set
readonly STATE_HTTP_PROXY=2     # bit 1: http_proxy is set
readonly STATE_HTTPS_PROXY=4    # bit 2: https_proxy is set

# Check if a proxy environment variable is set (case-insensitive)
is_proxy_set() {
  local lower_var=$(echo $1 | tr '[:upper:]' '[:lower]')
  local upper_var=$(echo $1 | tr '[:lower:]' '[:upper:]')
  [[ -n "${!lower_var}" || -n "${!upper_var}" ]]
}

# Get proxy status as bitmask
get_state() {
  local state=0

  is_proxy_set "all_proxy" && state=$((state | STATE_ALL_PROXY))
  is_proxy_set "http_proxy" && state=$((state | STATE_HTTP_PROXY))
  is_proxy_set "https_proxy" && state=$((state | STATE_HTTPS_PROXY))

  echo "$state"
}

# Format proxy status for display
format_proxy_display() {
  local state="$1"
  local parts=()

  # No proxy configured
  if ((state == 0)); then
    return
  fi

  # Check for all_proxy
  if ((state & STATE_ALL_PROXY)); then
    parts+=("all")
  fi

  # Check for http/https proxies
  local has_http=$((state & STATE_HTTP_PROXY))
  local has_https=$((state & STATE_HTTPS_PROXY))

  if ((has_http && has_https)); then
    parts+=("http(s)")
  elif ((has_http)); then
    parts+=("http")
  elif ((has_https)); then
    parts+=("https")
  fi

  # Join parts with space
  local IFS=' '
  echo "${parts[*]}"
}

# Main entry point
get_result() {
  local state
  state=$(get_state)
  format_proxy_display "$state"
}

# Command dispatcher
main() {
  case "${1:-result}" in
    state)
      get_state
      ;;
    result)
      get_result
      ;;
    *)
      echo "Usage: $0 {state|result}" >&2
      echo "" >&2
      echo "Commands:" >&2
      echo "  state   - Output numeric bitmask of proxy status" >&2
      echo "  result  - Output human-readable proxy status (default)" >&2
      exit 1
      ;;
  esac
}

# Run main function
main "$@"
