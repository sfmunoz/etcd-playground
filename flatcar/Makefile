IPS := $(IPS)

define bu_to_ign
	docker run --rm -i quay.io/coreos/butane:latest < $< > $@
endef

define bu_to_ign_dec
	sops decrypt --input-type yaml --output-type yaml $< | docker run --rm -i quay.io/coreos/butane:latest > $@
endef

all: etcd.json

# IPS="192.168.0.1 192.168.0.2 192.168.0.3" make reset
reset: etcd.json
	@for IP in $(IPS) ; do \
		set -x ; \
		scp etcd.json core@$$IP: ; \
		ssh core@$$IP "sudo flatcar-reset --keep-machine-id --keep-paths '/etc/ssh/ssh_host_.*' /var/log -F etcd.json && sudo systemctl reboot" ; \
		{ set +x; } 2> /dev/null ; \
	done

%.json: %.enc.yaml
	$(bu_to_ign_dec)

%.ign: %.enc.bu
	$(bu_to_ign_dec)

%.json: %.yaml
	$(bu_to_ign)

%.ign: %.bu
	$(bu_to_ign)

clean:
	${RM} *.json *.ign

.PHONY: all clean reset
