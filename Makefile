SHELL := /bin/bash

.PHONY: docs

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile

thing: # Upgrade all the things
	$(MAKE) update
	$(MAKE) update
	$(MAKE) install

update: # Update code
	git pull
	$(MAKE) update_inner
	source ./.bash_profile && $(MAKE) -f .dotfiles/Makefile upgrade

update_inner:
	if [[ ! -d .asdf/.git ]]; then git clone https://github.com/asdf-vm/asdf.git asdf; mv asdf/.git .asdf/; rm -rf asdf; cd .asdf && git reset --hard; fi
	git submodule update --init
	if [[ ! -d .dotfiles ]]; then git clone "$(shell cat .dotfiles-repo)" .dotfiles; fi
	cd .dotfiles && git pull && git submodule update --init
	$(MAKE) -f .dotfiles/Makefile update

upgrade: # Upgrade installed software
	brew upgrade
	if [[ "$(shell uname -s)" == "Linux" ]]; then brew upgrade --cask; fi

brew:
	 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash -

install-aws:
	sudo yum install -y jq htop
	sudo yum install -y expat-devel readline-devel openssl-devel bzip2-devel sqlite-devel
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	rm -f /home/linuxbrew/.linuxbrew/bin/gs
	cd .. && homedir/bin/install-homedir

setup-aws:
	sudo perl -pe 's{^#\s*GatewayPorts .*}{GatewayPorts yes}' /etc/ssh/sshd_config | grep Gateway

install: # Install software bundles
	source ./.bash_profile && ( $(MAKE) install_inner || true )
	rm -f /home/linuxbrew/.linuxbrew/bin/gs

install_inner:
	-if test -x "$(shell which brew)"; then brew bundle && rm -rf $(shell brew --cache); fi
	source ./.bash_profile && asdf install
	if ! test -f venv/bin/activate; then rm -rf venv; source ./.bash_profile && python3 -m venv venv; fi
	source venv/bin/activate && pip install --upgrade pip
	source venv/bin/activate && pip install --no-cache-dir -r requirements.txt
	if ! test -f venv-aws-sam-cli/bin/activate; then source ./.bash_profile && python3 -m venv venv-aws-sam-cli; source venv-aws-sam-cli/bin/activate && pip install --upgrade aws-sam-cli; ln -nfs ../venv-aws-sam-cli/bin/sam bin/sam; fi
	go get github.com/jojomomojo/docker-credential-helpers/pass/cmd@v0.6.5
	go build -o bin/docker-credential-pass github.com/jojomomojo/docker-credential-helpers/pass/cmd
	source ./.bash_profile && $(MAKE) -f .dotfiles/Makefile install
	rm -rf .cache/Homebrew || sudo rm -rf .cache/Homebrew
	rm -f /home/linuxbrew/.linuxbrew/bin/perl
	./env npm install
	npm install -g npm

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
