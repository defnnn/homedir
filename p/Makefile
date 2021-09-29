SHELL := /bin/bash

install: venv/bin/activate
	$(MAKE) cdktf
	$(MAKE) cdktf-py

clean:
	rm -rf venv
	rm -rf node_modules
	rm -rf imports cdktf.out

venv/bin/activate:
	$(MAKE) py

cdktf:
	npm config set fund false
	npm install -g npm
	npm install

cdktf-py:
	python -m venv venv
	. venv/bin/activate && python -m pip install --upgrade pip
	. venv/bin/activate && python -m pip install -r requirements.txt

test:
	checkov -d .

init:
	terraform init

upgrade:
	terraform init -upgrade

fmt:
	for a in *.tf *.tfvars; do if [[ -f $$a ]]; then terraform fmt $$a; fi; done

validate:
	terraform validate

plan:
	terraform plan -out=.plan

apply:
	terraform apply .plan
	rm -f .plan

refresh:
	terraform refresh

console:
	terraform console

apply-refresh: cdk.tf.json
	terraform apply -refresh-only

get:
	./node_modules/.bin/cdktf get

build:
	. ./venv/bin/activate && ./node_modules/.bin/cdktf synth
	$(MAKE) gen.tf.json

gen.tf.json: cdktf.out/stacks/default/cdk.tf.json
	cat $< | jq 'walk(if type == "object" then if .["//"] == null then . else del(.["//"]) end else . end)' > $@.1
	mv -f $@.1 $@
