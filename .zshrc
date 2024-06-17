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
    # Get the list of running instances
    local instances=$(gcloud compute instances list --filter="status=RUNNING" --format="table[no-heading](name, zone)")

    # Check if any instances are running
    if [[ -z "$instances" ]]; then
        echo "No running instances found."
        return
    fi

    # Convert the instances list to an array
    local instance_array=("${(@f)instances}")

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

        echo "Stopping instance: $selected_instance_name in zone: $selected_instance_zone"

        # Run the gcloud command to stop the selected instance
        gcloud compute instances stop "$selected_instance_name" --zone="$selected_instance_zone"
    else
        echo "Invalid selection. Please try again."
    fi
}

function startinstances {
    # Get the list of running instances
    local instances=$(gcloud compute instances list --filter="status=TERMINATED" --format="table[no-heading](name, zone)")

    # Check if any instances are running
    if [[ -z "$instances" ]]; then
        echo "No running instances found."
        return
    fi

    # Convert the instances list to an array
    local instance_array=("${(@f)instances}")

    # Display the list of running instances
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

        echo "Starting instance: $selected_instance_name in zone: $selected_instance_zone"

        # Run the gcloud command to stop the selected instance
        gcloud compute instances start "$selected_instance_name" --zone="$selected_instance_zone"
    else
        echo "Invalid selection. Please try again."
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

    # upload file and get URL
    echo "Uploading file: "
    local base_url="https://waifuvault.moe/rest?expires=2m"
    local upload_url=$(curl --progress-bar --request PUT --url "$base_url" \
                        --header 'Content-Type: multipart/form-data' \
                        --form file=@"$file_path" | jq -r .url)

    # copy upload URL to clipboard
    echo "$upload_url" | pbcopy
    echo "$upload_url"
    
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

    # parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -f|--file)
                is_local=true
                file_url="$2"
                shift 2
                ;;
            *)
                file_url="$1"
                shift
                ;;
        esac
    done

    # If the -f flag is present, upload the file first
    if $is_local; then
        if [[ -z "$file_url" ]]; then
            echo "Error: No file path provided."
            echo "Usage: transcribe -f <file_path> or transcribe <file_url>"
            return 1
        fi
        file_url=$(upload "$file_url")
        if [[ $? -ne 0 ]]; then
            echo "File upload failed."
            return 1
        fi
    fi

    if [[ -z "$file_url" ]]; then
        echo "Error: No file URL provided."
        echo "Usage: transcribe -f <file_path> or transcribe <file_url>"
        return 1
    fi

    # Encode the file URL to handle spaces
    encoded_url=$(echo "$file_url" | sed 's/ /%20/g')

    curl -s --request POST \
        --url https://fal.run/fal-ai/wizper \
        --header "Authorization: Key $FAL_KEY" \
        --header "Content-Type: application/json" \
        --data '{
            "audio_url": "'"$encoded_url"'",
            "language": "en",
            "version": "3",
            "task": "transcribe"
        }' | jq .text -r
}

# zeoxide initialization and iterm2 integration
eval "$(zoxide init --cmd cd zsh)"
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

export OPENAI_API_KEY=sk-proj-VeISYv7YFEsAzvNhaQ2TT3BlbkFJACrbPEyftCDoAXp1d1nX
export OPENROUTER_API_KEY=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
export FIREWORKS_API_KEY=YRqCJ77HbMkgVsArvHqD2G6nyqoJFqDlq640lXSFtN8SvcKG
export PPLX_API_KEY=pplx-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
export GROQ_API_KEY=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
export MISTRAL_API_KEY=cgmiDdbUG1PNl1YF2nr0UrdDacZg2YAV
export DEEPSEEK_API_KEY=sk-fc598b820bba45d48968591ccc00764a
export TOGETHERAI_API_KEY=cf2be16d4bcc109c94d53eb228a7033bbd62861239b1ce57e55993756ca82c38
export LLAMA_CLOUD_API_KEY=llx-rCJtFrQd3ehoc7ofjFwAefQ1KQU7JpDQ5MBxCP7U3fHhYCim
export GEMINI_API_KEY=AIzaSyDhIwZkaJ0niXxSCftwewM__Bh1UDHFuv
export FAL_KEY=4d7b7a59-11c2-4d2e-85bb-1721a52df222:24976836119b9637eb3468f0eba02483


# syntax highlighting

source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
