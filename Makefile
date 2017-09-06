freebsd-11.0-amd64: build/freebsd-11.0-amd64/freebsd-11.0-amd64.qcow2

freebsd-11.0-amd64-run:
	#qemu-system-x86_64 -drive file=build/freebsd-11.0-amd64/freebsd-11.0-amd64,if=virtio,cache=writeback,discard=ignore,format=qcow2 -netdev user,id=user.0,hostfwd=tcp::2228-:22 -boot once=d -m 512M -machine type=pc,accel=kvm -device virtio-net,netdev=user.0 -name freebsd-11.0-amd64 -display sdl -vnc 127.0.0.1:71
	qemu-system-x86_64 \
		-drive file=build/freebsd-11.0-amd64/freebsd-11.0-amd64.qcow2,if=virtio,cache=writeback,discard=ignore,format=qcow2 \
		-netdev tap,id=user.0 \
		-device virtio-net,netdev=user.0 \
		-boot once=d -m 2048M \
		-machine type=pc,accel=kvm \
		-name freebsd-11.0-amd64 \
		-nographic \
		-vnc 127.0.0.1:71

clean:
	rm -rf build/freebsd-11.0-amd64

clean-pkgs:
	rm -rf vendor/packages/freebsd-11.0-amd64

clean-isos:
	rm -f vendor/images/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-amd64
	rm -f vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso
	rm -f vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso.xz

build/freebsd-11.0-amd64/freebsd-11.0-amd64.qcow2: src/packer/freebsd-11.0-amd64.json secrets/freebsd-11.0-amd64/http/installerconfig vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso vendor/packages/freebsd-11.0-amd64
	PACKER_LOG=1 PACKER_KEY_INTERVAL=10ms packer build -on-error=ask -only=qemu src/packer/freebsd-11.0-amd64.json

secrets/freebsd-11.0-amd64:
	mkdir ${.TARGET}

secrets/freebsd-11.0-amd64/http:
	mkdir ${.TARGET}

secrets/http/freebsd-11.0-amd64/installerconfig: secrets/freebsd-11.0-amd64/env src/packer/http/freebsd-11.0-amd64/installerconfig.tpl secrets/freebsd-11.0-amd64/http
	test -n "${PROVISIONING_PASSWORD}"
	sed "s/PROVISIONING_PASSWORD/${PROVISIONING_PASSWORD}/" src/packer/http/freebsd-11.0-amd64/installerconfig.tpl > secrets/freebsd-11.0-amd64/http/installerconfig

vendor/packages/freebsd-11.0-amd64: Makefile
	mkdir -p vendor/packages/freebsd-11.0-amd64
	for pkg in pkg.txz pkg.txz.sig; do \
		[ -f "vendor/packages/freebsd-11.0-amd64/$$pkg" ] || curl -o "vendor/packages/freebsd-11.0-amd64/$$pkg" "http://pkg.freebsd.org/FreeBSD:11:amd64/quarterly/Latest/$$pkg"; \
	done
	for pkg in gettext-runtime-0.19.8.1_1.txz indexinfo-0.2.6.txz libffi-3.2.1.txz readline-6.3.8.txz python27-2.7.13_3.txz; do \
		[ -f "vendor/packages/freebsd-11.0-amd64/$$pkg" ] || curl -o "vendor/packages/freebsd-11.0-amd64/$$pkg" "http://pkg.freebsd.org/FreeBSD:11:amd64/quarterly/All/$$pkg"; \
		xz -t "vendor/packages/freebsd-11.0-amd64/$$pkg"; \
	done

vendor/images/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-amd64:
	curl -o vendor/images/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-amd64 -OJL "https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/11.0/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-amd64"

vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso: vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso.xz vendor/images/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-amd64
	xz -d --stdout vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso.xz > vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso
	( \
		cd vendor/images; \
		grep "FreeBSD-11.0-RELEASE-amd64-disc1.iso)" CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-amd64 | sha256sum -c - ; \
	)

vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso.xz: vendor/images/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-amd64
	curl -o vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso.xz -OJL "https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/11.0/FreeBSD-11.0-RELEASE-amd64-disc1.iso.xz"
	( \
		cd vendor/images; \
		grep "FreeBSD-11.0-RELEASE-amd64-disc1.iso.xz)" CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-amd64 | sha256sum -c - ; \
	)

vendor/images/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-i386:
	curl -o vendor/images/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-i386 -OJL "https://download.freebsd.org/ftp/releases/i386/i386/ISO-IMAGES/11.0/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-i386"

vendor/images/FreeBSD-11.0-RELEASE-i386-disc1.iso: vendor/images/FreeBSD-11.0-RELEASE-i386-disc1.iso.xz vendor/images/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-i386
	xz -d --stdout vendor/images/FreeBSD-11.0-RELEASE-i386-disc1.iso.xz > vendor/images/FreeBSD-11.0-RELEASE-i386-disc1.iso
	( \
		cd vendor/images; \
		grep "FreeBSD-11.0-RELEASE-i386-disc1.iso)" CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-i386 | sha256sum -c - ; \
	)

vendor/images/FreeBSD-11.0-RELEASE-i386-disc1.iso.xz: vendor/images/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-i386
	curl -o vendor/images/FreeBSD-11.0-RELEASE-i386-disc1.iso.xz -OJL "https://download.freebsd.org/ftp/releases/i386/i386/ISO-IMAGES/11.0/FreeBSD-11.0-RELEASE-i386-disc1.iso.xz"
	( \
		cd vendor/images; \
		grep "FreeBSD-11.0-RELEASE-i386-disc1.iso.xz)" CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-i386 | sha256sum -c - ; \
	)

