chpasswd:
	kubectl -n argocd patch secret argocd-secret -p \
		'{"stringData": { "admin.password": "$$2a$$10$$3sQFra.ZmAz88EhVIxtd6uKBgxcLNYjKBR2SoPGV2ifqiG6.oMiqm", "admin.passwordMtime": "2021-08-29T20:01:0" }}'

deploy:
	kustomize build https://github.com/letfn/katt-argocd/base?ref=v0.0.15 | kubectl apply -f -
