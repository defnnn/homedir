SHELL := /bin/bash

k3s-init:
	cd ../../cluster/$(shell uname -n) && c reset
	cd ../../cluster/$(shell uname -n) && c install
	cd ../../argocd && make deploy
	cd ../../argo-workflows && make deploy
