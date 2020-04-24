set -efu;
unset TMUX; 
mkdir -p "${HOME}/.ssh"; 
ln -nfs "${SSH_AUTH_SOCK}" "${HOME}/.ssh/ssh_auth_sock"; 
export SSH_AUTH_SOCK="${HOME}/.ssh/ssh_auth_sock";
tmux new-session -d -s default || true;
tmux detach-client -s default || true;
exec tmux -CC -u attach -t default;
