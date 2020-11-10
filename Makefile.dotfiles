SHELL := bash

update:
	if [[ -f /cache/.npmrc ]]; then ln -nfs /cache/.npmrc .; fi
	if [[ -f /efs/.npmrc ]]; then ln -nfs /efs/.npmrc .; fi
	if [[ -f /cache/.pip/pip.conf ]]; then mkdir -p .pip; ln -nfs /cache/.pip/pip.conf .pip/; fi
	if [[ -f /efs/.pip/pip.conf ]]; then mkdir -p .pip; ln -nfs /efs/.pip/pip.conf .pip/; fi

upgrade:
	ln -nfs .dotfiles/bashrc .bashrc.site
	if [[ ! -f .gitconfig ]]; then cp .dotfiles/gitconfig .gitconfig; fi
	if [[ -f /efs/.gitconfig ]]; then cp /efs/.gitconfig .gitconfig; fi
	ln -nfs .dotfiles/gitignore .gitignore
	mkdir -p .ssh && chmod 700 .ssh
	echo "@cert-authority * $(shell cat .dotfiles/trusted-user-ca-keys.pem)"  >> .ssh/known_hosts
	mkdir -p .gnupg && chmod 700 .gnupg
	ln -nfs ../.dotfiles/gnupg/pubring.kbx .gnupg/pubring.kbx
	ln -nfs ../.dotfiles/gnupg/trustdb.gpg .gnupg/trustdb.gpg
	mkdir -p .aws
	if [[ ! -e /usr/local/bin/pass-vault-helper ]]; then \
		if [[ -x "$(HOME)/bin/pass-vault-helper" ]]; then \
			if [[ -w /usr/local/bin ]]; then \
				ln -nfs "$(HOME)/bin/pass-vault-helper" /usr/local/bin/pass-vault-helper \
			else \
				sudo ln -nfs "$(HOME)/bin/pass-vault-helper" /usr/local/bin/pass-vault-helper; \
			fi \
		fi; \
	fi
	mkdir -p .docker
	(cat .docker/config.json 2>/dev/null || echo '{}') | jq -S '. + {credsStore: "pass"}' > .docker/config.json.1
	mv .docker/config.json.1 .docker/config.json
	rm -f .profile

install:
	@true
