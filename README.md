# Qumulus Platform Demo README

This repository contains terraform code that will enable you to quickly get started with OpenStack and allow you to explore some of it's features using a "real life" example deployment of Elastic Cloud behind a load balancer and a Kubernetes deployment

The entire deployment will fully utilise 4 QUMs of cloud capacity. If you are deploying this code to a trial account, please ensure your environment is clean before deploying or it might fail as the trial includes 4 QUMs.

Please refer to [this](https://support.qumulus.io/hc/en-gb/articles/16590120710162-Initializing-Environment) helpdesk article for detailed instructions how to get started with this code.

As a minimum you would need to to create a `terrform.tfvars` file with the following content

```
domain                              = "asubdomain.yourdomain.com"
letsencrypt_email                   = "someone@yourdomain.com"
public_ssh_key_path                 = "~/.ssh/id_rsa.pub"
private_ssh_key_path                = "~/.ssh/id_rsa"
```

The following modules are deployed in the `openstack.tf` file.

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

To access the logs, follow the instructions displayed in the terraform output.

There is alternative code for the above 2 modules that allow you to replicate the above infrastructure on AWS for comparison. You can access it be uncommenting out the modules in the file `aws.tf`. You will need AWS credentials to be able to run this code.

The script records the time taken to complete all the above steps, so that you can easily benchmark your cloud deployment and run a performance comparison against AWS as an example.

## Kubernetes

This module creates the network layout required to support both private Kubernetes clusters (only accessible using a VPN) and public Kubernetes clusters, where any load balanced services you create from within Kubernetes are exposed using a public IP. You can optionally expose the `kube-api`to the Internet by placing a load balancer in front of it and setting the label `master_lb_floating_ip_enabled` to true which we have done in the demo code.

In order to segment Kubernetes nodes away from your regular VMs, 3 new networks are created.

Here is a diagram of what the networking looks like

![network diagram](/images/KubernetesNetworkDiagram.png)

Two Kubernetes templates and clusters are created

 - kubernetes-`${var.kube_tag}`-internal
 - kubernetes-`${var.kube_tag}`-public

`${var.kube_tag}` is taken from the terraform variables and you can use any tag available in [this](https://hub.docker.com/r/rancher/hyperkube/tags) repo. We support all recent versions up to v1.28.6 which is the latest available at the time of writing this document. Support for newer versions should be available after testing.

To get access details to the Kubernetes api, run the command

    openstack coe cluster config --dir ${directory} ${cluster_name_or_uuid}

The above directory should exist and be empty.  And then point your Kubernetes client to the above directory with the following command

    export KUBECONFIG=${directory}

Alternatively, you can set the terraform variable `update_kube_config` to `true` in your `terraform.tfvars` file, (this now defaults to `true`) and it will add any OpenStack clusters you have access to, to your `~/.kube/config` file automatically. You will need the `openstack cli`, `kubectl` and `yq` installed for this to work. Refer to the helpdesk article above on how to install these tools.

## ArgoCD

[ArgCD](https://argo-cd.readthedocs.io/en/stable/) is a popular GitOps continuous delivery tool for Kubernetes, however like with anything related to Kubernetes, it comes with a steep learning curve. But also, like with anything related to Kubernetes, once you grasp it's significance and power, it can change your life :grinning:

The purpose of this module is to provide an easy entry into the world of ArgoCD by using it to deploy the following tools

 - [Grafana](https://grafana.com/oss/grafana)
 - [Grafana Mimir](https://grafana.com/oss/mimir)
 - [Grafana Loki](https://grafana.com/oss/loki)
 - [Grafana Agent](https://grafana.com/oss/agent)

These tools combined offer a modern,  comprehensive, highly scalable open-source logging, monitoring, alerting and tracing platform that can used across all your applications and cloud services.

In order to setup ArgoCD to deploy the above tools we take the following steps using Terraform

 1. We deploy ArgoCD using it's helm chart
 2. We create the necessary pre-config in Kubernetes required to support the above applications - (Kubernetes secrets with the passwords required to operate these tools)
 3. We deploy an ArgoCD project and an ArgoCD [App of Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) application that points to https://github.com/QumulusTechnology/argocd-demo
 4. ArgoCD than deploys all the applications from the above repo, handling LetsEncrypt cert-request and providing access using Nginx as an ingress via an OpenStack load-balancer and using dynamically created OpenStack volumes for it's `Persistent Volume` storage.

and then run `terraform apply`

### Post Installation:

 Kubernetes will require the following DNS entries to point to the load-balancer that it provides

 - argo.`yourdomain.com`
 - grafana.`yourdomain.com`
 - mimir.`yourdomain.com`
 - loki-gateway.`yourdomain.com`

 To get the IP address of the load-balancer - run this command.

    kubectl -n argocd get ingress -o=custom-columns='ADDRESS:.status.loadBalancer.ingress[0].ip'

Note, it will take a few mins for ArgoCD to install all the applications and for OpenStack to connect a loadbalancer, so you might need to run the above command a few times until an IP Address appears. (If it fails to allocate a public IP address it might because you have run out of free public IPs but this shouldn't occur on the trial platform as you are initially allocated 13 usable public IPs)

ArgoCD installs the [Cert-Manager](https://cert-manager.io) operator and configures a LetEncrypt ClusterIssuer so that you don't have to worry about SSL certificates as it will auotmatically request and install valid LetsEncrypt certificates for any Kubernetes `ingress` configured the following annotation `cert-manager.io/cluster-issuer: letsencrypt`. However for this to work, DNS has to be configured correctly. Once you have set DNS for the above domains, it might take a few mins for DNS to refresh and cert-manager to reattempt a validation. In order to speed this up, you can delete the relevant certificate and certificate-request using kubectl. Follow these [Instructions](https://cert-manager.io/docs/troubleshooting/acme/) to troubleshoot LetsEncrypt.

Note that LetsEncrypt cannot be used for internal Kubernetes cluster that are behind a firewall/VPN - for those you can optionally configure a [self-signed](https://cert-manager.io/docs/configuration/selfsigned) issuer or alternatively use [Hashicorp Vault](https://www.vaultproject.io/) as a backend for cert-manager.

You can optionally setup an [External-DNS](https://github.com/kubernetes-sigs/external-dns) operator to handle DNS automatically, to do this you can install External-DNS using it's [helm](https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns) chart. You would need to provide configuration that tells External-DNS who provides your DNS and give it credentials that can access the domain you enable.

Note for this demo we optionally set up a multi-cluster deployment and point your "internal" Kubernetes cluster to you your "master" metrics deployment which can be enabled by setting the terraform variable `deploy_internal_cluster_helm_charts` to `true`. If the variable is set to `true` we deploy a grafana-agent helm chart on your internal Kubernetes cluster that points to your public "master" cluster. To do this we need access the internal cluster Kubernetes APIs which are only available via the VPN, so please wait until you are connected to the VPN before setting the variable to true. You can run an initial `terraform apply` to set up the initial networking and Kubernetes clusters, get the automatically generated wireguard config from the `wireguard-peer1.conf` file and connect to the VPN, then set the variable to true and rerun `terraform apply`.

The username for all the services is `admin` and the passwords are generated using random values and stored in the `passwords` subfolder.

This is all you need to do to set up the above services (note for the purposes of this demo, the configuration has been kept purposely simple and light, there are many options available and if you plan to use these tools in production, please study the helm charts)

If you login to https://grafana.${yourdomain.com} you should be able to see a few useful dashboards that display your Kubernetes clusters health and logs.

Here are some screenshots from some of the tools

![ArgoCD](/images/argocd.png)

![Mimir Metrics](/images/metrics.png)

![Loki Logs](/images/logs.png)

### Troubleshooting:

If ArgoCD fails to deploy your applications properly and you cannot access ArgoCD using the DNS entry that you have created, run the following command to port-forward ArgoCD to your machine

    kubectl -n argocd port-forward services/argocd-server 8080:80

You should then be able to login to ArgoCD using the url (http://localhost:8080), username: admin and password from the passwords folder
