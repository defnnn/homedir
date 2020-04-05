SHELL := /bin/bash

.PHONY: docs

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile | sort -b

update: # Update code
	git pull
	$(MAKE) update_inner

update_inner:
	git submodule update --init
	if [[ ! -d .dotfiles ]]; then git clone https://github.com/amanibhavam/dotfiles .dotfiles; fi
	cd .dotfiles && git pull && git submodule update --init
	$(MAKE) -f .dotfiles/Makefile update

upgrade: # Upgrade homedir
	source ./.bash_profile && $(MAKE) -f .dotfiles/Makefile upgrade

brew:
	 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash -

asdf:
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.8 || true
	if test -x "$(shell which apt-get)"; then \
		sudo apt-get install -y --no-install-recommends \
        openssh-server tzdata locales iputils-ping iproute2 net-tools git curl xz-utils unzip \
        docker.io libusb-1.0-0 \
        sudo \
        build-essential \
        libssl-dev zlib1g-dev libbz2-dev libsqlite3-dev libncurses5-dev libncursesw5-dev libffi-dev liblzma-dev libreadline-dev; \
	fi

install: # Install software bundles
	if test -x "$(shell which brew)"; then brew bundle && rm -rf $(shell brew --cache); fi
	asdf install
	python -m venv venv
	source venv/bin/activate && pip install --upgrade pip
	source venv/bin/activate && pip install --no-cache-dir -r requirements.txt
	source ./.bash_profile && $(MAKE) -f .dotfiles/Makefile install

fmt: # Format with isort, black
	@echo
	drone exec --pipeline $@

lint: # Run pyflakes, mypy
	@echo
	drone exec --pipeline $@

test: # Run tests
	@echo
	drone exec --pipeline $@

docs: # Build docs
	@echo
	drone exec --pipeline $@

requirements: # Compile requirements
	@echo
	drone exec --pipeline $@
