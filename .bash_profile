export GPG_TTY="$(tty)"

export BASH_SILENCE_DEPRECATION_WARNING=1

if [[ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]]; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi

export PATH="$HOME/bin:$HOME/.local/bin:$PATH:/usr/local/sbin:/sbin:/usr/sbin"

if [[ -f "$HOME/.asdf/asdf.sh" ]]; then source "$HOME/.asdf/asdf.sh"; fi

PATH="$HOME/bin/site:$PATH"

if [[ "$(uname -s)" = "Darwin" ]]; then
  PATH="$PATH:$HOME/bin/$(uname -s)"
fi

source "$HOME/.bashrc"
