.POSIX:
.SUFFIXES:

.PHONY: freebsd-11.1-amd64
freebsd-11.1-amd64:
	. secrets/$@/env && $(MAKE) \
		OS=freebsd ISO_OS=FreeBSD \
		ARCH=amd64 \
		VER=11.1 \
		PKGS="gettext-runtime-0.19.8.1_1.txz indexinfo-0.2.6.txz libffi-3.2.1.txz readline-7.0.3.txz python27-2.7.13_7.txz" \
		image

.PHONY: freebsd-11.1-i386
freebsd-11.1-i386:
	. secrets/$@/env && $(MAKE) \
		OS=freebsd ISO_OS=FreeBSD \
		ARCH=i386 \
		VER=11.1 \
		PKGS="gettext-runtime-0.19.8.1_1.txz indexinfo-0.2.6.txz libffi-3.2.1.txz readline-7.0.3.txz python27-2.7.13_7.txz" \
		image

.PHONY: freebsd-11.0-i386
freebsd-11.0-amd64:
	. secrets/$@/env && $(MAKE) \
		OS=freebsd ISO_OS=FreeBSD \
		ARCH=amd64 \
		VER=11.0 \
		PKGS="gettext-runtime-0.19.8.1_1.txz indexinfo-0.2.6.txz libffi-3.2.1.txz readline-6.3.8.txz python27-2.7.13_3.txz" \
		image

.PHONY: debian-9.4.0-ppc64le
debian-9.4.0-ppc64le:
	. secrets/$@/env && $(MAKE) \
		OS=debian ISO_OS=debian \
		ARCH=ppc64le ISO_ARCH=ppc64el \
		VER=9.4.0 \
		image
	
.PHONY: image
image: build/${OS}-${VER}-${ARCH}/${OS}-${VER}-${ARCH}.qcow2

.PHONY: ${OS}-${VER}-${ARCH}-run
${OS}-${VER}-${ARCH}-run:
	qemu-system-x86_64 \
		-drive file=build/${OS}-${VER}-${ARCH}/${OS}-${VER}-${ARCH}.qcow2,if=virtio,cache=writeback,discard=ignore,format=qcow2 \
		-net nic -net bridge,br=br0
		-boot once=d -m 2048M \
		-machine type=pc,accel=kvm \
		-name ${OS}-${VER}-${ARCH} \
		-nographic \
		-vnc 127.0.0.1:71

.PHONY: clean
clean:
	rm -rf build/*

.PHONY: clean-pkgs
clean-pkgs:
	rm -rf vendor/packages/*

.PHONY: clean-isos
clean-isos:
	rm -f vendor/images/*

build/freebsd-${VER}-${ARCH}/${OS}-${VER}-${ARCH}.qcow2: src/packer/${OS}-${VER}-${ARCH}.json secrets/${OS}-${VER}-${ARCH}/http/installerconfig vendor/images/${OS}-${VER}-${ARCH}/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso vendor/packages/${OS}-${VER}-${ARCH}
	PACKER_LOG=1 PACKER_KEY_INTERVAL=10ms packer build -on-error=ask -only=qemu -var-file=src/packer/${OS}-${VER}-${ARCH}.json src/packer/${OS}.json

build/debian-${VER}-${ARCH}/${OS}-${VER}-${ARCH}.qcow2: src/packer/${OS}-${VER}-${ARCH}.json secrets/${OS}-${VER}-${ARCH}/http/preseed.cfg vendor/images/${OS}-${VER}-${ARCH}/${OS}-${VER}-${ISO_ARCH}-netinst.iso
	PACKER_LOG=1 PACKER_KEY_INTERVAL=50ms packer build -on-error=ask -only=qemu -var-file=src/packer/${OS}-${VER}-${ARCH}.json src/packer/${OS}.json

# Supporting intermediate files
secrets/${OS}-${VER}-${ARCH}:
	mkdir -p $@

secrets/${OS}-${VER}-${ARCH}/http: secrets/${OS}-${VER}-${ARCH}
	mkdir -p $@

secrets/${OS}-${VER}-${ARCH}/env: secrets/${OS}-${VER}-${ARCH}

vendor/images/${OS}-${VER}-${ARCH}:
	mkdir -p $@

# FreeBSD ISOs and other bits
secrets/freebsd-${VER}-${ARCH}/http/installerconfig: secrets/${OS}-${VER}-${ARCH}/env src/packer/http/${OS}-${VER}-${ARCH}/installerconfig.tpl secrets/${OS}-${VER}-${ARCH}/http
	test -n "${PROVISIONING_PASSWORD}"
	sed "s/PROVISIONING_PASSWORD/${PROVISIONING_PASSWORD}/" src/packer/http/${OS}-${VER}-${ARCH}/installerconfig.tpl > secrets/${OS}-${VER}-${ARCH}/http/installerconfig

vendor/packages/freebsd-${VER}-${ARCH}: Makefile
	mkdir -p vendor/packages/${OS}-${VER}-${ARCH}
	for pkg in pkg.txz pkg.txz.sig; do \
		[ -f "vendor/packages/${OS}-${VER}-${ARCH}/$$pkg" ] || curl -o "vendor/packages/${OS}-${VER}-${ARCH}/$$pkg" "http://pkg.${OS}.org/${ISO_OS}:11:${ARCH}/quarterly/Latest/$$pkg"; \
	done
	for pkg in ${PKGS}; do \
		[ -f "vendor/packages/${OS}-${VER}-${ARCH}/$$pkg" ] || curl -o "vendor/packages/${OS}-${VER}-${ARCH}/$$pkg" "http://pkg.${OS}.org/${ISO_OS}:11:${ARCH}/quarterly/All/$$pkg"; \
		xz -t "vendor/packages/${OS}-${VER}-${ARCH}/$$pkg"; \
	done

vendor/images/${OS}-${VER}-${ARCH}/CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH}: vendor/images/${OS}-${VER}-${ARCH}
	curl -o vendor/images/${OS}-${VER}-${ARCH}/CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH} -OJL "https://download.${OS}.org/ftp/releases/${ARCH}/${ARCH}/ISO-IMAGES/${VER}/CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH}"

vendor/images/${OS}-${VER}-${ARCH}/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso: vendor/images/${OS}-${VER}-${ARCH}/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz vendor/images/${OS}-${VER}-${ARCH}/CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH}
	xz -d --stdout vendor/images/${OS}-${VER}-${ARCH}/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz > vendor/images/${OS}-${VER}-${ARCH}/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso
	( \
		cd vendor/images/${OS}-${VER}-${ARCH}/; \
		grep "${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso)" CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH} | sha256sum -c - ; \
	)

vendor/images/${OS}-${VER}-${ARCH}/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz: vendor/images/${OS}-${VER}-${ARCH}/CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH}
	curl -o vendor/images/${OS}-${VER}-${ARCH}/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz -OJL "https://download.${OS}.org/ftp/releases/${ARCH}/${ARCH}/ISO-IMAGES/${VER}/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz"
	( \
		cd vendor/images/${OS}-${VER}-${ARCH}; \
		grep "${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz)" CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH} | sha256sum -c - ; \
	)

# Debian ISOs and other bits
secrets/debian-${VER}-${ARCH}/http/preseed.cfg: secrets/${OS}-${VER}-${ARCH}/env src/packer/http/${OS}-${VER}-${ARCH}/preseed.cfg secrets/${OS}-${VER}-${ARCH}/http
	test -n "${PROVISIONING_PASSWORD}"
	sed "s/PROVISIONING_PASSWORD/${PROVISIONING_PASSWORD}/" src/packer/http/${OS}-${VER}-${ARCH}/preseed.cfg > "$@"

vendor/images/${OS}-${VER}-${ARCH}/SHA256SUMS: vendor/images/${OS}-${VER}-${ARCH}
	curl -o "$@" "https://cdimage.debian.org/debian-cd/${VER}/${ARCH}/iso-cd/SHA256SUMS"

vendor/images/${OS}-${VER}-${ARCH}/${OS}-${VER}-${ISO_ARCH}-netinst.iso: vendor/images/${OS}-${VER}-${ARCH} vendor/images/${OS}-${VER}-${ARCH}/SHA256SUMS
	curl -o "$@" -OJL "https://cdimage.debian.org/debian-cd/${VER}/${ARCH}/iso-cd/${OS}-${VER}-${ISO_ARCH}-netinst.iso"
	( \
		cd vendor/images/${OS}-${VER}-${ARCH}; \
		grep "${OS}-${VER}-${ISO_ARCH}-netinst.iso" SHA256SUMS | sha256sum -c - ; \
	)
