SHELL := /bin/bash

.PHONY: docs

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile

thing: # Upgrade all the things
	./env.sh $(MAKE) thing-inner

thing-inner:
	-$(MAKE) update
	$(MAKE) update
	$(MAKE) install
	$(MAKE) upgrade

update: # Update code
	git pull
	-chmod 600 .ssh/config .password-store/ssh/config
	$(MAKE) update_inner

update_password_store:
	cd .password-store && git reset --hard origin/master
	-chmod 600 .ssh/config .password-store/ssh/config
	cd .password-store && git pull
	-chmod 600 .ssh/config .password-store/ssh/config

update_inner:
	if [[ ! -d .asdf/.git ]]; then git clone https://github.com/asdf-vm/asdf.git asdf; mv asdf/.git .asdf/; rm -rf asdf; cd .asdf && git reset --hard; fi
	git submodule update --init
	if [[ -f /cache/.npmrc ]]; then ln -nfs /cache/.npmrc .; fi
	if [[ -f /efs/.npmrc ]]; then ln -nfs /efs/.npmrc .; fi
	if [[ -f /cache/.pip/pip.conf ]]; then mkdir -p .pip; ln -nfs /cache/.pip/pip.conf .pip/; fi
	if [[ -f /efs/.pip/pip.conf ]]; then mkdir -p .pip; ln -nfs /efs/.pip/pip.conf .pip/; fi
	if [[ -f /efs/.gitconfig ]]; then cp /efs/.gitconfig .gitconfig; fi
	mkdir -p .ssh && chmod 700 .ssh
	mkdir -p .gnupg && chmod 700 .gnupg
	mkdir -p .aws
	mkdir -p .docker
	(cat .docker/config.json 2>/dev/null || echo '{}') | jq -S '. + {credsStore: "pass"}' > .docker/config.json.1
	mv .docker/config.json.1 .docker/config.json
	rm -f .profile

upgrade: # Upgrade installed software
	brew upgrade
	if [[ "$(shell uname -s)" == "Linux" ]]; then brew upgrade --cask; fi

brew:
	 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash -

install-aws:
	sudo yum install -y jq htop
	sudo yum install -y expat-devel readline-devel openssl-devel bzip2-devel sqlite-devel
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	cd .. && homedir/bin/install-homedir

setup-do:
	./env.sh $(MAKE) setup-do-inner

setup-do-inner:
	sudo mount -o defaults,nofail,discard,noatime /dev/disk/by-id/* /mnt
	for s in /swap0 /swap1 /swap2 /swap3; do sudo fallocate -l 1G $$s; sudo chmod 0600 $$s; sudo mkswap $$s || true; sudo swapon $$s || true; done
	while ! test -e /dev/sda; do date; sleep 5; done
	sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	rm -f .ssh/authorized_keys; touch .ssh/authorized_keys; chmod 700 .ssh; chmod 600 .ssh/authorized_keys
	curl -s "https://api.github.com/users/dgwyn/keys" | jq -r '.[].key' >> .ssh/authorized_keys
	curl -s "https://api.github.com/users/jojomomojo/keys" | jq -r '.[].key' >> .ssh/authorized_keys
	sudo install -d -o 1000 -g 1000 /mnt/password-store /mnt/work
	ln -nfs /mnt/password-store .password-store
	ln -nfs /mnt/work work
	git submodule sync
	git submodule update --init --recursive --remote
	make setup-dummy
	make update
	if [[ -d /mnt/tailscale ]]; then sudo systemctl stop tailscaled; sudo rm -rf /var/lib/tailscale; sudo rsync -ia /mnt/tailscale /var/lib/; sudo systemctl start tailscaled; fi
	sleep 30
	if [[ -d work/cilium ]]; then cd work/cilium; ~/env make up; fi

setup-aws:
	sudo perl -pe 's{^#\s*GatewayPorts .*}{GatewayPorts yes}' /etc/ssh/sshd_config | grep Gateway

setup-dummy:
	bin/setup-dummy

setup-registry:
	docker run -d -p 5000:5000 --restart=always --name registry registry:2

install: # Install software bundles
	source ./.bash_profile && ( $(MAKE) install_inner || true )
	-chmod 600 .ssh/config .password-store/ssh/config

install_inner:
	if test -w /usr/local/bin; then ln -nfs python3 /usr/local/bin/python; fi
	if test -w /home/linuxbrew/.linuxbrew/bin; then ln -nfs python3 /home/linuxbrew/.linuxbrew/bin/python; fi
	-if test -x "$(shell which brew)"; then brew bundle && rm -rf $(shell brew --cache) 2>/dev/null; fi
	source ./.bash_profile && asdf install
	if ! venv/bin/python --version; then rm -rf venv; source ./.bash_profile && python3 -m venv venv; fi
	source venv/bin/activate && pip install --upgrade pip
	source venv/bin/activate && pip install --no-cache-dir -r requirements.txt
	if ! test -x "$(HOME)/bin/docker-credential-pass"; then go get github.com/jojomomojo/docker-credential-helpers/pass/cmd@v0.6.5; go build -o bin/docker-credential-pass github.com/jojomomojo/docker-credential-helpers/pass/cmd; fi
	if [[ -w /usr/local/bin ]]; then ln -nfs ~/bin/pass-vault-helper ~/bin/pinentry-defn /usr/local/bin/; else sudo ln -nfs ~/bin/pass-vault-helper ~/bin/pinentry-defn /usr/local/bin/; fi
	if [[ ! -e /usr/local/bin/pass-vault-helper ]]; then \
		if [[ -x "$(HOME)/bin/pass-vault-helper" ]]; then \
			if [[ -w /usr/local/bin ]]; then \
				ln -nfs "$(HOME)/bin/pass-vault-helper" /usr/local/bin/pass-vault-helper \
			else \
				sudo ln -nfs "$(HOME)/bin/pass-vault-helper" /usr/local/bin/pass-vault-helper; \
			fi \
		fi; \
	fi
	mkdir -p "$(HOME)/.config/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator"
	if ! test -f "$(HOME)/.config/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator"; then curl -o "$(HOME)/.config/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator/SopsSecretGenerator" -sSL https://github.com/goabout/kustomize-sopssecretgenerator/releases/download/v1.3.2/SopsSecretGenerator_1.3.2_$(shell uname -s | tr '[:upper:]' '[:lower:]')_amd64; fi
	-chmod 755 "$(HOME)/.config/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator/SopsSecretGenerator"
	rm -rf $(shell brew --cache) 2>/dev/null || sudo rm -rf $(shell brew --cache)
	rm -f /home/linuxbrew/.linuxbrew/bin/perl

fmt: # Format with isort, black
	@echo
	drone exec --pipeline $@

lint: # Run drone lint
	@echo
	drone exec --pipeline $@

docs: # Build docs
	@echo
	drone exec --pipeline $@

requirements: # Compile requirements
	@echo
	drone exec --pipeline $@

test:
	 env PYTEST_ADDOPTS='--keep-cluster --cluster-name=test' pytest -v -s test.py
