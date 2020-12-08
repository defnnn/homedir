SHELL := /bin/bash

.PHONY: docs

menu:
	@perl -ne 'printf("%20s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile

step-ssh-user:
	ssh-add -L > ~/.ssh/id_rsa.pub
	token=$$(step ca token ${user} --not-after 11s --ssh --principal "${username}" ${opt} --provisioner defn --password-file .step/.pw); \
		step ssh certificate --token "$${token}" --provisioner defn -f --insecure --no-password --sign --principal "${username}" ${opt} "${user}" ~/.ssh/id_rsa.pub
	ssh-keygen -L -f ~/.ssh/id_rsa-cert.pub

renew: # Generate a new user certificate
	$(MAKE) step-ssh-user user=home username=app opt='--principal defn'
