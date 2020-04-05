export GPG_TTY="$(tty)"

export BASH_SILENCE_DEPRECATION_WARNING=1

if [[ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]]; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi

export PATH="$HOME/bin:/home/linuxbrew/.linuxbrew/bin:$PATH"

if [[ -f "$HOME/.asdf/asdf.sh" ]]; then source "$HOME/.asdf/asdf.sh"; fi

if [[ -f "$HOME/venv/bin/activate" ]]; then
  source "$HOME/venv/bin/activate"
fi

source "$HOME/.bashrc"
