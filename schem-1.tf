variable softlayer_username {}
variable softlayer_api_key {}
variable base_template_image {}
variable compute_node_image {}
variable datacenter {}
variable domain {}
variable domain_username {}
variable domain_password {}
variable dc_hostname {}
variable cn_hostname {}
variable computenode_count {}
variable domain_script_url {}

provider "ibmcloud" {
  softlayer_username = "${var.softlayer_username}"
  softlayer_api_key = "${var.softlayer_api_key}"
}

data "ibmcloud_infra_image_template" "base_template" {
  name = "${var.base_template_image}"
}
data "ibmcloud_infra_image_template" "compute_template" {
  name = "${var.compute_node_image}"
}

resource "ibmcloud_infra_virtual_guest" "domaincontroller" {
  count = "1"
  hostname = "${var.dc_hostname}"
  domain = "${var.domain}"
  image_id = "${data.ibmcloud_infra_image_template.base_template.id}"
  datacenter = "${var.datacenter}"
  cores = 4
  memory = 4096
  network_speed = 1000
  local_disk = false
  private_network_only = true,
  hourly_billing = true,
  tags = ["schematics","domaincontroller"]
  user_metadata = "#ps1_sysnative\nscript: |\n<powershell>\nNew-Item c:\\installs -type directory\ninvoke-webrequest '${var.domain_script_url}' -outfile 'c:\\installs\\create-domain-controller.ps1'\nc:\\installs\\create-domain-controller.ps1 -domain ${var.domain} -username ${var.domain_username} -password ${var.domain_password} -step 1\n</powershell>"
}

resource "ibmcloud_infra_virtual_guest" "computenodes" {
  count = "${var.computenode_count}"
  hostname = "${var.cn_hostname}${count.index}"
  domain = "${var.domain}"
  image_id = "${data.ibmcloud_infra_image_template.compute_template.id}"
  datacenter = "${var.datacenter}"
  cores = 2
  memory = 2048
  network_speed = 1000
  local_disk = false
  private_network_only = true,
  hourly_billing = true,
  tags = ["schematics","compute"]
  user_metadata = "#ps1_sysnative\nscript: |\n<powershell>\nNew-Item c:\\installs -type directory\n$ErrorActionPreference='SilentlyContinue'\nStop-Transcript | out-null\n$ErrorActionPreference = 'Continue'\nStart-Transcript -path C:\installs\output.txt -append\n$secure_string_pwd = ConvertTo-SecureString ${var.domain_password} -AsPlainText -Force\n$cred = New-Object System.Management.Automation.PSCredential (${var.domain_username}, $secure_string_pwd)\n$private_nic = Get-NetAdapter -Name 'Ethernet 2'\n$private_nic | Set-DnsClientServerAddress -ServerAddresses (${ibmcloud_infra_virtual_guest.domaincontroller.ipv4_address_private})\nSleep -Seconds 5\nAdd-Computer -DomainName ${var.domain} -Credential $cred\nSleep -Seconds 5\nStop-Transcript\nRestart-Computer\n</powershell>"
}
