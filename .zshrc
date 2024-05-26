export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git)
source $ZSH/oh-my-zsh.sh



export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "mafredri/zsh-async", from:github
zplug "zsh-users/zsh-autosuggestions", from:github
zplug load

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi


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

# completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no




eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH=/opt/homebrew/bin:$PATH
export PATH="/usr/local/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH
export PATH="/Users/bartek/.local/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias runtokenizer='/Users/bartek/Scripts/Tokenizer/run_tokenizer.sh'
alias runwebdev='/Users/bartek/Scripts/Open-Web-Dev-Testing/openWebDevTest.sh'
alias runcopilot='/Users/bartek/Scripts/Text-Copilot/runTextCopilot.sh'
alias runpythondev='source /Users/bartek/Scripts/Python-Testing-Env/openPythonTest.sh'
alias runcopilot='source /Users/bartek/Scripts/Typing-Copilot/runTypingCopilot.sh'
alias runwhisper='source /Users/bartek/Scripts/Transcription/runTranscription.sh'
alias act='source bin/activate'
alias nq='networkQuality'
alias zshconfig="code ~/.zshrc"
alias reload="source ~/.zshrc"
alias la="eza -l --no-permissions --no-user"
alias gs='git status'
alias ga='git add'
alias gp='git push'
alias gc='git commit'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias cl='clear'

EZA_COLORS="di=34:ex=32:fi=0:sn=0:da=0"

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

eval "$(zoxide init --cmd cd zsh)"