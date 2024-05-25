# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "mafredri/zsh-async", from:github
zplug "zsh-users/zsh-autosuggestions", from:github
zplug load
# Install plugins if there are plugins that have not been installed
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

export OPENAI_API_KEY=sk-proj-VeISYv7YFEsAzvNhaQ2TT3BlbkFJACrbPEyftCDoAXp1d1nX
export OPENROUTER_API_KEY=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
export FIREWORKS_API_KEY=YRqCJ77HbMkgVsArvHqD2G6nyqoJFqDlq640lXSFtN8SvcKG
export PPLX_API_KEY=pplx-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
export GROQ_API_KEY=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
export MISTRAL_API_KEY=cgmiDdbUG1PNl1YF2nr0UrdDacZg2YAV
export DEEPSEEK_API_KEY=sk-fc598b820bba45d48968591ccc00764a
export TOGETHERAI_API_KEY=cf2be16d4bcc109c94d53eb228a7033bbd62861239b1ce57e55993756ca82c38
export LLAMA_CLOUD_API_KEY=llx-rCJtFrQd3ehoc7ofjFwAefQ1KQU7JpDQ5MBxCP7U3fHhYCim

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
alias ls="ls -lah --color=always"


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