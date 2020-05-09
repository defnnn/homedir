export GPG_TTY="$(tty)"

export BASH_SILENCE_DEPRECATION_WARNING=1

if [[ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]]; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi

export PATH="$HOME/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/opt/java/bin:$HOME/.config/nvim/plugged/vim-iced/bin:$PATH:$HOME/node_modules/.bin"

if [[ -f "$HOME/.asdf/asdf.sh" ]]; then source "$HOME/.asdf/asdf.sh"; fi

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
  if [[ -f "$HOME/venv/bin/activate" ]]; then
    source "$HOME/venv/bin/activate"
  fi
fi

case "$(uname -s)" in
  Darwin)
    true
    ;;
  *)
    if [[ -f "$HOME/venv/bin/activate" ]]; then
      source "$HOME/venv/bin/activate"
    fi
    ;;
esac

source "$HOME/.bashrc"
