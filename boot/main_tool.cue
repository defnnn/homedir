package defn

import (
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
	create: exec.Run & {
		cmd: ["doctl", "compute", "droplet", "create",
			"--wait",
			"--tag-name", config.name,
			"--enable-ipv6",
			"--image", config.image,
			"--region", config.region,
			"--size", config.size,
			"--ssh-keys", "\(ssh[config.sshkey].id)",
			"--volumes", volume[config.volume].id,
			"--format", "ID",
			"--no-header",
			config.name,
		]
		stdout: string
	}
	fw: exec.Run & {
		cmd: ["doctl", "compute", "firewall", "add-tags",
			firewall[config.firewall].id,
			"--tag-names", config.name,
		]
		$after: create
	}
	ip: exec.Run & {
		cmd: ["doctl", "compute", "floating-ip", "assign",
			droplet.ip,
			create.stdout,
		]
		$after: fw
	}
	delete: exec.Run & {
		cmd: ["doctl", "compute", "droplet", "delete",
			"--force",
			config.name,
		]
	}
}
