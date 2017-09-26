.POSIX:
.SUFFIXES:

.PHONY: freebsd-11.1-amd64
freebsd-11.1-amd64:
	$(MAKE) \
		OS=freebsd \
		ISO_OS=FreeBSD VER=11.1 \
		ARCH=amd64 \
		PKGS="gettext-runtime-0.19.8.1_1.txz indexinfo-0.2.6.txz libffi-3.2.1.txz readline-7.0.3.txz python27-2.7.13_7.txz" \
		image

.PHONY: freebsd-11.1-i386
freebsd-11.1-i386:
	$(MAKE) \
		OS=freebsd \
		ISO_OS=FreeBSD VER=11.1 \
		ARCH=i386 \
		PKGS="gettext-runtime-0.19.8.1_1.txz indexinfo-0.2.6.txz libffi-3.2.1.txz readline-7.0.3.txz python27-2.7.13_7.txz" \
		image

.PHONY: freebsd-11.0-i386
freebsd-11.0-amd64:
	$(MAKE) \
		OS=freebsd \
		ISO_OS=FreeBSD VER=11.0 \
		ARCH=amd64 \
		PKGS="gettext-runtime-0.19.8.1_1.txz indexinfo-0.2.6.txz libffi-3.2.1.txz readline-6.3.8.txz python27-2.7.13_3.txz" \
		image

.PHONY: image
image: build/${OS}-${VER}-${ARCH}/${OS}-${VER}-${ARCH}.qcow2

.PHONY: ${OS}-${VER}-${ARCH}-run
${OS}-${VER}-${ARCH}-run:
	#qemu-system-x86_64 -drive file=build/${OS}-${VER}-${ARCH}/${OS}-${VER}-${ARCH},if=virtio,cache=writeback,discard=ignore,format=qcow2 -netdev user,id=user.0,hostfwd=tcp::2228-:22 -boot once=d -m 512M -machine type=pc,accel=kvm -device virtio-net,netdev=user.0 -name ${OS}-${VER}-${ARCH} -display sdl -vnc 127.0.0.1:71
	qemu-system-x86_64 \
		-drive file=build/${OS}-${VER}-${ARCH}/${OS}-${VER}-${ARCH}.qcow2,if=virtio,cache=writeback,discard=ignore,format=qcow2 \
		-netdev tap,id=user.0 \
		-device virtio-net,netdev=user.0 \
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

build/${OS}-${VER}-${ARCH}/${OS}-${VER}-${ARCH}.qcow2: src/packer/${OS}-${VER}-${ARCH}.json secrets/${OS}-${VER}-${ARCH}/http/installerconfig vendor/images/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso vendor/packages/${OS}-${VER}-${ARCH}
	PACKER_LOG=1 PACKER_KEY_INTERVAL=10ms packer build -on-error=ask -only=qemu -var-file=src/packer/${OS}-${VER}-${ARCH}.json src/packer/${OS}.json

secrets/${OS}-${VER}-${ARCH}:
	mkdir -p $@

secrets/${OS}-${VER}-${ARCH}/http: secrets/${OS}-${VER}-${ARCH}
	mkdir -p $@

secrets/${OS}-${VER}-${ARCH}/env: secrets/${OS}-${VER}-${ARCH}

secrets/${OS}-${VER}-${ARCH}/http/installerconfig: secrets/${OS}-${VER}-${ARCH}/env src/packer/http/${OS}-${VER}-${ARCH}/installerconfig.tpl secrets/${OS}-${VER}-${ARCH}/http
	test -n "${PROVISIONING_PASSWORD}"
	sed "s/PROVISIONING_PASSWORD/${PROVISIONING_PASSWORD}/" src/packer/http/${OS}-${VER}-${ARCH}/installerconfig.tpl > secrets/${OS}-${VER}-${ARCH}/http/installerconfig

vendor/packages/${OS}-${VER}-${ARCH}: Makefile
	mkdir -p vendor/packages/${OS}-${VER}-${ARCH}
	for pkg in pkg.txz pkg.txz.sig; do \
		[ -f "vendor/packages/${OS}-${VER}-${ARCH}/$$pkg" ] || curl -o "vendor/packages/${OS}-${VER}-${ARCH}/$$pkg" "http://pkg.${OS}.org/${ISO_OS}:11:${ARCH}/quarterly/Latest/$$pkg"; \
	done
	for pkg in ${PKGS}; do \
		[ -f "vendor/packages/${OS}-${VER}-${ARCH}/$$pkg" ] || curl -o "vendor/packages/${OS}-${VER}-${ARCH}/$$pkg" "http://pkg.${OS}.org/${ISO_OS}:11:${ARCH}/quarterly/All/$$pkg"; \
		xz -t "vendor/packages/${OS}-${VER}-${ARCH}/$$pkg"; \
	done

vendor/images/CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH}:
	curl -o vendor/images/CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH} -OJL "https://download.${OS}.org/ftp/releases/${ARCH}/${ARCH}/ISO-IMAGES/${VER}/CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH}"

vendor/images/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso: vendor/images/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz vendor/images/CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH}
	xz -d --stdout vendor/images/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz > vendor/images/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso
	( \
		cd vendor/images; \
		grep "${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso)" CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH} | sha256sum -c - ; \
	)

vendor/images/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz: vendor/images/CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH}
	curl -o vendor/images/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz -OJL "https://download.${OS}.org/ftp/releases/${ARCH}/${ARCH}/ISO-IMAGES/${VER}/${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz"
	( \
		cd vendor/images; \
		grep "${ISO_OS}-${VER}-RELEASE-${ARCH}-disc1.iso.xz)" CHECKSUM.SHA256-${ISO_OS}-${VER}-RELEASE-${ARCH} | sha256sum -c - ; \
	)
