SHELL := /bin/bash

.PHONY: docs

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile | sort -b

update: # Update code
	git pull
	$(MAKE) update_inner

update_inner:
	if [[ ! -d .asdf/.git ]]; then git clone https://github.com/asdf-vm/asdf.git asdf; mv asdf/.git .asdf/; rm -rf asdf; cd .asdf && git reset --hard; fi
	git submodule update --init
	if [[ ! -d .dotfiles ]]; then git clone https://github.com/amanibhavam/dotfiles .dotfiles; fi
	cd .dotfiles && git pull && git submodule update --init
	$(MAKE) -f .dotfiles/Makefile update

upgrade: # Upgrade homedir
	source ./.bash_profile && $(MAKE) -f .dotfiles/Makefile upgrade

brew:
	 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash -

install: # Install software bundles
	source ./.bash_profile && if test -x "$(shell which brew)"; then brew bundle && rm -rf $(shell brew --cache); fi
	source ./.bash_profile && asdf install
	source ./.bash_profile && python -m venv venv
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

uitest:
	 cypress run --browser chrome --headless

uideps:
	sudo apt install -y xvfb
	sudo apt install -y libxcomposite1 libxcursor-dev libxi6 libxtst6 libnss3 libgdk-pixbuf2.0.0 libgtk-3-0 libxss1 libasound2
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo apt install -y ./google-chrome-stable_current_amd64.deb
	rm -f google-chrome-stable_current_amd64.deb
	npm install
