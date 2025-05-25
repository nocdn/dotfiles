#!/bin/bash

if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is not installed. Please install it first."
    echo "e.g., sudo apt install fzf (Debian/Ubuntu) or brew install fzf (macOS)"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "Error: docker is not installed. Please install it first."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "Error: Docker daemon doesn't seem to be running."
    exit 1
fi

container_names=$(docker ps --format "{{.Names}}")
if [ -z "$container_names" ]; then
    echo "No running Docker containers found."
    exit 0
fi

FORMAT_STRING="{{.ID}}\n{{.Names}}\nCommand: {{.Command}}\nImage: {{.Image}}\nCreatedAt: {{.CreatedAt}}\nStatus: {{.Status}}\nPorts: {{.Ports}}"

selected_name=$(echo "$container_names" | \
    fzf --height 50% --layout=reverse --border \
        --prompt="Select Docker Container > " \
        --header="[Ctrl-C or Esc to quit]")

if [ -z "$selected_name" ]; then
    exit 1
fi

echo "--- Details for: $selected_name ---"
docker ps -a --filter "name=^${selected_name}$" --format "$FORMAT_STRING"

exit 0