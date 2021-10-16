build:
	docker build -t k3d-hub.defn.ooo:5000/kaniko .

push:
	docker push k3d-hub.defn.ooo:5000/kaniko

dogfood:
	docker run -ti --rm -v $(PWD):/workspace \
		k3d-hub.defn.ooo:5000/kaniko-project/executor:v1.6.0-debug \
		--dockerfile=Dockerfile \
		--destination=k3d-hub.defn.ooo:5000/kaniko:bootstrap \
		--reproducible \
		--cache=true --cache-copy-layers \
		--insecure --insecure-pull
	docker pull k3d-hub.defn.ooo:5000/kaniko:bootstrap
	docker run -ti --rm -v $(PWD):/workspace \
		k3d-hub.defn.ooo:5000/kaniko:bootstrap \
		--dockerfile=Dockerfile \
		--destination=k3d-hub.defn.ooo:5000/kaniko \
		--reproducible \
		--cache=true --cache-copy-layers \
		--insecure --insecure-pull
	docker pull k3d-hub.defn.ooo:5000/kaniko

warm:
	docker pull gcr.io/kaniko-project/executor:v1.6.0-debug
	docker tag gcr.io/kaniko-project/executor:v1.6.0-debug k3d-hub.defn.ooo:5000/kaniko-project/executor:v1.6.0-debug
	docker push k3d-hub.defn.ooo:5000/kaniko-project/executor:v1.6.0-debug
