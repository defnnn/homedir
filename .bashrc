ANSI_ESC=$'\033'
ANSI_CSI="${ANSI_ESC}["

function vi {
  if type -P vim >/dev/null; then
    command vim "$@"
  else
    command vi "$@"
  fi
}

function ws {
  if [[ "$#" == 0 ]]; then
    terraform workspace list | awk '{print $NF}' | grep -v default | sort
    return 0
  fi

  terraform workspace select "$@"
}

function gs {
  ~/bin/gs "$@"
}

function profile {
  if [[ "$#" == 0 ]]; then
    unset AWS_PROFILE AWS_DEFAULT_REGION AWS_REGION
    reset-aws
    return 0
  fi

  export AWS_PROFILE="$1"
  export AWS_METADATA_URL=http://lol.lol # until everything is on Terraform 0.13

  if [[ -n "${2:-}" ]]; then
    export AWS_DEFAULT_REGION="$2"
    export AWS_REGION="$2"
  else
    local region="$(unset AWS_DEFAULT_REGION AWS_REGION; aws configure --profile "${AWS_PROFILE}" get region)"
    if [[ -n "${region}" ]]; then
      export AWS_REGION="${region}" AWS_DEFAULT_REGION="${region}"
    else
      region="$(unset AWS_DEFAULT_REGION AWS_REGION; aws configure --profile "default" get region)"
      if [[ -n "${region}" ]]; then
        export AWS_REGION="${region}" AWS_DEFAULT_REGION="${region}"
      fi
    fi
  fi

  reset-aws
}

function renew {
  if [[ "$#" -gt 0 ]]; then
    profile "$1"
    shift
  fi

  eval $(
    $(aws configure get credential_process) | jq -r '"export AWS_ACCESS_KEY_ID=\(.AccessKeyId) AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey) AWS_SESSION_TOKEN=\(.SessionToken)"'
  )

  local region="$(unset AWS_DEFAULT_REGION AWS_REGION; aws configure --profile "${AWS_PROFILE}" get region)"
  if [[ -n "${region}" ]]; then
    export AWS_REGION="${region}" AWS_DEFAULT_REGION="${region}"
  else
    region="$(unset AWS_DEFAULT_REGION AWS_REGION; aws configure --profile "default" get region)"
    if [[ -n "${region}" ]]; then
      export AWS_REGION="${region}" AWS_DEFAULT_REGION="${region}"
    fi
  fi

  if [[ "$#" -gt 0 ]]; then
   "$@"
  fi
}

function reset-aws {
  unset \
    AWS_ACCESS_KEY_ID \
    AWS_OKTA_ASSUMED_ROLE \
    AWS_OKTA_ASSUMED_ROLE_ARN \
    AWS_OKTA_PROFILE \
    AWS_OKTA_SESSION_EXPIRATION \
    AWS_SECRET_ACCESS_KEY \
    AWS_SECURITY_TOKEN \
    AWS_SESSION_TOKEN
}

function reload {
  pushd ~ > /dev/null
  source ./.bash_profile
  popd > /dev/null

  for a in "$@"; do
    "reload-$a"
  done

  if [[ "$#" -gt 0 ]]; then
    if [[ "${SSH_AUTH_SOCK}" =~ gpg ]]; then 
      true
    else
      reload gpg 
      pushd ~ > /dev/null
      source ./.bash_profile
      popd > /dev/null
    fi
  else
    pushd ~ > /dev/null
    source ./.bash_profile
    popd > /dev/null
  fi
}

function reload-gpg {
  env GPG_TTY=$(tty) gpg-connect-agent updatestartuptty /bye >/dev/null
  gpg --card-status
}

function adjust_ps1 {
  perl -pe 's{(\\\$)([^\$]+?)$}{$1$2}s'
}

function expired {
  time_left=
  if [[ -n "${AWS_OKTA_SESSION_EXPIRATION:-}" ]]; then
    time_left="$(( AWS_OKTA_SESSION_EXPIRATION - $(date +%s) ))"
    if [[ "${time_left}" -lt 0 ]]; then
      return 0
    fi
  fi

  return 1
}

function render_ps1 {
  local ec="$?"

  export PS1_VAR=

  local nm_profile="${AWS_PROFILE}"
  if [[ -n "${nm_profile}" ]]; then
    if [[ -n "${AWS_OKTA_SESSION_EXPIRATION:-}" ]]; then
      PS1_VAR="${PS1_VAR:+${PS1_VAR}}@${nm_profile}${time_left:+ ${time_left}}"
    else
      PS1_VAR="${PS1_VAR:+${PS1_VAR}}@${nm_profile}"
    fi

    if [[ -n "${AWS_REGION:-}" ]]; then
      PS1_VAR="${PS1_VAR:+${PS1_VAR}} ${AWS_REGION}"
    fi
  fi

  if [[ -n "${TMUX_PANE:-}" ]]; then
    PS1_VAR="${TMUX_PANE}${PS1_VAR:+ ${PS1_VAR}}"
  fi

  if [[ -f ".terraform/environment" ]]; then
    PS1_VAR="_$(cat .terraform/environment)_${PS1_VAR:+ ${PS1_VAR}}"
  fi

  PS1_VAR="${PS1_VAR} $(printf '%s49m' "$ANSI_CSI")"

  echo
  powerline-go -error "$ec" --colorize-hostname -mode flat -newline \
    -priority root,cwd,user,host,ssh,perms,git-branch,exit,cwd-path,git-status \
    -modules host,ssh,cwd,perms,gitlite,load,exit${PS1_VAR:+,shell-var --shell-var PS1_VAR} \
    -path-aliases /home/boot=\~,\~/work=work \
    -theme ~/default.json
}

function update_ps1 {
  if expired; then
    reset-aws
  fi
  PS1="$(render_ps1)"
}

function do-env {
  for a in DIGITALOCEAN_{ACCESS_TOKEN,TOKEN,API_TOKEN}; do export $a=$(pass digitalocean/$a); done
}

function cf-env {
  for a in CLOUDFLARE_{DNS_API_TOKEN,ZONE_API_TOKEN,API_TOKEN}; do export $a=$(pass cloudflare/$a); done
}

function py-env {
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  eval "$(pyenv init -)"
}

if tty >/dev/null; then
  if type -P powerline-go >/dev/null; then
    PROMPT_COMMAND="update_ps1"
  fi
fi

#export AWS_OKTA_MFA_PROVIDER=YUBICO
export AWS_OKTA_MFA_PROVIDER=OKTA
#AWS_OKTA_MFA_FACTOR_TYPE=token:hardware
export AWS_OKTA_MFA_FACTOR_TYPE=push

export AWS_SDK_LOAD_CONFIG=1

if [[ -f /etc/aws.env ]]; then
  set -a
  source /etc/aws.env
  set +a
fi

export CHECKPOINT_DISABLE=1
export NODEJS_CHECK_SIGNATURES=no
export SAM_CLI_TELEMETRY=0

export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

export KUBECTX_IGNORE_FZF=1

if [[ -n "${TMUX:-}" ]]; then
  TERM=tmux-256color
else
  TERM=xterm-256color
fi
export TERM
export TERM_PROGRAM=iTerm.app
export BAT_THEME="Monokai Extended"

export LC_COLLATE=C
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
unset LC_ALL

unset GPG_TTY

export AWS_VAULT_BACKEND=pass
export AWS_VAULT_PASS_PASSWORD_STORE_DIR="$HOME/k/.sync/.aws-vault"
export AWS_VAULT_PASS_CMD=pass
export AWS_VAULT_PASS_PREFIX=aws-vault
export PASS_OATH_CREDENTIAL_NAME=aws-vault/totp
export CHAMBER_KMS_KEY_ALIAS=alias/aws/ssm

export PIP_REQUIRE_VIRTUALENV=1

if type -P vim >/dev/null; then
  export EDITOR="$(which vim)"
else
  export EDITOR="$(which vi)"
fi

if [[ -f ~/.bashrc.site ]]; then source ~/.bashrc.site; fi
