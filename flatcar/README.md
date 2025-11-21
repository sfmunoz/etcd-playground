# etcd: flatcar 4459.2.0

- [References](#references)
- [Example](#example)
- [Details](#details)
  - [Usage](#usage)
  - [/usr/lib/systemd/system/etcd-member.service](#usrlibsystemdsystemetcd-memberservice)
  - [/usr/lib/flatcar/etcd-wrapper](#usrlibflatcaretcd-wrapper)

## References

> https://www.flatcar.org/docs/latest/setup/customization/customize-etcd-unit/

## Example

**Notice**: **etcd.yaml** must be provided with proper keys/certs:

Reset/provision of flatcar hosts (**etcd.json** is created, injected followed by VM reset):
```
IPS="192.168.0.1 192.168.0.2 192.168.0.3" make reset
```
Demo client execution (TLS):
```
core@localhost ~ $ sudo /root/etcdctl.sh
+ etcdctl --cacert /var/lib/etcd/ca.pem --key /root/cli.key --cert /root/cli.crt put k 1234
OK
+ etcdctl --cacert /var/lib/etcd/ca.pem --key /root/cli.key --cert /root/cli.crt get k
k
1234
```

## Details

### Usage

It's ready to be run on vanilla **flatcar 4459.2.0**:

```
core@localhost ~ $ sudo systemctl start etcd-member

core@localhost ~ $ docker ps -a
CONTAINER ID   IMAGE                         COMMAND                 CREATED              STATUS              PORTS     NAMES
fb51cea61662   quay.io/coreos/etcd:v3.5.16   "/usr/local/bin/etcd"   About a minute ago   Up About a minute             etcd-member
```

### /usr/lib/systemd/system/etcd-member.service

```ini
core@localhost ~ $ cat /usr/lib/systemd/system/etcd-member.service
[Unit]
Description=etcd (System Application Container)
Documentation=https://github.com/etcd-io/etcd
Wants=network-online.target network.target
After=network-online.target
Conflicts=etcd.service
Conflicts=etcd2.service

[Service]
Type=notify
NotifyAccess=all
Restart=always
RestartSec=10s
TimeoutStartSec=0
LimitNOFILE=40000

Environment="ETCD_IMAGE_URL=quay.io/coreos/etcd"
Environment="ETCD_IMAGE_TAG=v3.5.16"
Environment="ETCD_NAME=%m"
Environment="ETCD_USER=etcd"
Environment="ETCD_DATA_DIR=/var/lib/etcd"
Environment="ETCD_SSL_DIR=/etc/ssl/certs"

ExecStart=/usr/lib/flatcar/etcd-wrapper $ETCD_OPTS
ExecStop=/usr/bin/docker stop etcd-member
ExecStopPost=/usr/bin/docker rm etcd-member

[Install]
WantedBy=multi-user.target
```

### /usr/lib/flatcar/etcd-wrapper

```bash
core@localhost ~ $ cat /usr/lib/flatcar/etcd-wrapper
#!/bin/bash
# The "etcd-wrapper" script can't be deleted because ct overwrites
# the ExecStart directive with etcd-wrapper. Do the new action of
# ExecStart here.
set -e

# Since etcd/v3 we can't use both `--name` and `ETCD_NAME` at the same time.
# We parse the etcd command line options to find a `--name/-name` flag if we found one,
# we unset the `ETCD_NAME` to not conflict with it.
for f in "${@}"; do
    if [[ $f =~ ^-?-name=? ]]; then
        unset ETCD_NAME
        break
    fi
done


# Do not pass ETCD_DATA_DIR through to the container. The default path,
# /var/lib/etcd is always used inside the container.
etcd_data_dir="${ETCD_DATA_DIR}"
ETCD_DATA_DIR="/var/lib/etcd"
mkdir -p ${etcd_data_dir}
chown -R etcd:etcd ${etcd_data_dir}
chmod 700 ${etcd_data_dir}
# A better way to run the Flannel/etcd container image is Podman because
# Flannel depends on etcd but wants to be run before Docker so that it
# can set up the Docker networking. Etcd and Flannel are part of the
# Container Linux Config specification and thus can't be dropped easily.
# For now we have to resort to running these services with Docker and try
# to restart Docker for the Flannel options to take effect.
/usr/bin/docker stop etcd-member || true
/usr/bin/docker rm -f etcd-member || true
# set umask so that sdnotify-proxy creates /run/etcd-notify with the same relaxed permissions as NOTIFY_SOCKET (/run/systemd/notify) normally has, to allow ETCD_USER to write to it
umask 000
# mapping only /run/etcd-notify does not work and we use the full /run, also we must set NOTIFY_SOCKET in the container but use the original for /usr/libexec/sdnotify-proxy
/usr/libexec/sdnotify-proxy /run/etcd-notify /usr/bin/docker run --name etcd-member --network=host --ipc=host -u $(id -u ${ETCD_USER}):$(id -g ${ETCD_USER}) -v /run:/run -v /usr/share/ca-certificates:/usr/share/ca-certificates:ro -v ${etcd_data_dir}:/var/lib/etcd:rw -v ${ETCD_SSL_DIR}:/etc/ssl/certs:ro --env-file <(env; echo PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; echo NOTIFY_SOCKET=/run/etcd-notify) --entrypoint /usr/local/bin/etcd ${ETCD_IMAGE:-${ETCD_IMAGE_URL}:${ETCD_IMAGE_TAG}} "$@"
```
