# zsh Autosuggestions plugin manual installation
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh


# history options
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# completion styling to help with zeoxide
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no


# node and npm initialization
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH=/opt/homebrew/bin:$PATH
export PATH="/usr/local/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH
export PATH="/Users/bartek/.local/bin:$PATH"
export NVM_DIR="$HOME/.nvm"

# from https://peterlyons.com/problog/2018/01/zsh-lazy-loading/ 
# placeholder nvm shell function
# On first use, it will set nvm up properly which will replace the `nvm`
# shell function with the real one
nvm() {
  if [[ -d '/usr/local/opt/nvm' ]]; then
    NVM_DIR="/usr/local/opt/nvm"
    export NVM_DIR
    # shellcheck disable=SC1090
    source "${NVM_DIR}/nvm.sh"
    if [[ -e ~/.nvm/alias/default ]]; then
      PATH="${PATH}:${HOME}.nvm/versions/node/$(cat ~/.nvm/alias/default)/bin"
    fi
    # invoke the real nvm function now
    nvm "$@"
  else
    echo "nvm is not installed" >&2
    return 1
  fi
}



# personal aliases
alias act='source bin/activate'
alias nq='networkQuality'
alias zshconfig="code ~/.zshrc"
alias reload="source ~/.zshrc"
alias hist="cat .zsh_history | fzf | pbcopy"

alias fcat="fzf | xargs cat"
alias ls="eza"
alias la="eza -l --no-permissions --no-user --no-filesize"
alias laa="eza -la --no-permissions --no-user --no-filesize"

alias gs='git status'
alias ga='git add'
alias gp='git push'
alias gc='git commit'
alias cp='cp -iv'
alias mv='mv -iv'
alias cl='clear'
alias ipinfo='curl -s http://ip-api.com/json/ | jq "."'

export EDITOR=/usr/bin/nano

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# dir color meanings
# da = date and time
# di = directory
# ex = executable
# fi = file
# sn = size


# export EZA_COLORS="di=34:ex=32:fi=0:sn=0:da=32"
# export EXA_COLORS="di=0;35:da=0;0:sn=0;0"

# export EXA_COLORS="da=0;0:sn=0;0"
export EXA_COLORS="di=38;5;117:ex=38;5;177:no=00:da=0;0:sn=0;0"



# Bind keys for history search (eg. only show matches from the current line)
autoload -Uz compinit && compinit
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# Prompt customization
PS1="%F{white}%n %F{#F38BA8}%~ %F{white}%# %F"

# personal functions
function listinstances() {
    gcloud compute instances list --format="table[no-heading](name, networkInterfaces[0].accessConfigs[0].natIP:label=EXTERNAL_IP)"
}

function sshinstance() {
    if [ -z "$1" ]; then
        read -r "external_ip?Enter the external IP of the instance you want to connect to: "
    else
        external_ip="$1"
    fi

    ssh_key="~/latest-server-ssh-key"

    ssh -i "$ssh_key" nk3h8wbq@"$external_ip" -o StrictHostKeyChecking=no
}



function tempinstance() {
    # Define an array of instance types
    local instance_types=(
        "t2d-standard-1"
        "t2d-standard-2"
        "t2d-standard-4"
        "t2d-standard-8"
    )

    # Display the list of instance types
    echo "Please select an instance type:"
    for ((i = 1; i <= ${#instance_types[@]}; i++)); do
        echo "$((i)). ${instance_types[$i]}"
    done

    # Read user input
    read -r "selection?Enter the number corresponding to the instance type: "

    if [[ $selection -gt 0 && $selection -le ${#instance_types[@]} ]]; then
        # Subtract 1 from the selection to get the correct array index
        local selected_type=${instance_types[$((selection))]}
        echo "You selected: $selected_type"

        # Define the path to the SSH key file
        local ssh_key_file=~/latest-server-ssh-key.pub

        # Read the SSH key from the file
        if [[ -f $ssh_key_file ]]; then
            local ssh_key
            ssh_key=$(<"$ssh_key_file")
        else
            echo "SSH key file $ssh_key_file not found."
            return 1
        fi

        # Run the gcloud command with the selected instance type
        gcloud compute instances create testing-instance \
            --zone=europe-west2-a \
            --machine-type=$selected_type \
            --preemptible \
            --tags=minecraft,http-server,https-server \
            --scopes=https://www.googleapis.com/auth/cloud-platform \
            --metadata ssh-keys="nk3h8wbq:$ssh_key"
    else
        echo "Invalid selection. Please try again."
    fi
}

function stopinstances {
    local instance_name="$1"

    # Get the list of running instances
    local instances=$(gcloud compute instances list --filter="status=RUNNING" --format="table[no-heading](name, zone)")
    # Check if any instances are running
    if [[ -z "$instances" ]]; then
        echo "No running instances found."
        return
    fi
    # Convert the instances list to an array
    local instance_array=("${(@f)instances}")

    if [[ -n "$instance_name" ]]; then
        # Check if the provided instance name exists in the list
        local found=false
        for instance in "${instance_array[@]}"; do
            if [[ "${instance%% *}" == "$instance_name" ]]; then
                local selected_instance_name="$instance_name"
                local selected_instance_zone="${instance##* }"
                found=true
                break
            fi
        done
        if ! $found; then
            echo "Instance '$instance_name' not found or not running."
            return
        fi
    else
        # Display the list of running instances
        echo "Please select an instance to stop:"
        for ((i = 1; i <= ${#instance_array[@]}; i++)); do
            echo "$i. ${instance_array[$i]%% *}"
        done
        # Read user input
        read -r "selection?Enter the number corresponding to the instance you want to stop: "
        if [[ $selection -gt 0 && $selection -le ${#instance_array[@]} ]]; then
            # Get the selected instance details
            local selected_instance="${instance_array[$((selection))]}"
            local selected_instance_name="${selected_instance%% *}"
            local selected_instance_zone="${selected_instance##* }"
        else
            echo "Invalid selection. Please try again."
            return
        fi
    fi

    echo "Stopping instance: $selected_instance_name in zone: $selected_instance_zone"
    # Run the gcloud command to stop the selected instance
    gcloud compute instances stop "$selected_instance_name" --zone="$selected_instance_zone"
}

function startinstances {
    local instance_name="$1"

    # get list of terminated instances
    local instances=$(gcloud compute instances list --filter="status=TERMINATED" --format="table[no-heading](name, zone)")
    # check if any instances are terminated
    if [[ -z "$instances" ]]; then
        echo "No terminated instances found."
        return
    fi
    # convert instances list to an array
    local instance_array=("${(@f)instances}")

    if [[ -n "$instance_name" ]]; then
        # check if provided instance name exists in the list
        local found=false
        for instance in "${instance_array[@]}"; do
            if [[ "${instance%% *}" == "$instance_name" ]]; then
                local selected_instance_name="$instance_name"
                local selected_instance_zone="${instance##* }"
                found=true
                break
            fi
        done
        if ! $found; then
            echo "Instance '$instance_name' not found or not terminated."
            return
        fi
    else
        # display list of terminated instances
        echo "Please select an instance to start:"
        for ((i = 1; i <= ${#instance_array[@]}; i++)); do
            echo "$i. ${instance_array[$i]%% *}"
        done
        # read user input
        read -r "selection?Enter the number corresponding to the instance you want to start: "
        if [[ $selection -gt 0 && $selection -le ${#instance_array[@]} ]]; then
            # Get the selected instance details
            local selected_instance="${instance_array[$((selection))]}"
            local selected_instance_name="${selected_instance%% *}"
            local selected_instance_zone="${selected_instance##* }"
        else
            echo "Invalid selection. Please try again."
            return
        fi
    fi

    echo "Starting instance: $selected_instance_name in zone: $selected_instance_zone"
    # run gcloud command to start the selected instance
    gcloud compute instances start "$selected_instance_name" --zone="$selected_instance_zone"

    # wait a bit for instance to fully start
    echo "Waiting for instance to initialize..."
    sleep 10

    # get external IP address
    local external_ip=$(gcloud compute instances describe "$selected_instance_name" --zone="$selected_instance_zone" --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

    if [[ -n "$external_ip" ]]; then
        echo "External IP: $external_ip"
        echo "Connecting to instance..."
        sshinstance "$external_ip"
    else
        echo "Could not find external IP. Please check the instance status and try to connect manually."
    fi
}

function deleteinstance() {
    instance_name=$1  # assign first positional parameter to instance_name

    if [ -z "$instance_name" ]; then
        echo "Error: No instance name provided."
        echo "Usage: deleteinstance <instance_name>"
        return 1
    fi

    gcloud compute instances delete "$instance_name"
}


function convert_to_iso8601() {
    # check if input is provided
    if [[ -z "$1" ]]; then
        echo "Usage: convert_to_iso8601 <date>"
        return 1
    fi

    # function to remove ordinal suffixes (st, nd, rd, th) from day part
    function remove_suffix() {
        echo "$1" | sed -E 's/([0-9]+)(st|nd|rd|th)/\1/'
    }

    # preprocess input to remove ordinal suffixes
    cleaned_input=$(remove_suffix "$1")

    # attempt to convert using "Month Day" format
    iso_date=$(date -j -f "%B %d" "$cleaned_input" +"%Y-%m-%d" 2>/dev/null)

    # if first conversion fails, attempt "Day Month" format
    if [[ $? -ne 0 ]]; then
        iso_date=$(date -j -f "%d %B" "$cleaned_input" +"%Y-%m-%d" 2>/dev/null)
    fi

    # if both previous conversions fail, attempt "dd-mm-yyyy" format
    if [[ $? -ne 0 ]]; then
        iso_date=$(date -j -f "%d-%m-%Y" "$cleaned_input" +"%Y-%m-%d" 2>/dev/null)
    fi

    # check if any date command was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Invalid date format. Please use 'Month Day', 'Day Month', or 'dd-mm-yyyy' format (e.g., 'August 5th', '5th August', '05-08-2024')."
        return 1
    else
        echo "$iso_date"
    fi
}

function convert_to_iso8601_llm() {
  local input_date="$1"
  curl https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "{
      \"model\": \"gpt-4o-mini\",
      \"messages\": [
        {
          \"role\": \"system\",
          \"content\": \"You convert dates given in natural language into iso8601 format. Output just the date in iso8601 format. The current date is 6th August 2024.\"
        },
        {
          \"role\": \"user\",
          \"content\": \"$input_date\"
        }
      ]
    }" | jq -r '.choices[0].message.content'
}


function gcp() {
    local date=""
    local time=""
    local help=false

    # parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--date)
                date="$2"
                shift 2
                ;;
            -t|--time)
                time="$2"
                shift 2
                ;;
            --help)
                help=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # check for help flag
    if [[ "$help" == true ]]; then
        echo -e "\nUsage: gcp [-d|--date <date>] [-t|--time <hh:mm>] [--help]"
        echo
        echo "Description:"
        echo "  Stages all changes, commits with a message, and pushes to the remote repository."
        echo "  Optionally allows setting a custom date and time for the commit."
        echo
        echo "Options:"
        echo "  -d, --date <date>       Set a custom date for the commit (e.g., 'August 5th', '5th August', '05-08-2024')"
        echo "  -t, --time <hh:mm>      Set a custom time for the commit"
        echo "  --help                  Display this help message"
        echo
        echo "Details:"
        echo "  - If no date is provided, the current date is used"
        echo "  - If no time is provided, the current time is used"
        echo "  - Date format: 'Month Day', 'Day Month', or 'dd-mm-yyyy' (e.g., 'August 5th', '5th August', '05-08-2024')"
        echo "  - Time format: hh:mm (e.g., 14:30)"
        echo "  - The commit message is prompted interactively\n"
        return 0
    fi

    git add .

    echo -n "Commit message: "
    read commit_message

    # prepare date string
    if [[ -n "$date" || -n "$time" ]]; then
        if [[ -n "$date" ]]; then
            # Convert the provided date using the convert_to_iso8601 function
            iso_date=$(convert_to_iso8601_llm "$date")
            if [[ $? -ne 0 ]]; then
                echo "Error: Unable to parse the date '$date'."
                return 1
            fi
        else
            iso_date=$(date +"%Y-%m-%d")
        fi
        
        if [[ -z "$time" ]]; then
            time=$(date +"%H:%M")
        fi
        
        # combine date and time to ISO 8601 format
        date_string=$(date -j -f "%Y-%m-%d %H:%M" "${iso_date} ${time}" +"%Y-%m-%dT%H:%M:%S")
        echo "Setting GIT_AUTHOR_DATE and GIT_COMMITTER_DATE to: $date_string"
        GIT_AUTHOR_DATE="$date_string" GIT_COMMITTER_DATE="$date_string" git commit -m "$commit_message"
    else
        git commit -m "$commit_message"
    fi

    # push changes
    git push
}

upload() {
    local short=false
    local file_path=""
    
    # Check for help flag
    if [[ "$1" == "--help" ]]; then
        echo "\nUsage: upload [-s|--short] <file_path>"
        echo
        echo "Description:"
        echo "  Uploads a file to a file hosting service and copies the URL to the clipboard."
        echo
        echo "Options:"
        echo "  -s, --short    Generate and output a shortened URL"
        echo "  --help         Display this help message"
        echo
        echo "Details:"
        echo "  - For files up to 99MB, uploads to waifuvault.moe"
        echo "  - For files over 99MB, uploads to 0x0.st"
        echo "  - The resulting URL is automatically copied to the clipboard"
        echo "  - If -s or --short flag used, a shortened URL is generated, copied instead\n"
        return 0
    fi

    # parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -s|--short) short=true ;;
            *) file_path="$1" ;;
        esac
        shift
    done
    # check if file path is provided
    if [[ -z "$file_path" ]]; then
        echo "Usage: upload [-s|--short] <file_path>"
        echo "Use 'upload --help' for more information."
        return 1
    fi
    # Get file size in bytes
    local file_size=$(stat -f%z "$file_path")
    local size_limit=$((99 * 1024 * 1024))  # 99MB in bytes
    local upload_url=""
    if [ "$file_size" -gt "$size_limit" ]; then
        # Use 0x0 for files over 99MB
        upload_url=$(curl -s -F "file=@$file_path" https://0x0.st)
    else
        # Use waifuvault.moe for files 99MB or smaller
        local base_url="https://waifuvault.moe/rest?expires=2m"
        upload_url=$(curl --progress-bar --request PUT --url "$base_url" \
                            --header 'Content-Type: multipart/form-data' \
                            --form file=@"$file_path" | jq -r .url)
    fi
    # Log upload URL
    echo "$upload_url"
    # copy upload URL to clipboard
    echo "$upload_url" | pbcopy
    
    # do URL shortening if -s or --short flag passed
    if $short; then
        local short_url=$(curl -s "https://is.gd/create.php?format=simple&url=$upload_url")
        echo "$short_url" | pbcopy
        echo "$short_url"
    fi
}

transcribe() {
    # Check for help flag
    if [[ "$1" == "--help" ]]; then
        echo "\nUsage: transcribe [-f|--file <file_path>] [<file_url>] [-o|--output <output_file>]"
        echo
        echo "Description:"
        echo "  Transcribes audio from a file or URL using the fal.ai Wizper service."
        echo
        echo "Options:"
        echo "  -f, --file <file_path>          Specify a local file to upload and transcribe"
        echo "  -o, --output <output_file>      Save the transcription to a file"
        echo "  --help                          Display this help message"
        echo
        echo "Arguments:"
        echo "  <file_url>                      URL of audio file to transcribe (if not using -f)"
        echo
        echo "Details:"
        echo "  - If -f is used, the local file is first uploaded using the 'upload' function"
        echo "  - The transcription is performed using the fal.ai Wizper service"
        echo "  - The resulting transcription is displayed in the terminal"
        echo "  - The transcription is automatically copied to the clipboard"
        echo "  - If -o is used, the transcription is also saved to the specified file"
        echo
        echo "Environment Variables:"
        echo "  FAL_KEY                          API key for the fal.ai service (must be set)\n"
        return 0
    fi

    local file_url=""
    local is_local=false
    local output_file=""

    # parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -f|--file)
                is_local=true
                file_url="$2"
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            *)
                file_url="$1"
                shift
                ;;
        esac
    done

    # Log arguments
    # echo "Arguments: is_local=$is_local, file_url=$file_url, output_file=$output_file"

    # If the -f flag is present, upload the file first
    if $is_local; then
        if [[ -z "$file_url" ]]; then
            echo "Error: No file path provided."
            echo "Usage: transcribe -f <file_path> [-o <output_file>] or transcribe <file_url> [-o <output_file>]"
            return 1
        fi
        echo "Uploading file: $file_url"
        file_url=$(upload "$file_url")
        if [[ $? -ne 0 ]]; then
            echo "File upload failed."
            return 1
        fi
        # echo "Uploaded file URL: $file_url"
    fi

    if [[ -z "$file_url" ]]; then
        echo "Error: No file URL provided."
        echo "Usage: transcribe -f <file_path> [-o <output_file>] or transcribe <file_url> [-o <output_file>]"
        return 1
    fi

    # Encode the file URL to handle spaces
    encoded_url=$(echo "$file_url" | sed 's/ /%20/g')
    # echo "Encoded URL: $encoded_url"

    # Perform transcription
    local transcription=$(curl -s --request POST \
        --url https://fal.run/fal-ai/wizper \
        --header "Authorization: Key $FAL_KEY" \
        --header "Content-Type: application/json" \
        --data '{
            "audio_url": "'"$encoded_url"'",
            "language": "en",
            "version": "3",
            "task": "transcribe"
        }' | jq .text -r)

    # Log transcription
    echo "$transcription"

    # Copy transcription to clipboard
    echo "$transcription" | pbcopy

    # If output file is specified, save transcription to file and output file path
    if [[ -n "$output_file" ]]; then
        echo "$transcription" > "$output_file"
        echo "Transcription saved to: $output_file"
    else
        # echo "$transcription"
    fi
}

function compressAudio() {
    # check if input file is provided
    if [[ $# -eq 0 ]]; then
        echo "usage: compress_audio <input_file>"
        return 1
    fi

    input_file="$1"
    
    # ask for parameters
    read "bitrate?enter bitrate (default: 16k): "
    read "sample_rate?enter sample rate (default: 16000): "
    read "format?enter output format (default: opus): "
    read "speed_multiplier?enter speed multiplier (default: 1): "

    # set defaults if empty
    bitrate=${bitrate:-16k}
    sample_rate=${sample_rate:-16000}
    format=${format:-opus}
    speed_multiplier=${speed_multiplier:-1}

    # get input filename without extension
    filename=$(basename "$input_file" | sed 's/\.[^.]*$//')

    # construct output filename
    output_file="${filename}.${format}"

    # run ffmpeg command with speed adjustment
    if (( $(echo "$speed_multiplier == 1" | bc -l) )); then
        ffmpeg -i "$input_file" -ac 1 -ar "$sample_rate" -b:a "$bitrate" "$output_file"
    else
        ffmpeg -i "$input_file" -filter:a "atempo=$speed_multiplier" -ac 1 -ar "$sample_rate" -b:a "$bitrate" "$output_file"
    fi
}

function duh() {
    local file_name="$1"
    du -h "$file_name"
}

rename() {
    # Function to process a single file
    process_file() {
        local fullFilePath="$1"
        local filename=$(basename "$fullFilePath")
        local extension="${filename##*.}"
        local filenameWithoutExt="${filename%.*}"
        local dirPath=$(dirname "$fullFilePath")

        # Escape the system prompt for JSON
        local systemPrompt=$(jq -n --arg sp "Rename the given filename by the user, ensuring clarity and brevity. Retain essential elements like names, chapter numbers, episode codes, dates, etc., replacing underscores and dashes with spaces (unless it is times or dates, then keep the dates combined with dashes only, use DD-MM-YYYY). Capitalise first letters. Never capilatize the word 'and'. Remove non-informative text like 'version', 'final', 'edit', or repetitive information. Provide the new filename without the extension. Expand abbreviations like 'lang\" to language'. NEVER use quotes. For TV series use this format: [Film title with capitalized first letters of each word] [Episode code]. In TV series, remove the year from the filename, but keep it in brackets for films. Examples: 'thesis_final_edit_v2' becomes 'Thesis V2'; 'JohnDoe_Report_Version_23.10.2021' becomes 'John Doe Report 23-10-2021'; 'Barbie.2023.HC.1080p.WEB-DL.AAC2.0.H.264-APEX[TGx]' becomes 'Barbie (2023)'; 'What.If.2021.S02E08.WEB.x264-TORRENTGALAXY' becomes 'What If S02E08'." '$sp')

        local response=$(curl -s https://api.anthropic.com/v1/messages \
          -H "Content-Type: application/json" \
          -H "x-api-key: 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" \
          -H "anthropic-version: 2023-06-01" \
          -d "$(jq -n \
            --arg model "claude-3-5-sonnet-20240620" \
            --arg system "$systemPrompt" \
            --arg user_content "$filenameWithoutExt" \
            '{
              model: $model,
              max_tokens: 1024,
              system: $system,
              messages: [
                {role: "user", content: $user_content}
              ]
            }'
          )")

        # Extract the new filename from the response
        local newFilename=$(echo "$response" | jq -r '.content[0].text')

        # Ensure newFilename is not empty
        if [[ -z "$newFilename" ]]; then
            echo "Error: Failed to generate new filename for $filename"
            return 1
        fi

        # Construct the new full file path
        local newFullFilePath="$dirPath/$newFilename.$extension"

        # Rename the file
        if mv "$fullFilePath" "$newFullFilePath"; then
            echo "File successfully renamed to: $newFilename.$extension"
        else
            echo "Error: Failed to rename the file $filename"
            return 1
        fi
    }

    # Main function logic
    if [[ $# -eq 0 ]]; then
        echo "Usage: rename <file1> [file2] [file3] ..."
        return 1
    fi

    # Loop through all provided files
    for file in "$@"; do
        if [[ -f "$file" ]]; then
            process_file "$file"
        else
            echo "Error: File not found - $file"
        fi
    done
}

github_repo_init() {
    # Check if a repository name was provided
    if [ -z "$1" ]; then
        echo "Please provide a repository name."
        return 1
    fi

    local repo_name=$1

    # Create the directory and navigate into it
    mkdir $repo_name && cd $repo_name

    # Initialize the local git repository
    git init

    # Create an initial file
    echo "# $repo_name" > README.md

    # Add and commit the README file
    git add README.md
    git commit -m "Initial commit"

    # Rename the branch to 'main'
    git branch -M main

    # Create a new repository on GitHub
    gh repo create $repo_name --public --source=. --remote=origin

    # Push the changes to GitHub
    git push -u origin main

    echo "Repository $repo_name has been created and pushed to GitHub."
}

function combine() {
    local dir="."
    local use_tree=false
    local output_file=""
    local output=""

    # parse options
    while getopts ":to:" opt; do
        case ${opt} in
            t ) use_tree=true ;;
            o ) output_file=$OPTARG ;;
            \? ) echo "Usage: combine [-t] [-o output_file] [directory]"; return 1 ;;
        esac
    done
    shift $((OPTIND -1))

    # set directory if provided
    [[ $1 ]] && dir="$1"

    # blacklist of files/directories to exclude
    local blacklist=(
        ".git"
        ".gitignore"
        ".css.map"
        ".DS_Store"
        "node_modules"
        ".env"
        ".vscode"
        ".idea"
        "*.log"
        "*.tmp"
        "*.temp"
        "*.swp"
        "*.swo"
        "*.bak"
        "*.cache"
        ".jpeg"
        ".png"
        ".jpg"
    )

    # create grep patterns from blacklist
    local grep_patterns=()
    for item in "${blacklist[@]}"; do
        grep_patterns+=("-e" "$(printf '%s' "$item" | sed 's/[.[\*^$/]/\\&/g')")
    done

    # add tree output if requested
    if $use_tree; then
        if command -v tree >/dev/null 2>&1; then
            output+="# Directory structure:\n\n"
            output+="$(tree -L 2 "$dir")\n\n\n"
        else
            echo "tree command not found. Skipping directory structure."
        fi
    fi

    # find all files recursively, excluding blacklisted items
    while IFS= read -r file; do
        # get relative path
        local rel_path="${file#$dir/}"
        
        # add formatted header and file contents to output
        output+="# $rel_path contents:\n\n"
        output+="$(cat "$file")\n\n\n"
    done < <(find "$dir" -type f | grep -v "${grep_patterns[@]}")

    # output and copy to clipboard
    echo -e "$output" | tee >(pbcopy)

    # save to file if requested
    if [[ -n "$output_file" ]]; then
        echo -e "$output" > "$output_file"
        echo "Output saved to $output_file"
    fi
}

ytdl() {
    local url
    if [[ -z "$1" ]]; then
        echo -n "Enter YouTube URL: "
        read -r url
    else
        url="$1"
    fi

    local type
    type=$(echo -e "video\naudio" | fzf --prompt="Select type: " --header="↑↓:move ↵:select" --height=5 --layout=reverse)

    local format_option quality_option
    if [[ "$type" == "audio" ]]; then
        local aFormat
        aFormat=$(echo -e "mp3\nogg\nwav\nopus" | fzf --prompt="Select audio format: " --header="↑↓:move ↵:select" --height=7 --layout=reverse)
        format_option="--extract-audio --audio-format $aFormat"
        quality_option="--audio-quality 0"
    else
        local vQuality
        vQuality=$(echo -e "1080\n1440\nmax\n144\n240\n360\n480\n720\n2160" | fzf --prompt="Select video quality: " --header="↑↓:move ↵:select" --height=12 --layout=reverse)
        if [[ "$vQuality" == "max" ]]; then
            format_option="-f bestvideo+bestaudio/best"
        else
            format_option="-f bestvideo[height<=$vQuality]+bestaudio/best[height<=$vQuality]"
        fi
        quality_option=""
    fi
    echo "Downloading ${type}..."

    yt-dlp \
        $format_option \
        $quality_option \
        --external-downloader aria2c \
        --external-downloader-args "-x 16 -s 16 -k 1M" \
        -o "%(title)s.%(ext)s" \
        --no-playlist \
        --embed-thumbnail \
        --add-metadata \
        --no-warnings \
        --ignore-errors \
        "$url"

    echo "Download complete!"
}

pythondev() {
    # Ask for environment name
    read "env_name?Enter a name for your Python environment: "

    # Select Python version using fzf
    local python_version=$(echo "3.10\n3.11\n3.12" | fzf --height=5 --prompt="Select Python version: ")

    # Ask if user wants to create files
    local create_files=$(echo "no\nyes" | fzf --height=4 --prompt="Do you want to create Python files? ")

    local file_names=""
    if [[ $create_files == "yes" ]]; then
        read "file_names?Enter the names of the Python files to create (comma-separated): "
    fi

    # Create and activate the virtual environment
    python$python_version -m venv $env_name
    cd $env_name
    source bin/activate

    # Create the Python files if requested
    if [[ $create_files == "yes" ]]; then
        IFS=',' read -r -A files <<< "$file_names"
        for file in "${files[@]}"; do
            file=$(echo $file | xargs)  # Trim whitespace
            if [[ -n "$file" ]]; then
                touch "$file"
                echo "Created file: $file"
            fi
        done
    fi

    echo "Python $python_version environment '$env_name' is now active."
}

typetext() {
    local wait_time=2  # Default wait time

    # Parse options
    while getopts ":t:" opt; do
        case $opt in
            t)
                wait_time=$OPTARG
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                return 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    read "text_type?Text to type: "

    echo "Waiting for $wait_time seconds..."
    sleep "$wait_time"

    # type the text using osascript
    osascript -e "tell application \"System Events\" to keystroke \"$text_type\""
}


source <(fzf --zsh)

# zeoxide initialization and iterm2 integration
eval "$(zoxide init --cmd cd zsh)"
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

source ~/.zsh_secrets

# syntax highlighting

source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh