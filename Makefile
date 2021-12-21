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
	$(MAKE) python
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
	$(MAKE) update
	$(MAKE) install-asdf
	-$(MAKE) install-asdf-plugin
	$(MAKE) install-python
	$(MAKE) rebuild-python

install-asdf:
	if [[ ! -d .asdf ]]; then git clone https://github.com/asdf-vm/asdf.git .asdf; fi

install-asdf-plugin:
	bin/runmany './env.sh asdf plugin-add $$1' argo argocd cue doctl golang helm k3sup k9s kubectl kubectx kustomize nodejs python terraform tilt

install-python: install-asdf
	sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libsqlite3-dev libncurses5-dev libncursesw5-dev libffi-dev liblzma-dev libreadline-dev
	./env.sh asdf install python

update_inner:
	mkdir -p .ssh && chmod 700 .ssh
	mkdir -p .gnupg && chmod 700 .gnupg
	mkdir -p .aws
	mkdir -p .docker
	rm -f .profile

upgrade: # Upgrade installed software
	brew upgrade
	if [[ "$(shell uname -s)" == "Darwin" ]]; then brew upgrade --cask; fi
	. venv/bin/activate && pipx upgrade-all

install: # Install software bundles
	source ./.bash_profile && ( $(MAKE) install_inner || true )
	rm -f /home/linuxbrew/.linuxbrew/bin/perl

install_inner:
	$(MAKE) brew
	asdf install
	$(MAKE) python
	$(MAKE) pipx
	$(MAKE) misc

python:
	if test -w /usr/local/bin; then ln -nfs python3 /usr/local/bin/python; fi
	if test -w /home/linuxbrew/.linuxbrew/bin; then ln -nfs python3 /home/linuxbrew/.linuxbrew/bin/python; fi
	if ! venv/bin/python --version 2>/dev/null; then \
		rm -rf venv; source ./.bash_profile && python3 -m venv venv && venv/bin/python -m pip install --upgrade pip pip-tools pipx; fi

pipx:
	if ! test -x venv/bin/pipx; then \
		./env.sh venv/bin/python -m pip install --upgrade pip pip-tools pipx; fi
	-bin/runmany 'venv/bin/python -m pipx install $$1' pre-commit yq keepercommander pyinfra testinfra solo-python ec2instanceconnectcli awscli
	-venv/bin/python -m pipx install --pip-args "httpie-aws-authv4" httpie

brew:
	-if test -x "$(shell which brew)"; then brew bundle; fi

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

homebrew:
	 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash -

new:
	sudo mkdir -p /home/linuxbrew
	-sudo mount /home/linuxbrew
	-sudo mount /mnt
	ln -nfs /mnt/work ~/
	ln -nfs /mnt/.password-store ~/
	./bin/install-homedir
	sudo mkdir -p /usr/local/bin
	sudo ln -nfs /home/linuxbrew/.linuxbrew/bin/git-crypt /usr/local/bin/

shim:
	ln -nfs "$(shell asdf which cue)" bin/site/
	ln -nfs "$(shell asdf which kubectl)" bin/site/
	ln -nfs "$(shell asdf which kustomize)" bin/site/
	ln -nfs "$(shell asdf which argocd)" bin/site/
	ln -nfs "$(shell asdf which argo)" bin/site/
	ln -nfs "$(shell asdf which k3sup)" bin/site/
	ln -nfs "$(shell asdf which helm)" bin/site/
	ln -nfs "$(shell asdf which kubectx)" bin/site/
	ln -nfs "$(shell asdf which kubens)" bin/site/
	ln -nfs "$(shell asdf which k9s)" bin/site/
	ln -nfs "$(shell asdf which python)" bin/site/
	ln -nfs "$(shell asdf which node)" bin/site/
	ln -nfs "$(shell asdf which go)" bin/site/
	ln -nfs "$(shell asdf which gofmt)" bin/site/

thing:
	-$(MAKE) update
	$(MAKE) update
	-$(MAKE) upgrade
	$(MAKE) upgrade
	$(MAKE) install

.vim/autoload/plug.vim:
	curl -fsSLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
