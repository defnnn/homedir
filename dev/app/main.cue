package defn

// One namespace
ns: string

namespace: {
	kind:       "Namespace"
	apiVersion: "v1"

	metadata: name: ns
}

// SSH
ssh: {
	port: 2222
}

// Mounts
cm_prefix: "/cm"

// Configuration per app instance
config: [string]: {
	tag:      string
	nodePort: int
}

// Generate statefulSet, service per app instance
for cname, c in config {
	serviceAccount: "\(cname)": {}
	clusterRoleBinding: "\(cname)": {}
	statefulSet: "\(cname)": {}
	service: "\(cname)": {}
}

// Common configuration files
configMap: ssh: {
	data: authorized_keys: """
		ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqGiNI0Co9JAKytfce4UVhEJj+HMaoZ7TFiLg8SBeRDxV+OLma9rqDVkVqrxW5rkGMco3/Xhm/uGu+rkODJD/aZD/1fpzEsNUQIKhP9VXlVx98CMYOMCXTrgXZGdNPs0CzIb0TDI3W1tOGAA0VOZL+DGb/pUFiWeADLA9GiA8qnhahQp6yCNf8zpt3ATawSOGDLttB+PQPvwwUGMozihCcn84Kbf2Q0aQEl5J0kPLQTgBTJ1pPjTqBmkBWhP1KKAEDz3ziUmFF2eoZax7B+VXYlI6nPeETqFWkke6/EVLRqOXC4nYXKUbX2HloiEGkv4ifzzuGyS2Tdiysx0dthVcv cardno:8 624 146
		"""
}

configMap: entry: {
	data: service: """
		#!/usr/bin/env bash

		function main {
			set -x

			if [[ -d \(cm_prefix)/ssh ]]; then
				mkdir -p ~/.ssh
				cp -v \(cm_prefix)/ssh/* ~/.ssh/
			fi

			exec /usr/sbin/sshd -D -o UseDNS=no -o UsePAM=yes -o PasswordAuthentication=no -o Port=\(ssh.port) -e
		}

		main "$@"
		"""
}

// Schemas for Remote Development App
serviceAccount: [NAME=string]: {
	kind:       "ServiceAccount"
	apiVersion: "v1"
	metadata: {
		name:      NAME
		namespace: ns
	}
}

clusterRoleBinding: [NAME=string]: {
	kind:       "ClusterRoleBinding"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: name: "\(NAME)-cluster-role-binding-cluster-admin"
	subjects: [{
		kind:      "ServiceAccount"
		name:      NAME
		namespace: ns
	}]
	roleRef: {
		kind:     "ClusterRole"
		name:     "cluster-admin"
		apiGroup: ""
	}
}

configMap: [NAME=string]: {
	kind:       "ConfigMap"
	apiVersion: "v1"

	metadata: {
		name:      NAME
		namespace: ns
	}
}

statefulSet: [NAME=string]: {
	kind:       "StatefulSet"
	apiVersion: "apps/v1"

	metadata: {
		labels: app: NAME
		name:      NAME
		namespace: ns
	}

	spec: {
		serviceName: NAME
		replicas:    1
		selector: matchLabels: app: NAME
		volumeClaimTemplates: []
		template: {
			metadata: labels: app: NAME
			spec: {
				serviceAccountName: NAME

				terminationGracePeriodSeconds: 60

				securityContext: {
					runAsUser: 1000
					fsGroup:   1000
				}

				volumes: [{
					name: "docker"
					hostPath: path: "/var/run/docker.sock"
				}, {
					name: "mnt"
					hostPath: path: "/mnt"
				},
					for cname, cm in configMap {
						{
							name: cname
							configMap: name: cname
						}
					}]

				containers: [{
					name:            "sshd"
					image:           "defn/dev:\(config[NAME].tag)"
					imagePullPolicy: "Always"
					command: ["bash", "-c", "exec bash \(cm_prefix)/entry/service"]
					ports: [{
						containerPort: ssh.port
					}]
					env: [{
						name: "POD_NAME"
						valueFrom: fieldRef: fieldPath: "metadata.name"
					}, {
						name: "POD_NAMESPACE"
						valueFrom: fieldRef: fieldPath: "metadata.namespace"
					}]
					volumeMounts: [{
						name:      "docker"
						mountPath: "/var/run/docker.sock"
					}, {
						name:      "mnt"
						mountPath: "/mnt"
					},
						for cname, cm in configMap {
							{
								name:      cname
								mountPath: "\(cm_prefix)/\(cname)"
							}
						}]
				}]
			}
		}
	}
}

service: [NAME=string]: {
	kind:       "Service"
	apiVersion: "v1"

	metadata: {
		name: NAME
		labels: app: NAME
		namespace: ns
	}

	spec: {
		type: "NodePort"
		selector: app: NAME
		ports: [{
			port:       ssh.port
			targetPort: ssh.port
			nodePort:   config[NAME].nodePort
		}]
	}
}
