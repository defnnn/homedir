package defn

import (
	"encoding/yaml"
	"tool/exec"
)

objects: [
	namespace,
	for name, c in configMap {c},
	for name, c in statefulSet {c},
	for name, c in service {c},
]

command: {
	apply: {
		kubeApply: exec.Run & {
			cmd: ["kubectl", "apply", "-f", "-"]
			stdin: yaml.MarshalStream(objects)
		}
	}
	delete: {
		kubeApply: exec.Run & {
			cmd: ["kubectl", "delete", "-f", "-"]
			stdin: yaml.MarshalStream(objects)
		}
	}
}
