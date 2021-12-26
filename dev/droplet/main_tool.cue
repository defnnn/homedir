package defn

import (
	"strings"
	"tool/exec"
	"tool/file"
)

command: {
	create: {
		listUserData: file.Glob & {
			glob: config.userdata
		}
		createDroplet: exec.Run & {
			cmd: ["doctl", "compute", "droplet", "create",
				"--format", "ID",
				"--no-header",
				"--tag-name", config.name,
				"--enable-ipv6",
				"--enable-private-networking",
				"--enable-monitoring",
				"--image", config.image,
				"--region", config.region,
				"--size", config.size,
				"--ssh-keys", "\(ssh[config.sshkey].id)",
				if config.volume != null {
					"--volumes"
				},
				if config.volume != null {
					volume[config.volume].id
				},
				if len(listUserData.files) == 1 {
					"--user-data-file"
				},
				if len(listUserData.files) == 1 {
					config.userdata
				},
				config.name,
			]
			stdout: string
		}
		attachFirewall: exec.Run & {
			cmd: ["doctl", "compute", "firewall", "add-tags", firewall[config.firewall].id, "--tag-names", config.name]
			$after: createDroplet
		}
	}
	deploy: {
		waitPing: exec.Run & {
			cmd: ["bash", "-c", "until ping -c1 \(config.fqdn)>/dev/null 2>&1; do date; sleep 1; done"]
		}
		githubHost: exec.Run & {
			cmd: ["bash", "-c", "ssh \(config.name) ssh -o StrictHostKeyChecking=false git@github.com || true"]
			$after: waitPing
		}
		gitClone: exec.Run & {
			cmd: ["ssh", config.name, "git", "clone", "git@github.com:amanibhavam/homedir"]
			$after: githubHost
		}
		rmGit: exec.Run & {
			cmd: ["ssh", config.name, "rm", "-rf", ".git"]
			$after: gitClone
		}
		installClone: exec.Run & {
			cmd: ["ssh", config.name, "mv", "homedir/.git", "."]
			$after: rmGit
		}
		removeClone: exec.Run & {
			cmd: ["ssh", config.name, "rm", "-rf", "homedir"]
			$after: installClone
		}
		resetHomedir: exec.Run & {
			cmd: ["ssh", config.name, "git", "reset", "--hard"]
			$after: removeClone
		}
		installPackages: exec.Run & {
			cmd: ["ssh", config.name, "sudo", "apt", "install", "-y", "make", "unzip", "pass", "jq", "postgresql", "postgresql-contrib", "docker.io"]
			$after: resetHomedir
		}
		dockerGroup: exec.Run & {
			cmd: ["ssh", config.name, "sudo", "usermod", "-a", "-G", "docker", "ubuntu"]
			$after: installPackages
		}
		copyToolVersions: exec.Run & {
			cmd: ["ssh", config.name, "cp", "/mnt/.password-store/.tool-versions", "."]
			$after: dockerGroup
		}
		bootstrapHomedir: exec.Run & {
			cmd: ["ssh", config.name, "make", "bootstrap"]
			$after: copyToolVersions
		}
		initKubernetes: exec.Run & {
			cmd: ["ssh", config.name, "bin/chexec.sh", "/mnt/work/dev/cluster/\(config.name)", "make"]
			$after: bootstrapHomedir
		}
		reboot: exec.Run & {
			cmd: ["bash", "-c", "ssh \(config.name) sudo reboot || true"]
			$after: initKubernetes
		}
	}
	delete: exec.Run & {
		cmd: ["doctl", "compute", "droplet", "delete", "--force", config.name]
	}
	snapshot: {
		dropletID: exec.Run & {
			cmd: ["doctl", "compute", "droplet", "get", "--format", "ID", "--no-header", config.name]
			stdout: string
		}
		shutdownDroplet: exec.Run & {
			cmd: ["doctl", "compute", "droplet-action", "shutdown", "--wait", strings.TrimSpace(dropletID.stdout)]
		}
		snapshotDroplet: exec.Run & {
			cmd: ["doctl", "compute", "droplet-action", "snapshot", "--wait", "--snapshot-name", config.name, strings.TrimSpace(dropletID.stdout)]
			$after: shutdownDroplet
		}
		deleteDroplet: exec.Run & {
			cmd: ["doctl", "compute", "droplet", "delete", "--force", config.name]
			$after: snapshotDroplet
		}
	}
	list: {
		listDroplets: exec.Run & {
			cmd: ["doctl", "compute", "droplet", "list"]
		}
		listVolumes: exec.Run & {
			cmd: ["doctl", "compute", "volume", "list"]
			$after: listDroplets
		}
		listSnapsnots: exec.Run & {
			cmd: ["doctl", "compute", "snapshot", "list"]
			$after: listVolumes
		}
	}
}
