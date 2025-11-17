#!/bin/bash
# vim: foldmethod=marker

# Ref: https://github.com/etcd-io/etcd/blob/main/etcd.conf.yml.sample

# {{{ globals

[ "$NODES" = "" ] && NODES="5"
[ "$PORT_BASE" = "" ] && PORT_BASE="2379"

# }}}
# functions
# {{{ node_name()

function node_name {
  n="$1"
  echo "n${n}"
}

# }}}
# {{{ initial_cluster()

function initial_cluster {
  RET=""
  for i in $(seq 0 $((NODES-1)))
  do
    [ "${RET}" = "" ] || RET="${RET},"
    RET="${RET}$(node_name $i)=http://localhost:$((PORT_BASE+2*i+1))"
  done
  echo "$RET"
}

# }}}
# {{{ unit_name()

function unit_name {
  n=$1
  echo "etcd-$(node_name $n)"
}

# }}}
# {{{ node_config()

function node_config {
  n=$1
  ETCD_NAME="$(node_name $n)"
  rm -rf $ETCD_NAME
  mkdir -p $ETCD_NAME
  CLI_PORT=$((PORT_BASE+2*n))
  PEER_PORT=$((PORT_BASE+2*n+1))
  ETCD_CONFIG_FILE="${ETCD_NAME}/etcd.conf.yaml"
  cat > "$ETCD_CONFIG_FILE" << __EOF
name: "${ETCD_NAME}"
data-dir: "${ETCD_NAME}/data"
wal-dir: "${ETCD_NAME}/wal"
listen-client-urls: "http://localhost:${CLI_PORT}"
initial-advertise-client-urls: "http://localhost:${CLI_PORT}"
listen-peer-urls: "http://localhost:${PEER_PORT}"
initial-advertise-peer-urls: "http://localhost:${PEER_PORT}"
initial-cluster: "$(initial_cluster)"
initial-cluster-state: "new"
initial-cluster-token: "ba88ab559201152899512f43dbafa983"
log-outputs: [stderr]
__EOF
  echo "${ETCD_CONFIG_FILE}"
}

# }}}
# {{{ node_start()

function node_start {
  n=$1
  ETCD_CONFIG_FILE="$(node_config $n)"
  UNIT_NAME="$(unit_name $n)"
  set -x
  systemd-run --user --same-dir -E ETCD_CONFIG_FILE="${ETCD_CONFIG_FILE}" -u "$UNIT_NAME" etcd
  { set +x; } 2> /dev/null
}

# }}}
# {{{ node_stop()

function node_stop {
  n=$1
  UNIT_NAME="$(unit_name $n)"
  set -x
  systemctl --user stop "$UNIT_NAME"
  systemctl --user reset-failed "$UNIT_NAME"
  { set +x; } 2> /dev/null
}

# }}}
# main
# {{{ main

case "$1" in
  start)
    cd "$(dirname "$0")"
    set -e -o pipefail
    for n in $(seq 0 $((NODES-1)))
    do
      node_start "$n"
    done
  ;;
  stop)
    for n in $(seq 0 $((NODES-1)))
    do
      node_stop "$n"
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

# }}}
