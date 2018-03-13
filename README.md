# kube
由于不能从k8s.gcr.io上直接pull镜像，所以这里通过docker hub的Automated Builds功能从项目的dockerfile中Build到docker的官方服务器上，然后再从它们上面拉取.

##	kube 1.9.3需要的镜像:
```
k8s.gcr.io/kube-proxy-amd64                v1.9.3
k8s.gcr.io/kube-scheduler-amd64            v1.9.3
k8s.gcr.io/kube-controller-manager-amd64   v1.9.3
k8s.gcr.io/kube-apiserver-amd64            v1.9.3

k8s.gcr.io/etcd-amd64                      3.1.10
k8s.gcr.io/pause-amd64                     3.0

k8s.gcr.io/k8s-dns-sidecarkube-amd64       1.14.7
k8s.gcr.io/k8s-dns-kube-dns-amd64          1.14.7
k8s.gcr.io/k8s-dns-dnsmasq-nanny           1.14.7

k8s.gcr.io/kubernetes-dashboard-amd64      v1.8.3
```

## docker hub上设置
由于docker hub不能后期更改一个image的tag，所以每次更新kubernetes时，都在build settings中，手动增加一个版本对应文件

## 更改tag
```
images=(kube-proxy-amd64:v1.9.3 kube-scheduler-amd64:v1.9.3 kube-controller-manager-amd64:v1.9.3 kube-apiserver-amd64:v1.9.3 etcd-amd64:3.1.10 pause-amd64:3.0 k8s-dns-sidecar-amd64:1.14.7 k8s-dns-kube-dns-amd64:1.14.7 k8s-dns-dnsmasq-nanny:1.14.7 kubernetes-dashboard-amd64:v1.8.3)
for imageName in ${images[@]} ; do
  docker pull  thomas67/$imageName
  docker tag  thomas67/$imageName k8s.gcr.io/$imageName
done
# 监控
images=(heapster:canary heapster_grafana:v2.6.0 heapster_influxdb:v0.6)
for imageName in ${images[@]} ; do
  docker pull  thomas67/$imageName
  docker tag  thomas67/$imageName kubernetes/$imageName
done
# 日志
images=(elasticsearch:v2.4.1-1 fluentd-elasticsearch:1.22 kibana:v4.6.1-1)
for imageName in ${images[@]} ; do
  docker pull  thomas67/$imageName
  docker tag  thomas67/$imageName k8s.gcr.io/$imageName
done
```


## 通过kubeadm安装
```
kubeadm init --use-kubernetes-version v1.9.3

#或者(可以通过netstat -rn来看是否需要重新设置 --pod-network-cidr，默认的是10.244.0.0/16)
#kubeadm init --use-kubernetes-version v1.9.3 --pod-network-cidr=172.16.0.0/16
#当时加入某个结点时
#kubeadm join --token=xxx.xxx ip
```

### 让kubernetes可以在master上启动业务pods
```
kubectl taint nodes --all dedicated-
```
### 当通过kubeadm安装后，还需要安装网络
由于 pod 可能运行在不同的机器上，所以为了能让 pod 互相通信，就需要安装 pod 网络插件。weave net或者flannel，如果启动master时配置了pod-network-cidr，这里也要配置:
```
kubectl apply -f https://git.io/weave-kube

```
因为之前的 kube-dns addon 是依赖 pod 网络的，所以在没有部署 pod 网络之前，kube-dns 都会报错，因此只需要检查 kube-dns 是否成功就知道 pod 网络有没有成功了。
```
kubectl get pods --all-namespaces
```

## 如果docker hub也不能访问
如果docker hub也不能访问，那么可以通过[阿里云](https://cr.console.aliyun.com/#/accelerator)或者[daocloud](https://www.daocloud.io/mirror#accelerator-doc)的加速，它会在docker的配置--registry-mirro中加一个镜像服务器，但是通过它还是不能访问google container的镜像，所以还是需要上面在docker hub中配置


## 安装kubeadm
由于kubeadm安装时也要从google的源上下载，这里配置一个离线的包[kubeadm](https://github.com/sails/kube/tree/master/other/)：
```
# ubuntu

dpkg -i kubeadm.deb kubectl.deb kubelet.deb kube-cni.deb
```
