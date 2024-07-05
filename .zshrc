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
alias runwebdev='/Users/bartek/Scripts/Open-Web-Dev-Testing/openWebDevTest.sh'
alias runcopilot='/Users/bartek/Scripts/Text-Copilot/runTextCopilot.sh'
alias runpythondev='source /Users/bartek/Scripts/Python-Testing-Env/openPythonTest.sh'
alias runcopilot='source /Users/bartek/Scripts/Typing-Copilot/runTypingCopilot.sh'
alias act='source bin/activate'
alias nq='networkQuality'
alias zshconfig="code ~/.zshrc"
alias reload="source ~/.zshrc"

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

    # Get the list of terminated instances
    local instances=$(gcloud compute instances list --filter="status=TERMINATED" --format="table[no-heading](name, zone)")
    # Check if any instances are terminated
    if [[ -z "$instances" ]]; then
        echo "No terminated instances found."
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
            echo "Instance '$instance_name' not found or not terminated."
            return
        fi
    else
        # Display the list of terminated instances
        echo "Please select an instance to start:"
        for ((i = 1; i <= ${#instance_array[@]}; i++)); do
            echo "$i. ${instance_array[$i]%% *}"
        done
        # Read user input
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
    # Run the gcloud command to start the selected instance
    gcloud compute instances start "$selected_instance_name" --zone="$selected_instance_zone"

    # Wait a bit for the instance to fully start
    echo "Waiting for instance to initialize..."
    sleep 10

    # Get the external IP address
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
    instance_name=$1  # Assign the first positional parameter to instance_name

    if [ -z "$instance_name" ]; then
        echo "Error: No instance name provided."
        echo "Usage: deleteinstance <instance_name>"
        return 1
    fi

    gcloud compute instances delete "$instance_name"
}

function dlyt() {
    # use the first argument as the url
    local url=$1

    yt-dlp "$url" -f "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --output "%(title)s.%(ext)s"
}


function gcp() {
    ga .
    read -r "commit_message?Commit message: "
    git commit -m "$commit_message"
    git push
}

upload() {
    local short=false
    local file_path=""
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

    # set defaults if empty
    bitrate=${bitrate:-16k}
    sample_rate=${sample_rate:-16000}
    format=${format:-opus}

    # get input filename without extension
    filename=$(basename "$input_file" | sed 's/\.[^.]*$//')

    # construct output filename
    output_file="${filename}.${format}"

    # run ffmpeg command
    ffmpeg -i "$input_file" -ac 1 -ar "$sample_rate" -b:a "$bitrate" "$output_file"
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

# zeoxide initialization and iterm2 integration
eval "$(zoxide init --cmd cd zsh)"
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

source ~/.zsh_secrets

# syntax highlighting

source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh