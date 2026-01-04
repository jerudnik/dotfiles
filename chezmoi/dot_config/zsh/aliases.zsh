# Shell Aliases
# Managed by chezmoi

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# ls replacements (using eza)
alias ls="eza"
alias l="eza -la"
alias ll="eza -la"
alias la="eza -la"
alias lt="eza --tree --level=2"
alias lta="eza --tree --level=2 -a"

# Cat replacement (using bat)
alias cat="bat"

# Grep replacement (using ripgrep)
alias grep="rg"

# Find replacement (using fd)
alias find="fd"

# Nix shortcuts
alias rebuild="sudo darwin-rebuild switch --flake ~/Projects/dotfiles"
alias nix-clean="nix-collect-garbage -d"
alias nix-update="nix flake update ~/Projects/dotfiles"

# Git shortcuts
alias g="git"
alias gs="git status -sb"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias glog="git log --oneline -20"

# Directory shortcuts
alias dotfiles="cd ~/Projects/dotfiles"
alias projects="cd ~/Projects"

# Safety nets
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

# Misc
alias c="clear"
alias h="history"
alias path='echo $PATH | tr ":" "\n"'
alias week="date +%V"
alias myip="curl -s https://ifconfig.me"
