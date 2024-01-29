# Qumulus Platform Demo README

This repository contains terraform code that will enable you to quickly get started with OpenStack and allow you to explore some of it's features using a "real life" example deployment of Elastic Cloud behind a load balancer.

Please refer to [this](https://support.qumulus.io/hc/en-gb/articles/16590120710162-Initializing-Environment) helpdesk article for detailed instructions how to get started with this code.

The following modules are accessed in the `openstack.tf` file.

## Network with VPN
The network-with-vpn module sets up a private network and VPN to access the private network. The VPN is protected with a security group and a route is pointed to the VPN sever so that VPN clients can communicate with the local area networks without the need for NAT. We used [VyOS](https://vyos.io/) as the VPN server and [Wireguard](https://www.wireguard.com/) as the VPN protocol but you are free to choose any VPN server or protocol of your choice. Additionally, you can setup clustered VPN servers using availability groups on multiple compute nodes as OpenStack allows for virtual IPs shared by multiple instances.

The vpn server is automatically configured using [cloud-init](https://cloud-init.io/) and a config file named `wireguard-peer-1.conf`is created which you can use to connect to the server. You just need to install a wireguard client and add the configuration from the config file. If you need more than 1 client, you can increase the number of remote peers using the terraform variable `vpn_remote_peers_count`.

## Load Balanced Elastic Search
This module deploys [Elastic Cloud Enterprise](https://www.elastic.co/ece) on 3 nodes behind a load balancer.

It also deploys another "management-instance" node to run the installation and other operations from.

The management instance runs a series of ansible playbooks, that does the follows

 - Deploys Elastic Cloud Enterprise (ECE) using this [playbook](https://github.com/elastic/ansible-elastic-cloud-enterprise)
 - Configures ECE.
 - Creates an initial 3 node ElasticSearch deployment within ECE
 - Uses this [playbook](https://github.com/geerlingguy/ansible-role-certbot) to request a valid LetsEncrypt certificate (note: dns needs to be pointed to the load balancer for this to work)
 - Uploads the LetsEncrypt certificate to the load-balancer listeners
 - Runs an [esrally](https://esrally.readthedocs.io/en/stable/) race against the ElasticSearch deployment.

The load balancer has a number of layer 7 listeners, that terminate TLS sessions with various policies and rules to allow for https redirection, and multiple pools linked to a single listener.

Note: this module requires 4 VMs using a total of 68 GB of RAM so please make sure you have enough capacity free before running it.

To access the logs, follow the instructions displayed in the terraform output.

There is alternative code for the above 2 modules that allow you to replicate the above infrastructure on AWS for comparison. You can access it be uncommenting out the modules in the file `aws.tf`. You will need AWS credentials to be able to run this code.

The script records the time taken to complete all the above steps, so that you can easily benchmark your cloud deployment and run a performance comparison against AWS as an example.

## Kubernetes

This module is commented out by default as you might not have enough capacity to run it side by side with load balanced elastic search module. To use this module uncomment it in the `openstack.tf`file.

This module creates the network layout required to support both private Kubernetes clusters (only accessible using a VPN) and public Kubernetes clusters, where any load balanced services you create from within Kubernetes are exposed using a public IP. You can optionally expose the `kube-api`to the Internet by placing a load balancer in front of it.

In order to segment kubernetes nodes away from your regular VMs, 3 new networks are created.

Here is a diagram of what the networking looks like
![network diagram](/images/KubernetesNetworkDiagram.png)

Two Kubernetes templates and clusters are created

 - kubernetes-`${var.kube_tag}`-internal
 - kubernetes-`${var.kube_tag}`-public

`${var.kube_tag}` is taken from the terraform variables and you can use any tag available in [this](https://hub.docker.com/r/rancher/hyperkube/tags) repo. We support all recent versions up to v1.28.6 which is the latest available at the time of writing this document. Support for newer versions should be available after testing.

To get access details to the Kubernetes api, run the command

    openstack coe cluster config --dir ${directory} ${cluster_name_or_uuid}

The above directory should exist and be empty.  And then point your kubernetes client to the above directory with the following command

    export KUBECONFIG=${directory}

Alternatively, you can set the terraform variable `update_kube_config` to `true` and it will add any OpenStack clusters you have access to, to your `~/.kube/config` file automatically.
