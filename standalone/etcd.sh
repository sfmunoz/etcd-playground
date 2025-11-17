#!/bin/bash

# Ref: https://github.com/etcd-io/etcd/blob/main/etcd.conf.yml.sample

[ "$NODES" = "" ] && NODES="5"

case "$1" in
  start)
    cd "$(dirname "$0")"
    set -e -o pipefail
    INITIAL_CLUSTER=""
    for i in $(seq 0 $((NODES-1)))
    do
      SEP=","
      [ "${INITIAL_CLUSTER}" = "" ] && SEP=""
      INITIAL_CLUSTER="${INITIAL_CLUSTER}${SEP}n${i}=http://localhost:$((2380+2*$i))"
    done
    for i in $(seq 0 $((NODES-1)))
    do
      ETCD_NAME="n$i"
      rm -rf $ETCD_NAME
      mkdir -p $ETCD_NAME
      CLI_PORT=$((2379+2*i))
      PEER_PORT=$((2380+2*i))
      ETCD_CONFIG_FILE="${ETCD_NAME}/etcd.conf.yaml"
      cat > "$ETCD_CONFIG_FILE" << __EOF
name: "${ETCD_NAME}"
data-dir: "${ETCD_NAME}/data"
wal-dir: "${ETCD_NAME}/wal"
listen-client-urls: "http://localhost:${CLI_PORT}"
initial-advertise-client-urls: "http://localhost:${CLI_PORT}"
listen-peer-urls: "http://localhost:${PEER_PORT}"
initial-advertise-peer-urls: "http://localhost:${PEER_PORT}"
initial-cluster: "${INITIAL_CLUSTER}"
initial-cluster-state: "new"
initial-cluster-token: "ba88ab559201152899512f43dbafa983"
log-outputs:
- stderr
__EOF
      UNIT_NAME="etcd-${ETCD_NAME}"
      set -x
      systemd-run --user --same-dir -E ETCD_CONFIG_FILE="${ETCD_CONFIG_FILE}" -u "$UNIT_NAME" etcd
      { set +x; } 2> /dev/null
    done
  ;;
  stop)
    for i in $(seq 0 $((NODES-1)))
    do
      UNIT_NAME="etcd-n${i}"
      set -x
      systemctl --user stop "$UNIT_NAME"
      systemctl --user reset-failed "$UNIT_NAME"
      { set +x; } 2> /dev/null
    done
  ;;
  *)
    echo
    echo "usage:"
    echo
    echo "  $(basename "$0") start/stop"
    echo
    exit 1
  ;;
esac

