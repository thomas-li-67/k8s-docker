#!/usr/bin/env bash

images=(
    kube-proxy-amd64:v1.9.3
    kube-controller-manager-amd64:v1.9.3
    kube-apiserver-amd64:v1.9.3
    kube-scheduler-amd64:v1.9.3
    kubernetes-dashboard-amd64:v1.9.3
    k8s-dns-sidecar-amd64:1.14.1
    k8s-dns-kube-dns-amd64:1.14.1
    k8s-dns-dnsmasq-nanny-amd64:1.14.1
    etcd-amd64:3.0.17
    pause-amd64:3.0
)

for imageName in ${images[@]} ; do
    docker pull thomas67/$imageName
#    docker tag gcr.io/google_containers/$imageName registry.cn-beijing.aliyuncs.com/bbt_k8s/$imageName
#    docker push registry.cn-beijing.aliyuncs.com/bbt_k8s/$imageName
done

#quay.io/coreos/flannel:v0.7.0-amd64
#docker tag quay.io/coreos/flannel:v0.7.0-amd64 registry.cn-beijing.aliyuncs.com/bbt_k8s/flannel:v0.7.0-amd64
#docker push registry.cn-beijing.aliyuncs.com/bbt_k8s/flannel:v0.7.0-amd64
