set -efu;
unset TMUX; 
mkdir -p "${HOME}/.ssh"; 
ln -nfs "${SSH_AUTH_SOCK}" "${HOME}/.ssh/ssh_auth_sock"; 
export SSH_AUTH_SOCK="${HOME}/.ssh/ssh_auth_sock";
pth_tmux="$(which tmux | head -1)";
"$pth_tmux" new-session -d -s default || true;
"$pth_tmux" detach-client -s default || true;
exec "$pth_tmux" -CC -u attach -t default;
