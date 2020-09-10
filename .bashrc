if [[ -f ~/.env ]]; then set -a; source ~/.env; set +a; fi
if [[ -f /efs/.env ]]; then set -a; source /efs/.env; set +a; fi
if [[ -f ~/.bashrc.site ]]; then source ~/.bashrc.site; fi
