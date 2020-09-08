export GPG_TTY="$(tty)"

export BASH_SILENCE_DEPRECATION_WARNING=1

if [[ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]]; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi

export PATH="$HOME/bin:$HOME/.config/nvim/plugged/vim-iced/bin:$PATH:/usr/local/sbin:/sbin:/usr/sbin"
if [[ -d /home/linuxbrew/.linuxbrew/bin ]]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/opt/java/bin:$PATH"
fi

if [[ -f "$HOME/.asdf/asdf.sh" ]]; then source "$HOME/.asdf/asdf.sh"; fi
if [[ -d "$HOME/.asdf/installs/bin" ]]; then
  PATH="$HOME/.asdf/installs/bin:$PATH"
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
  ln -nfs /efs/pasword-store "$HOME/.password-store"
fi

if [[ ! -f .env ]]; then
  ln -nfs .password-store/.env "$HOME/.env"
fi

source "$HOME/.bashrc"
