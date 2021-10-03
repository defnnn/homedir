# -*- mode: Python -*

analytics_settings(False)

k8s_yaml(kustomize('k'))

k8s_resource('sshd', port_forwards=2222)

docker_build('defn-sshd', 'k',
  live_update=[
    sync('k/.sync', '/home/app/.sync'),

    run('cd && rsync -ia .sync/authorized_keys /home/app/.ssh/ >/dev/null', 'k/.sync'),
    run('cd && rsync -ia .sync/.password-store/. /home/app/.password-store/. >/dev/null', 'k/.sync'),
    run('cd && rm -rf .sync'),
  ]
)
