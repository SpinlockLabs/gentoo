# Gentoo in a Container

Gentoo in a container, via systemd.

## Setup

Run the following command to setup your Gentoo container:

```bash
bash <(curl -s https://raw.githubusercontent.com/SpinlockLabs/gentoo/master/setup.sh)
```

## Usage

To start the container:

```bash
machinectl start gentoo
```

To start the container on system boot:

```bash
machinectl enable gentoo
```

To get a shell in the container:

```bash
machinectl shell gentoo
```

To mount a host directory into the container:

```bash
machinectl bind gentoo /path/to/host/dir /inside/container/dir
```

To stop the container:

```bash
machinectl terminate gentoo
```

## Removal

To remove the container, first stop the container, then run the following:

```bash
machinectl remove gentoo
```
