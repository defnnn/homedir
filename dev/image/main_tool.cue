package defn

import (
	"tool/exec"
)

docker_image: "\(config.docker.image):\(config.docker.tag)"

command: {
	build: {
		buildImage: exec.Run & {
			cmd: ["docker", "build",
				"--build-arg", "IMAGE=\(config.docker.from)",
				"-t", docker_image, ".",
			]
		}
		pushImage: exec.Run & {
			cmd: ["docker", "push", docker_image]
			$after: buildImage
		}
	}
}
