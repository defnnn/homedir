# -*- mode: Python -*

analytics_settings(False)

k8s_yaml(kustomize('k'))

k8s_resource('sshd', port_forwards=2222)

docker_build('defn-sshd', 'k',
  live_update=[
    sync('k/.sync', '/home/app/k/.sync'),

    run('make update || make update'),
    run('cd && rsync -ia k/.sync/authorized_keys .ssh/ >/dev/null', 'k/.sync/authorized_keys'),
    run('cd && rsync -ia k/.sync/.password-store/. .password-store/. >/dev/null', 'k/.sync/.password-store'),
    run('cd && rsync -ia k/.sync/.kube/. .kube/. >/dev/null', 'k/.sync/.kube'),
    run('cd && rsync -ia k/.sync/.docker/. .kube/. >/dev/null', 'k/.sync/.docker'),
  ]
)
