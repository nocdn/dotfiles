dps() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker is not installed. Please install it first." >&2
    return 1
  fi

  if ! command docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not running." >&2
    return 1
  fi

  command docker ps --size --format '{{.ID}}\n{{.Names}}\nCommand: {{.Command}}\nImage: {{.Image}}\nCreatedAt: {{.CreatedAt}}\nStatus: {{.Status}}\nPorts: {{.Ports}}\nSize: {{.Size}}\n'
}

dpsf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed. Please install it first." >&2
    return 1
  fi

  if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker is not installed. Please install it first." >&2
    return 1
  fi

  if ! command docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not running." >&2
    return 1
  fi

  local entries fmt sel container_id container_name

  entries=$(command docker ps --format "{{.ID}}\t{{.Names}}")
  if [[ -z "$entries" ]]; then
    echo "No running Docker containers found."
    return 0
  fi

  fmt="{{.ID}}\n{{.Names}}\nCommand: {{.Command}}\nImage: {{.Image}}\nCreatedAt: {{.CreatedAt}}\nStatus: {{.Status}}\nPorts: {{.Ports}}\nSize: {{.Size}}"

  sel=$(printf "%s\n" "$entries" | fzf --height 40% --layout=reverse --border \
    --prompt="Select Docker Container > " \
    --header="[Ctrl-C or Esc to quit]" \
    --delimiter=$'\t' \
    --with-nth=2) || return 1

  [[ -n "$sel" ]] || return 1

  container_id="${sel%%$'\t'*}"
  container_name="${sel#*$'\t'}"
  if [[ -z "$container_id" || -z "$container_name" || "$container_id" == "$sel" ]]; then
    echo "Error: could not resolve the selected container." >&2
    return 1
  fi

  echo ""
  echo "--- Details for: $container_name ---"
  command docker ps -a --size --filter "id=$container_id" --format "$fmt"
  echo ""
}
