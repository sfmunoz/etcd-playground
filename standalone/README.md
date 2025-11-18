# etcd: standalone

- [Usage](#usage)

## Usage

Start:
```
$ ./etcd.sh start
+ systemd-run --user --same-dir -E ETCD_CONFIG_FILE=n0/etcd.conf.yaml -u etcd-n0 etcd
Running as unit: etcd-n0.service; invocation ID: fcd482ba47b741f082e5d9a4b1864349
+ systemd-run --user --same-dir -E ETCD_CONFIG_FILE=n1/etcd.conf.yaml -u etcd-n1 etcd
Running as unit: etcd-n1.service; invocation ID: dff9be5bdf694b02a03bd1d8fe88ac43
+ systemd-run --user --same-dir -E ETCD_CONFIG_FILE=n2/etcd.conf.yaml -u etcd-n2 etcd
Running as unit: etcd-n2.service; invocation ID: fe48164bd839460da201cc5fc4fc5ec1
+ systemd-run --user --same-dir -E ETCD_CONFIG_FILE=n3/etcd.conf.yaml -u etcd-n3 etcd
Running as unit: etcd-n3.service; invocation ID: 7e2daf1d345d460f9d32769060c3f0f5
+ systemd-run --user --same-dir -E ETCD_CONFIG_FILE=n4/etcd.conf.yaml -u etcd-n4 etcd
Running as unit: etcd-n4.service; invocation ID: 4dcb5618916a43039697024de89a3c06
```
Members:
```
$ etcdctl member list
229a8dfc7934aab3, started, n0, http://localhost:2380, http://localhost:2379, false
34f90e30f9124f52, started, n1, http://localhost:2382, http://localhost:2379, false
35a4707965991847, started, n3, http://localhost:2386, http://localhost:2379, false
4b85bd4bccbdb071, started, n4, http://localhost:2388, http://localhost:2379, false
da9dae8f861efc6a, started, n2, http://localhost:2384, http://localhost:2379, false
```
Stop:
```
$ ./etcd.sh stop
+ systemctl --user stop etcd-n0
+ systemctl --user reset-failed etcd-n0
Failed to reset failed state of unit etcd-n0.service: Unit etcd-n0.service not loaded.
+ systemctl --user stop etcd-n1
+ systemctl --user reset-failed etcd-n1
Failed to reset failed state of unit etcd-n1.service: Unit etcd-n1.service not loaded.
+ systemctl --user stop etcd-n2
+ systemctl --user reset-failed etcd-n2
Failed to reset failed state of unit etcd-n2.service: Unit etcd-n2.service not loaded.
+ systemctl --user stop etcd-n3
+ systemctl --user reset-failed etcd-n3
Failed to reset failed state of unit etcd-n3.service: Unit etcd-n3.service not loaded.
+ systemctl --user stop etcd-n4
+ systemctl --user reset-failed etcd-n4
Failed to reset failed state of unit etcd-n4.service: Unit etcd-n4.service not loaded.
```
