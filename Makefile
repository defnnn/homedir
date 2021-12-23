SHELL := /bin/bash

.PHONY: docs

first = $(word 1, $(subst --, ,$@))
second = $(word 2, $(subst --, ,$@))

first_ = $(word 1, $(subst _, ,$@))
second_ = $(word 2, $(subst _, ,$@))

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile

latest: # Upgrade to the latest
	-$(MAKE) update
	$(MAKE) update
	$(MAKE) latest_inner

latest_inner:
	$(MAKE) upgrade install

rebuild-python:
	rm -rf venv .local/pipx
	$(MAKE) penv
	$(MAKE) pipx

update: # Update code
	git pull
	$(MAKE) config
	$(MAKE) update_inner

config:
	-chmod 700 .ssh
	-chmod 600 .ssh/config
	-chmod 700 .gnupg

bootstrap:
	./env.sh $(MAKE) bootstrap_inner

bootstrap_inner:
	$(MAKE) update
	$(MAKE) install-password-store
	$(MAKE) install-powerline
	$(MAKE) install-asdf
	-$(MAKE) install-asdf-plugin
	$(MAKE) install-python
	$(MAKE) rebuild-python
	$(MAKE) latest
	sudo apt update
	sudo apt upgrade -y
	sync

katt:
	cd /mnt/work/katt/dev && ~/env.sh c reset
	cd /mnt/work/katt/dev && ~/env.sh c install

katt-golang:
	cd /mnt/work/dev/k/golang && ~/env.sh c apply

install-password-store:
	ln -nfs /mnt/.password-store .

install-vim:
	vim +'PlugInstall --sync' +qa

install-powerline:
	curl -sSL -o bin/powerline-go https://github.com/justjanne/powerline-go/releases/download/v1.21.0/powerline-go-linux-amd64
	chmod 755 bin/powerline-go

install-asdf:
	if [[ ! -d .asdf ]]; then git clone https://github.com/asdf-vm/asdf.git .asdf; fi
	if [[ ! -f .tool-versions ]]; then sudo install -d -o $$(id -un) -g $$(id -gn) -m 0700 /mnt/.password-store; cp .tool-versions.example /mnt/.password-store/.tool-versions; fi

install-asdf-plugin:
	bin/runmany './env.sh asdf plugin-add $$1' cue doctl golang helm k3sup k9s kubectl kubectx kustomize nodejs python tilt

install-python:
	sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libsqlite3-dev libncurses5-dev libncursesw5-dev libffi-dev liblzma-dev libreadline-dev
	-./env.sh asdf install python

update_inner:
	mkdir -p .ssh && chmod 700 .ssh
	mkdir -p .gnupg && chmod 700 .gnupg
	mkdir -p .aws
	mkdir -p .docker
	rm -f .profile

upgrade: # Upgrade installed software
	. venv/bin/activate && pipx upgrade-all

install: # Install software bundles
	source ./.bash_profile && ( $(MAKE) install_inner || true )

install_inner:
	asdf install
	$(MAKE) pipx
	$(MAKE) misc

penv:
	if ! venv/bin/python --version 2>/dev/null; then \
		rm -rf venv; source ./.bash_profile && python3 -m venv venv && venv/bin/python -m pip install --upgrade pip pip-tools pipx; fi

pipx: penv
	-bin/runmany 'venv/bin/python -m pipx install $$1' pre-commit yq awscli
	-venv/bin/python -m pipx install --pip-args "httpie-aws-authv4" httpie

misc:
	~/env.sh $(MAKE) /usr/local/bin/pinentry-defn
	~/env.sh $(MAKE) /usr/local/bin/pass-vault-helper

/usr/local/bin/pinentry-defn:
	if [[ -w /usr/local/bin ]]; then \
		ln -nfs "$(HOME)/bin/pinentry-defn" /usr/local/bin/pinentry-defn; \
	else \
		sudo ln -nfs "$(HOME)/bin/pinentry-defn" /usr/local/bin/pinentry-defn; fi

/usr/local/bin/pass-vault-helper:
	if [[ -w /usr/local/bin ]]; then \
		ln -nfs "$(HOME)/bin/pass-vault-helper" /usr/local/bin/pass-vault-helper; \
	else \
		sudo ln -nfs "$(HOME)/bin/pass-vault-helper" /usr/local/bin/pass-vault-helper; fi

shim:
	ln -nfs "$(shell ./env.sh asdf which cue)" bin/site/
	ln -nfs "$(shell ./env.sh asdf which kubectl)" bin/site/
	ln -nfs "$(shell ./env.sh asdf which kustomize)" bin/site/
	ln -nfs "$(shell ./env.sh asdf which k3sup)" bin/site/
	ln -nfs "$(shell ./env.sh asdf which helm)" bin/site/
	ln -nfs "$(shell ./env.sh asdf which kubectx)" bin/site/
	ln -nfs "$(shell ./env.sh asdf which kubens)" bin/site/
	ln -nfs "$(shell ./env.sh asdf which k9s)" bin/site/
	ln -nfs "$(shell ./env.sh asdf which python)" bin/site/
	ln -nfs "$(shell ./env.sh asdf which node)" bin/site/
	ln -nfs "$(shell ./env.sh asdf which go)" bin/site/
	ln -nfs "$(shell ./env.sh asdf which gofmt)" bin/site/

.vim/autoload/plug.vim:
	curl -fsSLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
