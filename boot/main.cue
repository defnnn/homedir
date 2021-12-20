package defn

config: {
	name:     "dev"
	image:    "ubuntu-20-04-x64"
	region:   "sfo3" // doctl compute region list
	size:     "c-2"  // doctl compute size list
	sshkey:   "immanent"
	firewall: "Private"
	volume:   "volume-sfo3-01"
}
