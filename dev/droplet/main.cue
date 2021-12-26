package defn

config: {
	name:     string
	fqdn:     string | *"\(name).tiger-mamba.ts.net"
	volume:   string | *null
	userdata: string | *"../user-data.txt"

	image:    string | *"ubuntu-20-04-x64"
	region:   string | *"sfo3"        // doctl compute region list
	size:     string | *"s-1vcpu-1gb" // doctl compute size list
	sshkey:   string | *"immanent"
	firewall: string | *"Private"
}
