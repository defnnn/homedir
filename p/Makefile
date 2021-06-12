install: venv/bin/activate
	$(MAKE) cdktf
	$(MAKE) ts

cdkts:
	npm config set fund false
	npm install -g npm
	npm install

ts:
	cd tf/src/ts && npm install
	cd tf/src/ts && $(MAKE) get

venv/bin/activate:
	$(MAKE) py

py:
	python -m venv venv
	. venv/bin/activate && python -m pip install --upgrade pip
	. venv/bin/activate && python -m pip install -r tf/src/py/requirements.txt
