package defn

import (
	"tool/exec"
)

command: passwd: exec.Run & {
	cmd: ["kubectl", "--namespace", "argocd", "get", "-o", "go-template={{.data.password | base64decode}}", "secret/argocd-initial-admin-secret"]
}

command: add: {
  addProject: exec.Run & {
    cmd: ["argocd", "--core", "proj", "create", arg1]
  }

  addCluster: exec.Run & {
    cmd: ["argocd", "--core", "cluster", "add", "-y", "--project", arg1, arg1]
    $after: addProject
  }
}
