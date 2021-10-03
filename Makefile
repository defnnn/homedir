SHELL := /bin/bash

.PHONY: docs

first = $(word 1, $(subst --, ,$@))
second = $(word 2, $(subst --, ,$@))

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

list-all: # Update asdf plugin versions
	bin/runmany 4 'echo $$1; asdf list-all $$1 | sort > .tool-versions-$$1' consul packer vault kubectl kustomize helm king k3d k3sup terraform argo argocd python nodejs

config:
	-chmod 600 ssh/config
	-chmod 700 .gnupg

update_inner:
	if [[ ! -d .asdf ]]; then git clone https://github.com/asdf-vm/asdf.git .asdf; fi
	bin/runmany './env.sh asdf plugin-add $$1 || true' consul packer vault kubectl kustomize helm king k3d k3sup terraform argo argocd python nodejs
	mkdir -p .ssh && chmod 700 .ssh
	mkdir -p .gnupg && chmod 700 .gnupg
	mkdir -p .aws
	mkdir -p .docker
	(cat .docker/config.json 2>/dev/null || echo '{}') | jq -S '. + {credsStore: "pass", "credHelpers": { "docker.io": "pass" }}' > .docker/config.json.1
	mv .docker/config.json.1 .docker/config.json
	rm -f .profile

upgrade: # Upgrade installed software
	brew upgrade
	if [[ "$(shell uname -s)" == "Darwin" ]]; then brew upgrade --cask; fi
	. venv/bin/activate && pipx upgrade-all

install-aws:
	sudo yum install -y jq htop
	sudo yum install -y expat-devel readline-devel openssl-devel bzip2-devel sqlite-devel
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	cd .. && homedir/bin/install-homedir

setup-do:
	./env.sh $(MAKE) setup-do-inner

setup-do-inner:
	sudo mount -o defaults,nofail,discard,noatime /dev/disk/by-id/* /mnt
	for s in /swap0 /swap1 /swap2 /swap3; do \
		sudo fallocate -l 1G $$s; \
		sudo chmod 0600 $$s; \
		sudo mkswap $$s; \
		echo $$s swap swap defaults 0 0 | sudo tee -a /etc/fstab; \
	done
	while ! (test -e /dev/sda || test -e /dev/sdb); do date; sleep 5; done
	-sudo e2label /dev/sda mnt
	-sudo e2label /dev/sdb mnt
	echo LABEL=mnt /mnt ext4 defaults 0 0 | sudo tee -a /etc/fstab
	-sudo umount /mnt
	sudo mount /mnt
	sudo install -d -o 1000 -g 1000 /mnt/password-store /mnt/work
	ln -nfs /mnt/password-store .password-store
	ln -nfs /mnt/work work
	make update install

setup-aws:
	sudo perl -pe 's{^#\s*GatewayPorts .*}{GatewayPorts yes}' /etc/ssh/sshd_config | grep Gateway

install: # Install software bundles
	source ./.bash_profile && ( $(MAKE) install_inner || true )
	@bin/fig cleanup
	rm -f /home/linuxbrew/.linuxbrew/bin/perl

install_inner:
	$(MAKE) brew
	$(MAKE) asdf
	$(MAKE) python
	$(MAKE) pipx
	$(MAKE) misc

python:
	if test -w /usr/local/bin; then ln -nfs python3 /usr/local/bin/python; fi
	if test -w /home/linuxbrew/.linuxbrew/bin; then ln -nfs python3 /home/linuxbrew/.linuxbrew/bin/python; fi
	if ! venv/bin/python --version 2>/dev/null; then \
		rm -rf venv; bin/fig python; source ./.bash_profile && python3 -m venv venv && venv/bin/python bin/get-pip.py && venv/bin/python -m pip install --upgrade pip pip-tools pipx; fi

pipx:
	@bin/fig pipx
	if ! test -x venv/bin/pipx; then \
		./env.sh venv/bin/python -m pip install --upgrade pip pip-tools pipx; fi
	-bin/runmany 'venv/bin/python -m pipx install $$1' cookiecutter pre-commit yq keepercommander docker-compose black pylint flake8 isort pyinfra testinfra aws-sam-cli poetry solo-python ec2instanceconnectcli awscli flit
	-venv/bin/python -m pipx install --pip-args "httpie-aws-authv4" httpie
	-venv/bin/python -m pipx install --pip-args "tox-docker" tox
	-venv/bin/python -m pipx install --pip-args "ansible paramiko" ansible-core

asdf:
	if [[ "$(shell id -un)" != "cloudshell-user" ]]; then bin/fig asdf; ./env.sh asdf install; fi

brew:
	-if test -x "$(shell which brew)"; then bin/fig brew; brew bundle; fi

misc:
	@bin/fig misc
	~/env.sh $(MAKE) /usr/local/bin/pinentry-defn
	~/env.sh $(MAKE) .config/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator/SopsSecretGenerator
	~/env.sh $(MAKE) bin/docker-credential-pass
	~/env.sh $(MAKE) /usr/local/bin/pass-vault-helper

.config/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator/SopsSecretGenerator:
	@bin/fig sops
	mkdir -p .config/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator
	curl -o .config/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator/SopsSecretGenerator -sSL https://github.com/goabout/kustomize-sopssecretgenerator/releases/download/v1.3.2/SopsSecretGenerator_1.3.2_$(shell uname -s | tr '[:upper:]' '[:lower:]')_amd64
	-chmod 755 .config/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator/SopsSecretGenerator

/usr/local/bin/pinentry-defn:
	@bin/fig pinentry
	if [[ -w /usr/local/bin ]]; then \
		ln -nfs "$(HOME)/bin/pinentry-defn" /usr/local/bin/pinentry-defn; \
	else \
		sudo ln -nfs "$(HOME)/bin/pinentry-defn" /usr/local/bin/pinentry-defn; fi

bin/docker-credential-pass:
	@bin/fig pass-docker
	go mod init github.com/amanibhavam/homedir
	go get github.com/jojomomojo/docker-credential-helpers/pass/cmd@v0.6.5
	go build -o bin/docker-credential-pass github.com/jojomomojo/docker-credential-helpers/pass/cmd

/usr/local/bin/pass-vault-helper:
	@bin/fig pass-vault
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

bash:
	cd c && docker-compose exec home bash -il

ssh:
	ssh -A -p 2222 -o StrictHostKeyChecking=no app@localhost

tilt:
	cp .ssh/authorized_keys k/
	tilt up -n defn

up:
	cd c && docker-compose up -d --remove-orphans

down:
	cd c && docker-compose down --remove-orphans

recreate:
	$(MAKE) down
	-ssh-keygen -R '[localhost]:2222'
	$(MAKE) up

recycle:
	$(MAKE) pull
	$(MAKE) recreate

tail:
	cd c && docker-compose logs -f

shim:
	ln -nfs "$(shell asdf which kubectl)" bin/site/
	ln -nfs "$(shell asdf which kustomize)" bin/site/
	ln -nfs "$(shell asdf which argocd)" bin/site/
	ln -nfs "$(shell asdf which argo)" bin/site/
	ln -nfs "$(shell asdf which k3sup)" bin/site/
	ln -nfs "$(shell asdf which helm)" bin/site/
	ln -nfs "$(shell asdf which python)" bin/site/
	ln -nfs "$(shell asdf which node)" bin/site/

rebuild: # Rebuild everything from scratch
	$(MAKE) build--base push--base build=--no-cache
	$(MAKE) build--brew push--brew build=--no-cache
	$(MAKE) build--home push--home build=--no-cache

home: b/.tool-versions
	date > b/index-homedir
	$(MAKE) build--home push--home

b/.tool-versions: .password-store/.tool-versions
	rsync -ia .password-store/.tool-versions $@

push--%:
	docker push k3d-hub.defn.ooo:5000/defn/home:$(second)

build--%:
	docker build $(build) -t k3d-hub.defn.ooo:5000/defn/home:$(second) \
		--build-arg HOMEBOOT=app \
		--build-arg HOMEUSER=app \
		--build-arg HOMEDIR=https://github.com/amanibhavam/homedir \
		-f b/Dockerfile.$(second) \
		b
