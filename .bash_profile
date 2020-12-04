export GPG_TTY="$(tty)"

export BASH_SILENCE_DEPRECATION_WARNING=1

if [[ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]]; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi

export PATH="$HOME/bin:$PATH:/usr/local/sbin:/sbin:/usr/sbin"

PATH="/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/opt/java/bin:$PATH"

if [[ -f "$HOME/.asdf/asdf.sh" ]]; then source "$HOME/.asdf/asdf.sh"; fi
PATH="$HOME/.asdf/installs/bin:$PATH"

if [[ "$(uname -s)" = "Darwin" ]]; then
  PATH="$PATH:$HOME/bin/$(uname -s)"
fi

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

if [[ ! -d "$HOME/.password-store/." && -d /efs/password-store ]]; then
  ln -nfs /efs/password-store "$HOME/.password-store"
fi

if [[ ! -f .env ]]; then
  ln -nfs .password-store/.env "$HOME/.env"
fi

source "$HOME/.bashrc"
