# Create datasource of images from the image list
data "oci_core_images" "images" {
  compartment_id = var.compartment_ocid
  operating_system = "Oracle Linux"
  operating_system_version = "8"
}

# Create a compute instance with a public IP address using oci provider
resource "oci_core_instance" "instance" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_name
  shape               = var.instance_shape


  
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.images.images[0].id
    boot_volume_size_in_gbs = 200
  }

  create_vnic_details {
    assign_public_ip = "true"
    subnet_id        = oci_core_subnet.subnet.id
  }
  # Add private key
  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(file("setup-instance.sh"))
  }

    extended_metadata = {
        hf_token = var.hf_token
    }
}

# Create datasource for availability domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.compartment_ocid
}

# Create internet gateway
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.infra_vcn.id
  display_name   = "${var.instance_name}-internet-gateway"
}

# Create route table
resource "oci_core_route_table" "infra_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.infra_vcn.id
  display_name   = "${var.instance_name}-route-table"
  route_rules {
    destination = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# Create security list with ingress and egress rules
resource "oci_core_security_list" "infra_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.infra_vcn.id
  display_name   = "${var.instance_name}-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all outbound traffic"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = "0.0.0.0/0"
    description = "Allow all inbound traffic"
  }

  # ingress rule for ssh
    ingress_security_rules {
        protocol    = "6" # tcp
        source      = "0.0.0.0/0"
        description = "Allow ssh"
        tcp_options {
            max = 22
            min = 22
        }
    }
}

# Create a subnet
resource "oci_core_subnet" "subnet" {
  cidr_block        = var.subnet_cidr
  compartment_id    = var.compartment_ocid
  display_name      = "${var.instance_name}-subnet"
  vcn_id            = oci_core_virtual_network.infra_vcn.id
  route_table_id    = oci_core_route_table.infra_route_table.id
  security_list_ids = ["${oci_core_security_list.infra_security_list.id}"]
  dhcp_options_id   = oci_core_virtual_network.infra_vcn.default_dhcp_options_id
}

# Create a virtual network
resource "oci_core_virtual_network" "infra_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "${var.instance_name}-vcn"
}

output "instance_public_ip" {
  value = <<EOF
  
  Wait 15 minutes for the apps to be ready.

  ssh -i server.key opc@${oci_core_instance.instance.public_ip}
  
  ssh tunnel => 
    ssh -i server.key -L 7860:localhost:7860 -L 3000:localhost:3000 opc@${oci_core_instance.instance.public_ip}

  Document QA web ui => https://localhost:7860
  
EOF
}