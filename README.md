# Generating Machine Images

## Prerequisites

Depends on the following being available on the path:

- curl
- xz
- Packer
- Ansible

## Provisioning (e.g. Image Generator) Stack

### src/packer

Bootstrap VM creation (with QEMU) + provisioning with Ansible.

### src/ansible

Provision target VM for running Buildkite agent as unprivileged user.

## Using

You will need to set the following environment variables before building:

- `PROVISIONING_PASSWORD` - password for the root account in the new VM
- `BUILDKITE_TOKEN` - token given by Buildkite to configure the agent with

It is suggested to store them in `secrets/$machine-type/env` as shell
variables, and then sourcing them.  This will allow the Makefile to detect
changes and do the right thing.

Run `make machine-type` where machine-type is in:

- freebsd-11.0-amd64
- freebsd-11.1-amd64
- freebsd-11.1-i386

# Running

Take a look at the `$machine-type-run` target in the Makefile.  This makes
assumptions about the state of the VM host providing DHCP and routing of some
type.

It might be helpful to install libvirt, and use either virt-manager, or virsh
to attach and run multiple vms.
