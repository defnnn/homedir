package defn

config: docker: {
	from: "\(config.docker.image):golang"
	tag:  "pulumi"
}
