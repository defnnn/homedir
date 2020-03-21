export BASH_SILENCE_DEPRECATION_WARNING=1

export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"

export PATH="$HOME/.asdf/shims:/home/linuxbrew/.linuxbrew/bin:$PATH"

if [[ -f "$HOME/venv/bin/activate" ]]; then
  source "$HOME/venv/bin/activate"
fi

source "$HOME/.bashrc"
