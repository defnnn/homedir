package defn

config: docker: {
	from: "\(config.docker.image):base"
	tag:  "typescript"
}
