SHELL := /bin/bash

.PHONY: docs

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile | sort -b

update: # Update code
	git pull
	$(MAKE) update_inner

update_inner:
	git submodule update --init
	cd .dotfiles && git pull && git submodule update --init
	$(MAKE) -f .dotfiles/Makefile update

upgrade: # Upgrade homedir
	$(MAKE) -f .dotfiles/Makefile update
	source ./.bash_profile && $(MAKE) -f .dotfiles/Makefile upgrade

install: # Install software bundles
	brew bundle
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
