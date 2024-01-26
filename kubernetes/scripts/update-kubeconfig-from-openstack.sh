#!/bin/bash

## Automatically add the kubernetes clusters for the openstack project to the kubeconfig file

function is_bin_in_path {
  builtin type -P "$1" &> /dev/null
}

CONTINUE="true"
if ! is_bin_in_path yq; then
  echo "yq is not installed. cannot run this script"
  CONTINUE="false"
fi

if ! is_bin_in_path openstack; then
  echo "openstack is not installed. cannot run this script"
  CONTINUE="false"
fi

if ! is_bin_in_path kubectl; then
  echo "kubectl is not installed. cannot run this script"
  CONTINUE="false"
fi

if [ "$CONTINUE" == "false" ]; then
    exit 0
fi

mkdir -p ~/.kube
pushd ~/.kube &> /dev/null

for c in $(openstack coe cluster list -c uuid -c name -f value | cut -d " " -f 1); do

dir=$(mktemp -d)
openstack coe cluster config --dir ${dir} ${c} &> /dev/null
server=$(yq -r '.clusters[].cluster.server' ${dir}/config)
cluster=$(yq -r '.contexts[].context.cluster' ${dir}/config)
yq -r '.clusters[].cluster."certificate-authority-data"' ${dir}/config | base64 -d > ${dir}/certificateAuthorityData.txt
yq -r '.users[].user."client-certificate-data"' ${dir}/config | base64 -d > ${dir}/clientCertificateData.txt
yq -r '.users[].user."client-key-data"' ${dir}/config | base64 -d > ${dir}/clientKeyData.txt

kubectl config set-cluster $cluster --embed-certs --server=$server --certificate-authority=${dir}/certificateAuthorityData.txt
kubectl config set-credentials $cluster --embed-certs --client-certificate=${dir}/clientCertificateData.txt --client-key=${dir}/clientKeyData.txt
kubectl config set-context $cluster --cluster=$cluster --user=$cluster
kubectl config use-context $cluster

rm -rf ${dir}
done

popd &> /dev/null
