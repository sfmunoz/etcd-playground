# etcd-playground

- [References](#references)
- [Install (releases)](#install-releases)
- [Install (docker)](#install-docker)
- [Install (brew)](#install-brew)

## References

- https://etcd.io/
- https://github.com/etcd-io/etcd
- [k8s-playground (external repository)](https://github.com/sfmunoz/k8s-playground)

## Install (releases)

Ref: https://etcd.io/ → https://etcd.io/docs/v3.6/quickstart/ → https://etcd.io/docs/v3.6/install/ → https://github.com/etcd-io/etcd/releases/

```
$ curl -OL https://github.com/etcd-io/etcd/releases/download/v3.6.6/etcd-v3.6.6-linux-amd64.tar.gz

$ curl -OL https://github.com/etcd-io/etcd/releases/download/v3.6.6/SHA256SUMS

$ sha256sum etcd-v3.6.6-linux-amd64.tar.gz
887afaa4a99f22d802ccdfbe65730a5e79aa5c9ce2c8799c67e9d804c50ecedb  etcd-v3.6.6-linux-amd64.tar.gz

$ grep etcd-v3.6.6-linux-amd64.tar.gz SHA256SUMS
887afaa4a99f22d802ccdfbe65730a5e79aa5c9ce2c8799c67e9d804c50ecedb  etcd-v3.6.6-linux-amd64.tar.gz

$ tar xvzf etcd-v3.6.6-linux-amd64.tar.gz

$ export PATH="$(pwd)/etcd-v3.6.6-linux-amd64:$PATH"

$ etcdctl version
etcdctl version: 3.6.6
API version: 3.6
```
## Install (docker)
```
$ docker run -it --rm --name etcd quay.io/coreos/etcd:v3.6.6
```
Client:
```
$ docker exec -it etcd etcdctl put k v
OK
```
## Install (brew)
```
$ brew install etcd

$ etcdctl version
etcdctl version: 3.6.6
API version: 3.6
```
