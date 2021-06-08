SHELL := /bin/bash

synth:
	cd src && tfc synth

get:
	cd src && tfc get

init:
	terraform init

upgrade:
	terraform init -upgrade

fmt:
	for a in *.tf *.tfvars; do if [[ -f $$a ]]; then terraform fmt $$a; fi; done

validate:
	terraform validate

check:
	checkov -d .

plan:
	terraform plan -out=.plan

apply:
	terraform apply .plan
	rm -f .plan

refresh:
	terraform refresh

apply-refresh:
	terraform apply -refresh-only

console:
	terraform console

replace:
	terraform plan -out=.plan --replace=module.defn.module.instance.aws_instance.default
