# -*- mode: Python -*

analytics_settings(False)

k8s_yaml(kustomize('k'))

k8s_resource('sshd', port_forwards=2222)

docker_build('defn-sshd', 'k', build_args={},
  live_update=[
    sync('k/authorized_keys', '/home/app/.ssh/authorized_keys'),
])
