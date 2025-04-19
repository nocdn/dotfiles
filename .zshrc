# ~/.zshrc

# -- History Settings --
# Keep plenty of history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# Remove duplicates
HISTDUP=erase
# Standard history options
setopt appendhistory sharehistory hist_ignore_all_dups hist_ignore_dups hist_find_no_dups

# -- Environment Variables & Path --
# Homebrew (Apple Silicon path) - This eval can take time, but often necessary
# Ensure it runs only once if possible
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add other paths (consolidated)
# No need to add /opt/homebrew/bin again, brew shellenv does it
export PATH="/usr/local/bin:$PATH" # Standard macOS path
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH" # Cargo path
export PATH="$HOME/.bun/bin:$PATH" # Bun path
export PATH="$HOME/.deno/bin:$PATH" # Deno path
export PATH="$HOME/Library/pnpm:$PATH" # PNPM path

# Environment variables
export NVM_DIR="$HOME/.nvm" # Set NVM_DIR path for lazy loading function
export EDITOR=/opt/homebrew/bin/nvim
export MINIO_CONFIG_ENV_FILE=/etc/default/minio
export EXA_COLORS="di=38;5;117:ex=38;5;177:no=00:da=0;0:sn=0;0" # eza colors

# -- Aliases --
# General
alias ls="eza"
alias la="eza -l --no-permissions --no-user --no-filesize --sort=date"
alias laa="eza -la --no-permissions --no-user --sort=date"
alias zshconfig="code ~/.zshrc"
alias reload="source ~/.zshrc"
alias cl='clear'
alias cp='cp -iv'
alias mv='mv -iv'
alias hist="cat ~/.zsh_history | fzf | pbcopy" # Use correct histfile path
alias fcat="fzf | xargs cat"
alias nq='networkQuality'
alias ipinfo='curl -s http://ip-api.com/json/ | jq "."'
alias py='python3'
alias docker="/Applications/Docker.app/Contents/Resources/bin/docker" # Specific Docker path

# Git
alias gs='git status'
alias ga='git add .' # Common usage: add all changes in pwd
alias gp='git push'
alias gc='git commit'

# Development
alias brd='bun run dev'
alias brb='bun run build'

# -- Functions --
# (Your existing functions go here - function definitions are cheap at startup)
# nvm lazy loader (corrected path check for Apple Silicon Homebrew)
nvm() {
  # check if nvm installed via homebrew on apple silicon
  if [[ -d '/opt/homebrew/opt/nvm' ]]; then
    export NVM_DIR="/opt/homebrew/opt/nvm" # set correct NVM_DIR
    # shellcheck disable=SC1091 # source nvm script
    \. "${NVM_DIR}/nvm.sh"
    # add node path if default exists
    if [[ -e "$HOME/.nvm/alias/default" ]]; then
      export PATH="$PATH:$HOME/.nvm/versions/node/$(cat "$HOME/.nvm/alias/default")/bin"
    fi
    # invoke the real nvm function now
    nvm "$@"
  # check if nvm installed manually or via installer
  elif [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091 # source nvm script
    \. "$NVM_DIR/nvm.sh"
    # invoke the real nvm function now
    nvm "$@"
  else
    echo "nvm is not installed or NVM_DIR is not set correctly" >&2
    return 1
  fi
}

# listinstances
function listinstances() {
    gcloud compute instances list --format="table[no-heading](name, networkInterfaces[0].accessConfigs[0].natIP:label=EXTERNAL_IP)"
}

# sshinstance
function sshinstance() {
    local external_ip
    if [ -z "$1" ]; then
        read -r "external_ip?Enter the external IP of the instance: "
    else
        external_ip="$1"
    fi
    local ssh_key="$HOME/latest-server-ssh-key" # Use $HOME instead of ~
    ssh -i "$ssh_key" nk3h8wbq@"$external_ip" -o StrictHostKeyChecking=no
}

# tempinstance
function tempinstance() {
    local instance_types=("t2d-standard-1" "t2d-standard-2" "t2d-standard-4" "t2d-standard-8")
    local selected_type=$(printf "%s\n" "${instance_types[@]}" | fzf --height=6 --prompt="Select instance type: ")
    [[ -z "$selected_type" ]] && echo "No type selected." && return 1
    echo "Selected type: $selected_type"

    local disk_type=$(echo -e "pd-balanced\npd-standard\npd-ssd" | fzf --height=5 --prompt="Select disk type: ")
    [[ -z "$disk_type" ]] && echo "No disk type selected." && return 1
    echo "Selected disk type: $disk_type"

    local disk_size
    read -r "disk_size?Enter disk size in GB (default 10): "
    disk_size=${disk_size:-10}
    echo "Disk size: ${disk_size}GB"

    local instance_name
    read -r "instance_name?Enter instance name (default testing-instance): "
    instance_name=${instance_name:-testing-instance}

    local ssh_key_file="$HOME/latest-server-ssh-key.pub" # Use $HOME
    if [[ ! -f "$ssh_key_file" ]]; then
        echo "SSH key file $ssh_key_file not found." && return 1
    fi
    local ssh_key=$(<"$ssh_key_file")

    gcloud compute instances create "$instance_name" \
        --zone=europe-west2-a \
        --machine-type="$selected_type" \
        --boot-disk-type="$disk_type" \
        --boot-disk-size="${disk_size}GB" \
        --preemptible \
        --tags=testing,minecraft,http-server,https-server \
        --scopes=https://www.googleapis.com/auth/cloud-platform \
        --metadata ssh-keys="nk3h8wbq:$ssh_key" || return 1 # Exit if create fails

    echo "Attempting to SSH into $instance_name..."
    gcloud compute ssh "$instance_name" --zone=europe-west2-a
    # Copy SSH command to clipboard after successful creation/connection attempt
    echo "gcloud compute ssh $instance_name --zone=europe-west2-a" | pbcopy
}

# stopinstances
function stopinstances {
    local instance_name="$1"
    local instances=$(gcloud compute instances list --filter="status=RUNNING" --format="table[no-heading](name, zone)")
    [[ -z "$instances" ]] && echo "No running instances found." && return 0
    local instance_array=("${(@f)instances}")
    local selected_instance_name selected_instance_zone

    if [[ -n "$instance_name" ]]; then
        local found=false
        for instance in "${instance_array[@]}"; do
            if [[ "${instance%% *}" == "$instance_name" ]]; then
                selected_instance_name="$instance_name"
                selected_instance_zone="${instance##* }"
                found=true
                break
            fi
        done
        if ! $found; then echo "Instance '$instance_name' not found or not running." && return 1; fi
    else
        echo "Select an instance to stop:"
        select instance_choice in "${instance_array[@]}" "Cancel"; do
            if [[ "$instance_choice" == "Cancel" || -z "$instance_choice" ]]; then
                 echo "Operation cancelled." && return 0
            fi
            selected_instance_name="${instance_choice%% *}"
            selected_instance_zone="${instance_choice##* }"
            break
        done
    fi

    echo "Stopping instance: $selected_instance_name in zone: $selected_instance_zone"
    gcloud compute instances stop "$selected_instance_name" --zone="$selected_instance_zone"
}

# startinstances
function startinstances {
    local instance_name="$1"
    local instances=$(gcloud compute instances list --filter="status=TERMINATED" --format="table[no-heading](name, zone)")
    [[ -z "$instances" ]] && echo "No terminated instances found." && return 0
    local instance_array=("${(@f)instances}")
    local selected_instance_name selected_instance_zone

    if [[ -n "$instance_name" ]]; then
        local found=false
        for instance in "${instance_array[@]}"; do
            if [[ "${instance%% *}" == "$instance_name" ]]; then
                selected_instance_name="$instance_name"
                selected_instance_zone="${instance##* }"
                found=true
                break
            fi
        done
        if ! $found; then echo "Instance '$instance_name' not found or not terminated." && return 1; fi
    else
        echo "Select an instance to start:"
         select instance_choice in "${instance_array[@]}" "Cancel"; do
            if [[ "$instance_choice" == "Cancel" || -z "$instance_choice" ]]; then
                 echo "Operation cancelled." && return 0
            fi
            selected_instance_name="${instance_choice%% *}"
            selected_instance_zone="${instance_choice##* }"
            break
        done
    fi

    echo "Starting instance: $selected_instance_name in zone: $selected_instance_zone"
    gcloud compute instances start "$selected_instance_name" --zone="$selected_instance_zone" || return 1

    echo "Waiting for instance to initialize..."
    sleep 10 # Consider a more robust check if needed

    local external_ip=$(gcloud compute instances describe "$selected_instance_name" --zone="$selected_instance_zone" --format="get(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null)

    if [[ -n "$external_ip" ]]; then
        echo "External IP: $external_ip"
        echo "Connecting to instance..."
        sshinstance "$external_ip"
    else
        echo "Could not find external IP. Instance might still be starting. Try connecting manually."
    fi
}

# deleteinstance
function deleteinstance() {
    local instance_name=$1
    if [[ -z "$instance_name" ]]; then
        echo "Usage: deleteinstance <instance_name>" && return 1
    fi
    # Add a confirmation prompt
    read -r "confirm?Really delete instance '$instance_name'? [y/N]: "
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Deletion cancelled." && return 0
    fi
    gcloud compute instances delete "$instance_name"
}

# convert_to_iso8601_llm
function convert_to_iso8601_llm() {
  local input_date="$1"
  local current_date=$(date -I) # yyyy-mm-dd
  # Check if OPENAI_API_KEY is set
  if [[ -z "$OPENAI_API_KEY" ]]; then
    echo "Error: OPENAI_API_KEY environment variable is not set." >&2
    return 1
  fi
  curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "{
      \"model\": \"gpt-4o-2024-08-06\",
      \"messages\": [
        {\"role\": \"system\", \"content\": \"You convert dates given in natural language into iso8601 format (YYYY-MM-DD). Output ONLY the date string. Use the current year 2024 unless specified otherwise. The current date is $current_date.\"},
        {\"role\": \"user\", \"content\": \"$input_date\"}
      ],
      \"temperature\": 0.1
    }" | jq -r '.choices[0].message.content'
}

# gcp (git commit push helper)
function gcp() {
    local date="" time="" help=false
    # Use getopts for robust argument parsing
    while getopts ":d:t:h-" opt; do
        case $opt in
            d) date="$OPTARG" ;;
            t) time="$OPTARG" ;;
            h|-) help=true ;; # Handle --help
            \?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
            :) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
        esac
    done
    shift $((OPTIND - 1)) # Remove parsed options

    if [[ "$help" = true ]]; then
        # (Help text remains the same)
        echo -e "\nUsage: gcp [-d|--date <date>] [-t|--time <hh:mm>] [--help]"
        echo "  Stages all changes, commits with a prompted message, and pushes."
        echo "  Options allow overriding the commit date/time.\n"
        return 0
    fi

    # Check for unparsed arguments (like a commit message mistakenly put here)
    if [[ $# -gt 0 ]]; then
        echo "Error: Unexpected arguments: $@" >&2
        echo "Usage: gcp [-d date] [-t time]" >&2
        return 1
    fi

    git add .

    local commit_message
    read -r "commit_message?Commit message: "
    if [[ -z "$commit_message" ]]; then
        echo "Commit message cannot be empty. Aborting." >&2
        return 1
    fi

    local date_string=""
    if [[ -n "$date" || -n "$time" ]]; then
        local iso_date time_part
        if [[ -n "$date" ]]; then
            iso_date=$(convert_to_iso8601_llm "$date")
            if [[ $? -ne 0 || -z "$iso_date" ]]; then
                echo "Error converting date '$date'. Aborting." >&2
                return 1
            fi
        else
            iso_date=$(date +"%Y-%m-%d")
        fi

        time_part=${time:-$(date +"%H:%M")}

        # Attempt to format the date using 'date' command
        date_string=$(date -j -f "%Y-%m-%d %H:%M" "${iso_date} ${time_part}" +"%Y-%m-%dT%H:%M:%S%z" 2>/dev/null)
        if [[ $? -ne 0 ]]; then
            echo "Error formatting date/time: ${iso_date} ${time_part}. Using current time." >&2
            date_string="" # Fallback to no date override
        else
             echo "Using custom commit date: $date_string"
        fi
    fi

    if [[ -n "$date_string" ]]; then
        GIT_AUTHOR_DATE="$date_string" GIT_COMMITTER_DATE="$date_string" git commit -m "$commit_message"
    else
        git commit -m "$commit_message"
    fi

    # check commit success before pushing
    if [[ $? -eq 0 ]]; then
      echo "Pushing changes..."
      git push
    else
      echo "Commit failed. Aborting push." >&2
      return 1
    fi
}

# cmprss (audio compression)
function cmprss() {
    [[ $# -eq 0 ]] && echo "Usage: cmprss <input_file>" && return 1
    local input_file="$1"
    [[ ! -f "$input_file" ]] && echo "Error: Input file not found." && return 1
    local input_ext="${input_file##*.}"

    local bitrate sample_rate format speed_multiplier
    read -r "bitrate?Bitrate (default: 16k): "
    read -r "sample_rate?Sample rate (default: 16000): "
    read -r "format?Output format (default: opus): "
    read -r "speed_multiplier?Speed multiplier (default: 1): "

    bitrate=${bitrate:-16k}
    sample_rate=${sample_rate:-16000}
    format=${format:-opus}
    speed_multiplier=${speed_multiplier:-1}

    local filename=$(basename "$input_file" ".$input_ext")
    local output_file
    # Add suffix only if format AND speed are unchanged (or speed=1)
    if [[ "$format" == "$input_ext" && "$(echo "$speed_multiplier == 1" | bc -l)" -eq 1 ]]; then
         output_file="${filename}(compressed).${format}"
    else
         output_file="${filename}.${format}" # Format change implies difference
    fi

    local ffmpeg_cmd=("ffmpeg" "-i" "$input_file")
    # add speed filter if needed
    if (( $(echo "$speed_multiplier != 1" | bc -l) )); then
        ffmpeg_cmd+=("-filter:a" "atempo=$speed_multiplier")
    fi
    # add audio codec options
    ffmpeg_cmd+=("-ac" "1" "-ar" "$sample_rate" "-b:a" "$bitrate" "$output_file")

    echo "Running: ${ffmpeg_cmd[*]}"
    "${ffmpeg_cmd[@]}"
}

# duh (disk usage human-readable)
function duh() {
    local target="." # Default to current directory
    if [[ $# -gt 0 ]]; then
        target="$1"
    fi
    # Check if target exists
    if [[ ! -e "$target" ]]; then
        echo "Error: '$target' not found." >&2
        return 1
    fi
    # Use -d 1 for one level deep in directories, or just -h for files/single dir total
    if [[ -d "$target" ]]; then
         du -hd 1 "$target" | sort -h
    else
         du -h "$target"
    fi
}

# rename (using Anthropic API)
rename() {
    process_file() {
        local fullFilePath="$1"
        local filename=$(basename "$fullFilePath")
        local extension="${filename##*.}"
        local filenameWithoutExt="${filename%.*}"
        local dirPath=$(dirname "$fullFilePath")

        # Check if ANTHROPIC_API_KEY is set
        if [[ -z "$ANTHROPIC_API_KEY" ]]; then
          echo "Error: ANTHROPIC_API_KEY environment variable is not set." >&2
          # Optionally try the hardcoded key as a fallback ONLY IF NEEDED
          # local api_key="sk-ant-api03-..." # Avoid hardcoding keys if possible
          # If still no key, return error
          # if [[ -z "$api_key" ]]; then return 1; fi
          # else
           local api_key="$ANTHROPIC_API_KEY"
          # fi
        else
           local api_key="$ANTHROPIC_API_KEY"
        fi


        # system prompt as variable
        local systemPrompt="Rename the given filename by the user, ensuring clarity and brevity. Retain essential elements like names, chapter numbers, episode codes, dates, etc., replacing underscores and dashes with spaces (unless it is times or dates, then keep the dates combined with dashes only, use DD-MM-YYYY format). Capitalize first letters of significant words. Never capitalize the word 'and'. Remove non-informative text like 'version', 'final', 'edit', or repetitive information. Provide ONLY the new filename without the extension. Expand common abbreviations (e.g., 'lang' to 'language'). NEVER use quotes in the output. For TV series use format: [Show Title Capitalized] [Episode Code]. Remove the year from TV series filenames. For films, use format: [Film Title Capitalized] ([Year]). Examples: 'thesis_final_edit_v2' -> 'Thesis V2'; 'JohnDoe_Report_Version_23.10.2021' -> 'John Doe Report 23-10-2021'; 'Barbie.2023.HC.1080p.WEB-DL.AAC2.0.H.264-APEX[TGx]' -> 'Barbie (2023)'; 'What.If.2021.S02E08.WEB.x264-TORRENTGALAXY' -> 'What If S02E08'."

        # construct json payload using jq for safety
        local json_payload
        json_payload=$(jq -n \
          --arg model "claude-3-5-sonnet-20240620" \
          --arg system "$systemPrompt" \
          --arg user_content "$filenameWithoutExt" \
          '{ model: $model, max_tokens: 100, system: $system, messages: [ {role: "user", content: $user_content} ] }'
        )

        local response=$(curl -s https://api.anthropic.com/v1/messages \
          -H "Content-Type: application/json" \
          -H "x-api-key: $api_key" \
          -H "anthropic-version: 2023-06-01" \
          -d "$json_payload")

        local newFilename=$(echo "$response" | jq -r '.content[0].text // empty')

        if [[ -z "$newFilename" ]]; then
            echo "Error: Failed to generate new filename for '$filename'. API Response:" >&2
            echo "$response" >&2 # Print response for debugging
            return 1
        fi

        # Sanitize newFilename: remove leading/trailing whitespace, replace / with _
        newFilename=$(echo "$newFilename" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/\//_/g')

        # check again if empty after sanitizing
         if [[ -z "$newFilename" ]]; then
            echo "Error: Generated filename is empty or invalid for '$filename'." >&2
            return 1
        fi


        local newFullFilePath="$dirPath/$newFilename.$extension"

        # Avoid renaming if new name is same as old
        if [[ "$fullFilePath" == "$newFullFilePath" ]]; then
             echo "Skipping rename for '$filename', name is unchanged."
             return 0
        fi

        # Check if target file already exists
        if [[ -e "$newFullFilePath" ]]; then
             echo "Error: Target file '$newFilename.$extension' already exists. Skipping rename for '$filename'." >&2
             return 1
        fi

        if mv -n "$fullFilePath" "$newFullFilePath"; then # Use -n to prevent overwrite (belt-and-suspenders)
            echo "'$filename' -> '$newFilename.$extension'"
        else
            echo "Error: Failed to rename '$filename' to '$newFilename.$extension'" >&2
            return 1
        fi
    }

    if [[ $# -eq 0 ]]; then
        echo "Usage: rename <file1> [file2] ..." && return 1
    fi

    for file in "$@"; do
        if [[ -f "$file" ]]; then
            process_file "$file"
        elif [[ -e "$file" ]]; then
             echo "Skipping: '$file' is not a regular file." >&2
        else
            echo "Error: File not found - '$file'" >&2
        fi
    done
}

# github_repo_init
github_repo_init() {
    [[ -z "$1" ]] && echo "Usage: github_repo_init <repo_name>" && return 1
    local repo_name=$1

    # check if gh cli is installed
    if ! command -v gh &> /dev/null; then
        echo "Error: GitHub CLI 'gh' not found. Please install it." >&2
        return 1
    fi

    # check if directory already exists
    if [[ -e "$repo_name" ]]; then
       echo "Error: Directory '$repo_name' already exists." >&2
       return 1
    fi

    mkdir "$repo_name" && cd "$repo_name" || return 1 # exit if mkdir/cd fails

    git init -b main # initialize with main branch
    echo "# $repo_name" > README.md
    git add README.md
    git commit -m "Initial commit"

    echo "Creating GitHub repository '$repo_name'..."
    if gh repo create "$repo_name" --public --source=. --remote=origin; then
        echo "Pushing initial commit to origin/main..."
        if git push -u origin main; then
            echo "Repository '$repo_name' created and pushed successfully."
        else
            echo "Error: Failed to push to GitHub." >&2
            # you are already in the dir, so maybe cd .. is not needed here
            # cd .. # Clean up by going back up? Or stay in repo? Staying is probably better.
            return 1
        fi
    else
        echo "Error: Failed to create GitHub repository." >&2
        # Clean up the local directory if GitHub creation failed? Optional.
        # echo "Cleaning up local directory '$repo_name'..."
        # cd .. && rm -rf "$repo_name"
        return 1
    fi
}

# sox_audio
function sox_audio() {
    [[ -z "$1" ]] && echo "Usage: sox_audio <filename>" && return 1
    local input_file="$1"
    [[ ! -f "$input_file" ]] && echo "Error: Input file not found." && return 1

    # check if sox is installed
    if ! command -v sox &> /dev/null; then
        echo "Error: 'sox' command not found. Please install it (brew install sox)." >&2
        return 1
    fi

    local base_name="${input_file%.*}"
    local extension="${input_file##*.}"
    local output_file="${base_name}(sox).${extension}"

    echo "Applying effects to '$input_file' -> '$output_file'"
    sox "$input_file" "$output_file" vol 0.8 bass +2 reverb 50 50 100 100 0.5 2
    if [[ $? -eq 0 ]]; then
        echo "Conversion completed: $output_file"
    else
        echo "Error during sox processing." >&2
        return 1
    fi
}

# upload file to 0x0.st
upload() {
  [[ -z "$1" ]] && echo "Usage: upload <file>" && return 1
  local file_path="$1"
  [[ ! -f "$file_path" ]] && echo "Error: File not found: $file_path" && return 1
  local filename=$(basename "$file_path")

  echo "Uploading '$filename'..."
  # Use --fail to make curl exit with error on server error
  local response=$(curl --progress-bar --fail -F "file=@${file_path}" https://0x0.st)
  local curl_exit_code=$?

  if [[ $curl_exit_code -eq 0 && $response == https://0x0.st/* ]]; then
    # url encode filename for safety in url
    local encoded_filename=$(printf %s "$filename" | jq -s -R -r @uri)
    local download_link="${response}/${encoded_filename}" # use encoded name in link
    echo "Link: $download_link"
    # copy link to clipboard
    echo "$download_link" | pbcopy
    echo "Link copied to clipboard."
  else
    echo "Error: File upload failed." >&2
    echo "Curl exit code: $curl_exit_code" >&2
    echo "Server response: $response" >&2
    return 1
  fi
}

# vite-react
# Bootstrap a Vite + React (+ TailwindCSS) project using Bun.
function vite-react() {
  set -euo pipefail

  # 1. Parse CLI flags / arguments
  local ts_flag=0
  local open_code=0
  local -a extra_modules=()
  local app_name=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        cat << 'EOF'
Usage: vite-react [options] <app-name>

Bootstraps a Vite + React (+ TailwindCSS) project using Bun.

Options:
  --ts, --typescript      Use the React + TypeScript template (react-ts)
  -o, --open              Open the project in VS Code (runs "code .") before dev server
  -m, --modules <pkgs>    Space-separated list of additional npm packages to install
  -h, --help              Show this help message and exit

Examples:
  vite-react my-app
  vite-react --ts my-app
  vite-react -m motion @supabase/supabase-js my-app
  vite-react --ts -m sonner -o my-app
EOF
        return 0
        ;;
      --ts|--typescript)
        ts_flag=1
        shift
        ;;
      -o|--open)
        open_code=1
        shift
        ;;
      -m|--modules)
        shift
        if [[ $# -eq 0 || "$1" == -* ]]; then
          echo "Error: --modules requires at least one module name." >&2
          return 1
        fi
        while [[ $# -gt 0 && "$1" != -* ]]; do
          extra_modules+=("$1")
          shift
        done
        ;;
      -*)
        echo "Unknown option: $1" >&2
        return 1
        ;;
      *)
        if [[ -n "$app_name" ]]; then
          echo "Error: multiple app names supplied: '$app_name' and '$1'." >&2
          return 1
        fi
        app_name="$1"
        shift
        ;;
    esac
  done

  # 2. Validate app name & environment
  if [[ -z "$app_name" ]]; then
    echo "Usage: vite-react [options] <app-name>" >&2
    return 1
  fi
  if [[ -e "$app_name" ]]; then
    echo "✖︎ '$app_name' already exists." >&2
    return 1
  fi
  command -v bun >/dev/null || {
    echo "✖︎ Bun is not installed / not in PATH." >&2
    return 1
  }

  # 3. Create the project
  echo "› Creating Vite project '$app_name' …"
  if (( ts_flag )); then
    bun create vite@latest "$app_name" --template react-ts
  else
    bun create vite@latest "$app_name" --template react
  fi
  cd "$app_name"

  # 4. Install Tailwind and optional extra modules
  echo "› Installing TailwindCSS (and extras) …"
  bun add tailwindcss @tailwindcss/vite "${extra_modules[@]}"

  # 5. Rewrite vite.config.[ts|js]
  local vite_cfg
  if [[ -f vite.config.ts ]]; then
    vite_cfg="vite.config.ts"
  elif [[ -f vite.config.js ]]; then
    vite_cfg="vite.config.js"
  else
    echo "✖︎ vite.config.[ts|js] not found." >&2
    return 1
  fi

  cat > "$vite_cfg" << 'EOF'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
});
EOF
  echo "› Rewrote $vite_cfg"

  # 6. Overwrite src/index.css
  cat > src/index.css << 'EOF'
@import url("https://fonts.googleapis.com/css2?family=Geist+Mono:wght@100..900&family=Geist:wght@100..900&family=IBM+Plex+Mono:wght@300;400;500;600;700&family=JetBrains+Mono:wght@100..800&display=swap");
@import "tailwindcss";

:root {
  font-family: system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;

  font-synthesis: none;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

@theme {
  --font-geist: "Geist", sans-serif;
  --font-geist-mono: "Geist Mono", monospace;
  --font-jetbrains-mono: "JetBrains Mono", monospace;
  --font-plex-mono: "IBM Plex Mono", monospace;
}
EOF
  echo "› Rewrote src/index.css"

  # 7. Remove App.css & rewrite App component
  rm -f src/App.css

  local app_file
  if [[ -f src/App.tsx ]]; then
    app_file="src/App.tsx"
  elif [[ -f src/App.jsx ]]; then
    app_file="src/App.jsx"
  else
    echo "✖︎ App component not found." >&2
    return 1
  fi

  cat > "$app_file" << 'EOF'
import { useState, useEffect } from "react";

function App() {
  return <></>;
}

export default App;
EOF
  echo "› Rewrote $app_file (and removed src/App.css)"

  # 8. Final install & dev server
  echo "› Running final bun install …"
  bun install

  if (( open_code )); then
    command -v code >/dev/null && code .
  fi

  echo "✓ Project ready – starting dev server (Ctrl‑C to quit)"
  bun run dev --open
}

# -- Plugin & Completion Initialization --

# zsh-autosuggestions (manual install)
# Sourcing plugins always adds some startup time. This is generally fast though.
ZSH_AUTOSUGGEST_MANUAL_INSTALL_DIR="$HOME/.zsh/zsh-autosuggestions"
if [[ -f "$ZSH_AUTOSUGGEST_MANUAL_INSTALL_DIR/zsh-autosuggestions.zsh" ]]; then
  source "$ZSH_AUTOSUGGEST_MANUAL_INSTALL_DIR/zsh-autosuggestions.zsh"
fi

# fzf keybindings and fuzzy completion
# Running <(...) executes command, source loads output. Adds startup time.
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
fi

# zeoxide init
# Uses eval $() which runs a command. Adds startup time.
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# iTerm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# bun completions
# Check existence before sourcing
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Add completion paths to fpath (Function Path)
# Ensure these directories exist and contain completion files
# Group fpath modifications together before compinit
fpath=($HOME/.zsh/completions $fpath) # Deno completions (manual add)
fpath=($HOME/.docker/completions $fpath) # Docker completions

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Case-insensitive matching
zstyle ':completion:*' menu no # Disable completion menu for zeoxide? (as commented)

# Keybindings
# Edit command line in $EDITOR
autoload -z edit-command-line && zle -N edit-command-line && bindkey "^X^E" edit-command-line

# Initialize Completion System LAST
# Only run compinit once, after all fpath modifications
# Use caching (-C) to speed up subsequent loads
# Check if cache needs update (e.g., if ~/.zshrc or completion files are newer)
# Simple check: if zcompdump is older than zshrc or doesn't exist
if [[ ! -f ~/.zcompdump || ~/.zshrc -nt ~/.zcompdump ]]; then
  autoload -Uz compinit && compinit -i
  echo "Completion cache rebuilt." # Optional message
else
  autoload -Uz compinit && compinit -C -i
fi

# Prompt (PS1)
PS1="%F{reset}%n %F{blue}%~ %F{reset}%# %F"
