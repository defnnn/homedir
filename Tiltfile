load('ext://uibutton', 'cmd_button', 'location')

analytics_settings(False)

k8s_yaml(kustomize('hello'))
k8s_yaml(kustomize('hello-test'))

k8s_resource('sshd', port_forwards=2222)

docker_build('defn-hello', 'hello')

docker_build('defn-sshd', 'k',
  live_update=[
    sync('k/.sync', '/home/app/k/.sync'),

    run('cd && rsync -ia k/.sync/.ssh/. .ssh/. || true'),
    run('cd && rsync -ia k/.sync/.docker/. .docker/. || true'),
    run('cd && rsync -ia k/.sync/.kube/. .kube/. >/dev/null || true'),
    run('cd && rsync -ia k/.sync/.password-store/. .password-store/. >/dev/null || true'),
    run('cd && env SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock make update || true')
  ]
)

cmd_button(name='rebuild',
           resource='sshd',
           argv=['make', 'home-update'])

cmd_button(name='full-sync',
           resource='sshd',
           argv=['make', 'tilt-sync'])

cmd_button(name='sync',
           resource='sshd',
           argv=['make', 'sync'])
