if [[ -f ~/.env ]]; then set -a; source ~/.env; set +a; fi
if [[ -f ~/.bashrc.site ]]; then source ~/.bashrc.site; fi

function vm {
  docker run -it --rm -v "$HOME:$HOME" -w "$HOME" -e "HOME=$HOME" letfn/spacevim "$@"
}
