export GPG_TTY="$(tty)"

export BASH_SILENCE_DEPRECATION_WARNING=1

if [[ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]]; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi

export PATH="$HOME/bin:$PATH:/usr/local/sbin:/sbin:/usr/sbin"

PATH="$HOME/.pyenv/shims:$HOME/.local/bin:/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/opt/java/bin:$PATH"

if [[ -f "$HOME/.asdf/asdf.sh" ]]; then source "$HOME/.asdf/asdf.sh"; fi
PATH="$HOME/.asdf/installs/bin:$PATH"

if [[ "$(uname -s)" = "Darwin" ]]; then
  PATH="$PATH:$HOME/bin/$(uname -s)"
fi

if [[ ! -f .env ]]; then
  ln -nfs .password-store/.env "$HOME/.env"
fi

source "$HOME/.bashrc"
