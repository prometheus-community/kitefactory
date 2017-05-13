freebsd-11.0-amd64: build/freebsd-11.0-amd64/freebsd-11.0-amd64

clean:
	rm -rf build build/freebsd-11.0-amd64

clean-isos:
	rm -f vendor/images/CHECKSUM.SHA256-FreeBSD-11.0-RELEASE-amd64
	rm -f vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso
	rm -f vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso.xz

build/freebsd-11.0-amd64/freebsd-11.0-amd64: src/packer/freebsd-11.0-amd64.json vendor/images/FreeBSD-11.0-RELEASE-amd64-disc1.iso
	packer build src/packer/freebsd-11.0-amd64.json

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

