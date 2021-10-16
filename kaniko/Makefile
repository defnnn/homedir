build:
	docker build -t k3d-hub.defn.ooo:5000/kaniko .

push:
	docker push k3d-hub.defn.ooo:5000/kaniko

warm:
	docker pull gcr.io/kaniko-project/executor:v1.6.0-debug
	docker tag gcr.io/kaniko-project/executor:v1.6.0-debug k3d-hub.defn.ooo:5000/kaniko-project/executor:v1.6.0-debug
	docker push k3d-hub.defn.ooo:5000/kaniko-project/executor:v1.6.0-debug
