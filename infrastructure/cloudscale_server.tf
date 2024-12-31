provider "cloudscale" {
  token = "dkjrc4tjzeo4zfuq6da6rcs7hwkgqxhv"
}

resource "cloudscale_server" "grafana_agent" {
  name         = "grafana-agent"
  flavor_slug  = "flex-4-1"   # Flex-4-1 flavor
  image_slug   = "debian-12"
  volume_size_gb = 50         # Disk size in GB
  ssh_keys     = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJzXNcaIWPkDLf1SzNAD5aHtH/dW6MVEHFmsw5wSN36h"] # Replace with your public SSH key
  #cpu_count    = 1            # Set CPU count explicitly
}