#!/bin/bash
# AMDY image: Bazzite-DX (ROCm, developer tools, Steam) plus what an agent-run
# machine needs. Everything user-level (models, amdy-llm, containers) lives in
# /var/home/andrew and the amdy-llm repo, not here.
set -ouex pipefail

cp -avf "/ctx/system_files"/. /

### NetBird client (official RPM repo). Updates arrive with each image rebuild,
### so the repo is disabled in the final image.
cat > /etc/yum.repos.d/netbird.repo <<'REPO'
[netbird]
name=netbird
baseurl=https://pkgs.netbird.io/yum/
enabled=1
gpgcheck=0
gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
repo_gpgcheck=1
REPO
# --setopt=tsflags=noscripts: the RPM's %post runs `netbird service install` and starts it,
# which fails in an image build; the unit ships in system_files instead.
dnf5 install -y --setopt=tsflags=noscripts netbird
sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/netbird.repo
systemctl enable netbird.service   # unit ships in system_files/etc/systemd/system

### Admin tools agents use
dnf5 install -y smartmontools dmidecode nvtop socat

### Fan control: CoolerControl + liquidctl from Terra (what `ujust install-coolercontrol`
### would layer, built in instead). Sensors come from nct6775 (system_files/usr/lib/modules-load.d).
dnf5 install -y --enablerepo=terra liquidctl coolercontrol coolercontrold
systemctl enable coolercontrold.service

### SSH: keys only, NetBird addresses only (see system_files/etc/ssh)
chmod 0644 /etc/ssh/authorized_keys.d/andrew
systemctl enable sshd.service

### Scoped passwordless sudo for agents (see system_files/etc/sudoers.d)
chmod 0440 /etc/sudoers.d/50-agents
visudo -cf /etc/sudoers.d/50-agents

systemctl enable podman.socket

### Docker ships in Bazzite-DX but we use podman; its socket fails without a docker group.
systemctl disable docker.socket docker.service
