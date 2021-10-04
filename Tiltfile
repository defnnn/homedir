# -*- mode: Python -*

analytics_settings(False)

k8s_yaml(kustomize('k'))

k8s_resource('sshd', port_forwards=2222)

docker_build('defn-sshd', 'k',
  live_update=[
    sync('k/.sync', '/home/app/k/.sync'),

    run('cd && rsync -ia k/.sync/.ssh/. .ssh/. >/dev/null'),
    run('cd && rsync -ia k/.sync/.password-store/. .password-store/. >/dev/null'),
    run('cd && rsync -ia k/.sync/.kube/. .kube/. >/dev/null'),
    run('cd && rsync -ia k/.sync/.docker/. .docker/. >/dev/null'),
  ]
)
