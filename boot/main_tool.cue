package defn

import (
	"strings"
	"tool/exec"
)

arg1: string @tag(arg1)
arg2: string @tag(arg2)
arg3: string @tag(arg3)
arg4: string @tag(arg4)
arg5: string @tag(arg5)
arg6: string @tag(arg6)
arg7: string @tag(arg7)
arg8: string @tag(arg8)
arg9: string @tag(arg9)

command: {
	create: {
		createDroplet: exec.Run & {
			cmd: ["doctl", "compute", "droplet", "create",
				"--wait",
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
				"--volumes", volume[config.volume].id,
				"--user-data-file", "etc/user-data-\(config.name).txt",
				config.name,
			]
			stdout: string
		}
		attachFirewall: exec.Run & {
			cmd: ["doctl", "compute", "firewall", "add-tags",
				firewall[config.firewall].id,
				"--tag-names", config.name,
			]
			$after: createDroplet
		}
		attachIP: exec.Run & {
			cmd: ["doctl", "compute", "floating-ip-action", "assign",
				config.ip,
				strings.TrimSpace(createDroplet.stdout),
			]
			$after: createDroplet
		}
		cleanName: exec.Run & {
			cmd: ["ssh-keygen", "-R", config.name]
			$after: attachIP
		}
		cleanIP: exec.Run & {
			cmd: ["ssh-keygen", "-R", config.ip]
			$after: cleanName
		}
		getHostKey: exec.Run & {
			cmd: ["ssh", "-o", "StrictHostKeyChecking=false", config.name, "true"]
			$after: cleanIP
		}
	}
	delete: exec.Run & {
		cmd: ["doctl", "compute", "droplet", "delete",
			"--force",
			config.name,
		]
	}
}
