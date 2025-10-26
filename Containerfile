ARG SOURCE_REGISTRY="${SOURCE_REGISTRY:-quay.io}"
ARG SOURCE_IMAGE="${IMAGE_NAME:-fedora-kinoite}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora}"

ARG IMAGE_REGISTRY="${SOURCE_REGISTRY}/${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG IMAGE_VERSION="${IMAGE_VERSION:-latest}"


FROM ${IMAGE_REGISTRY}:${IMAGE_VERSION} AS base

LABEL org.opencontainers.image.description "Cloudvard's Atomik OS"
LABEL org.opencontainers.image.url https://github.com/cloudvard/atomik
LABEL org.opencontainers.image.source https://github.com/cloudvard/atomik
LABEL org.opencontainers.image.vendor Cloudvard
LABEL org.opencontainers.image.authors Cloudvard
LABEL org.opencontainers.image.title "Atomik OS"

ADD ./configs/ /

RUN dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN dnf install -y fish neovim aria2 lshw net-tools zstd fzf bat fd-find distrobox go
RUN dnf install -y code

RUN dnf group install -y multimedia
RUN dnf swap -y ffmpeg-free ffmpeg --allowerasing
RUN dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
RUN dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

RUN dnf install -y jetbrains-mono-fonts rsms-inter-fonts \
    google-go-mono-fonts fira-code-fonts mozilla-fira-sans-fonts
    
RUN dnf remove -y firefox firefox-langpacks

RUN dnf clean all

RUN systemctl disable flatpak-add-fedora-repos.service
RUN systemctl enable bootc-fetch-apply-updates.timer
RUN systemctl enable podman-auto-update.timer
RUN systemctl enable flatpak-system-update.timer
RUN systemctl enable flatpak-remove-fedora-repo.service
RUN systemctl --global enable flatpak-user-update.timer
RUN systemctl --global enable podman-auto-update.timer
RUN systemctl --global enable flatpak-add-flathub-repo.service

RUN bootc container lint


FROM base AS pro

LABEL org.opencontainers.image.description "Cloudvard's Atomik OS PRO Edition"
LABEL org.opencontainers.image.title "Atomik OS Pro"

RUN dnf group install -y virtualization

RUN dnf install -y coreutils attr findutils hostname iproute glibc-common systemd nfs-utils samba samba-common-tools corectrl libvirt-dbus

RUN dnf install -y cockpit-system cockpit-ws cockpit-ostree cockpit-podman cockpit-bridge \
    cockpit-machines cockpit-networkmanager cockpit-selinux cockpit-storaged cockpit-files

RUN dnf clean all

RUN bootc container lint