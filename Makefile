SHELL := /bin/bash

.PHONY: docs

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile

update: # Update code
	git pull
	$(MAKE) update_inner

update_inner:
	if [[ ! -d .asdf/.git ]]; then git clone https://github.com/asdf-vm/asdf.git asdf; mv asdf/.git .asdf/; rm -rf asdf; cd .asdf && git reset --hard; fi
	git submodule update --init
	if [[ ! -d .dotfiles ]]; then git clone "$(shell cat .dotfiles-repo)" .dotfiles; fi
	cd .dotfiles && git pull && git submodule update --init
	$(MAKE) -f .dotfiles/Makefile update

upgrade: # Upgrade homedir
	source ./.bash_profile && $(MAKE) -f .dotfiles/Makefile upgrade

brew:
	 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash -

install: # Install software bundles
	source ./.bash_profile && ( $(MAKE) install_inner || true )

install_inner:
	if test -x "$(shell which brew)"; then brew bundle && rm -rf $(shell brew --cache); fi
	brew link --overwrite docker-compose
	source ./.bash_profile && asdf install
	if ! test -f venv/bin/activate; then rm -rf venv; source ./.bash_profile && python3 -m venv venv; fi
	source venv/bin/activate && pip install --upgrade pip
	source venv/bin/activate && pip install --no-cache-dir -r requirements.txt
	source ./.bash_profile && $(MAKE) -f .dotfiles/Makefile install
	rm -rf .cache/Homebrew
	./env npm install

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
