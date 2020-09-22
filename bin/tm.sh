set -efu;
unset TMUX; 
mkdir -p "${HOME}/.ssh"; 
ln -nfs "${SSH_AUTH_SOCK}" "${HOME}/.ssh/ssh_auth_sock"; 
export SSH_AUTH_SOCK="${HOME}/.ssh/ssh_auth_sock";
pth_gpg_agent="$(gpgconf --list-dirs | grep agent-socket: | cut -d: -f2-)"
if [[ "$pth_gpg_agent" != "$HOME/.gnupg/S.gpg-agent" ]]; then ln -nfs $HOME/.gnupg/S.gpg-agent "$pth_gpg_agent"; fi;
pth_tmux="$(which /home/linuxbrew/.linuxbrew/bin/tmux tmux | head -1)";
"$pth_tmux" new-session -d -s default || true;
"$pth_tmux" detach-client -s default || true;
exec "$pth_tmux" -CC -u attach -t default;
