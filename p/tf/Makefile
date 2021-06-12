SHELL := /bin/bash

pl ?= ts

synth:
	if test -d src; then cd src/$(pl); fi && tfc synth

get:
	if test -d src; then cd src/$(pl); fi && tfc synth
	tfc get

cdk.tf.json: src/$(pl)/cdktf.out/stacks/default/cdk.tf.json
	cat $< | jq 'walk(if type == "object" then if .["//"] == null then . else del(.["//"]) end else . end)' > $@.1
	mv -f $@.1 $@

init: cdk.tf.json
	terraform init

upgrade: cdk.tf.json
	terraform init -upgrade

fmt: cdk.tf.json
	for a in *.tf *.tfvars; do if [[ -f $$a ]]; then terraform fmt $$a; fi; done

validate: cdk.tf.json
	terraform validate

check: cdk.tf.json
	checkov -d .

plan: cdk.tf.json
	terraform plan -out=.plan

apply:
	terraform apply .plan
	rm -f .plan

refresh: cdk.tf.json
	terraform refresh

apply-refresh: cdk.tf.json
	terraform apply -refresh-only

console: cdk.tf.json
	terraform console

replace: cdk.tf.json
	terraform plan -out=.plan --replace=module.defn.module.instance.aws_instance.default
