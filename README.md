<div align="center">

# Megatools Docker

**A lightweight, multi-arch Alpine Docker image for [Megatools](https://xff.cz/megatools/), built from upstream source**

[![Build and Publish](https://github.com/mhajder/megatools-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/mhajder/megatools-docker/actions/workflows/docker-publish.yml)
[![Version](https://img.shields.io/github/v/tag/mhajder/megatools-docker?label=version&logo=github)](https://github.com/mhajder/megatools-docker/tags)
[![GHCR](https://img.shields.io/badge/GHCR-ghcr.io%2Fmhajder%2Fmegatools--docker-2496ED?logo=docker&logoColor=white)](https://github.com/mhajder/megatools-docker/pkgs/container/megatools-docker)
[![License](https://img.shields.io/github/license/mhajder/megatools-docker)](https://github.com/mhajder/megatools-docker/blob/main/LICENSE)

[![Megatools](https://img.shields.io/badge/Megatools-1.12.2-D9272E?logo=mega&logoColor=white)](https://xff.cz/megatools/)
[![Alpine](https://img.shields.io/badge/Alpine-3.24-0D597F?logo=alpinelinux&logoColor=white)](https://alpinelinux.org/)
[![Platforms](https://img.shields.io/badge/platform-linux%2Famd64%20%7C%20linux%2Farm64-555?logo=linux&logoColor=white)](https://github.com/mhajder/megatools-docker#-image-tags--architectures)
[![Stars](https://img.shields.io/github/stars/mhajder/megatools-docker?style=flat&logo=github)](https://github.com/mhajder/megatools-docker/stargazers)

[Features](https://github.com/mhajder/megatools-docker#-features) · [Quick Start](https://github.com/mhajder/megatools-docker#-quick-start) · [Usage](https://github.com/mhajder/megatools-docker#-usage) · [Tags & Architectures](https://github.com/mhajder/megatools-docker#-image-tags--architectures) · [Building](https://github.com/mhajder/megatools-docker#-building-locally)

</div>

A minimal container image for [Megatools](https://xff.cz/megatools/), the fast command-line client suite for [Mega.nz](https://mega.nz) cloud storage. Compiled directly from [upstream source tarballs](https://xff.cz/megatools/builds/) in a multi-stage Alpine Linux 3.24 build so new releases are available immediately without waiting for distro packaging.

## ✨ Features

- **Minimal runtime image**: Multi-stage `alpine:3.24` build with only runtime libraries (`glib`, `libcurl`, `ca-certificates`)
- **Upstream source builds & PGP verification**: Compiles directly from official [xff.cz/megatools](https://xff.cz/megatools/builds/) releases with `MEGATOOLS_VERSION` pinning and `.asc` PGP signature verification
- **Modern Megatools 1.12.x support**: Includes Two-Factor Authentication (`2fa`), `passwd`, `dl --list`, `put --overwrite`, and updated shared folder support
- **Compatibility symlinks**: Exposes both `megatools <cmd>` and legacy `mega*` symlinks (`megadl`, `megals`, `megaget`, `megaput`, `megacopy`, etc.)
- **Non-root by default**: Runs as unprivileged `megatools` user (`UID 10001`, `GID 10001`) in `/home/megatools`
- **Multi-arch & automated CI/CD**: GitHub Actions builds and publishes `linux/amd64` and `linux/arm64` images to GitHub Container Registry on semver git tags

## 🚀 Quick Start

Pull the latest image from GitHub Container Registry:

```bash
docker pull ghcr.io/mhajder/megatools-docker:latest
```

Verify available commands:

```bash
docker run --rm ghcr.io/mhajder/megatools-docker:latest --help
```

Download a public Mega.nz link into your current directory:

```bash
docker run --rm -v "$PWD/downloads:/home/megatools" \
  ghcr.io/mhajder/megatools-docker:latest \
  dl "https://mega.nz/file/YOUR_LINK"
```

## 💡 Usage

### Public Links

```bash
# Download a shared file or folder
docker run --rm -v "$PWD/downloads:/home/megatools" \
  ghcr.io/mhajder/megatools-docker:latest \
  dl "https://mega.nz/folder/YOUR_LINK"

# List contents and individual links inside a shared folder without downloading
docker run --rm ghcr.io/mhajder/megatools-docker:latest \
  dl --list "https://mega.nz/folder/YOUR_LINK"
```

### Account Operations

```bash
# Show cloud storage quota (prompts interactively for password / 2FA if needed)
docker run --rm -it ghcr.io/mhajder/megatools-docker:latest \
  df -h -u your@email.com

# List remote files
docker run --rm -it ghcr.io/mhajder/megatools-docker:latest \
  ls -l -u your@email.com /Root

# Upload a file (or replace an existing file with --overwrite)
docker run --rm -it -v "$PWD:/home/megatools" \
  ghcr.io/mhajder/megatools-docker:latest \
  put --overwrite -u your@email.com --path /Root/archive.tar.gz archive.tar.gz

# Download from your account
docker run --rm -it -v "$PWD/downloads:/home/megatools" \
  ghcr.io/mhajder/megatools-docker:latest \
  get -u your@email.com /Root/archive.tar.gz
```

### Two-Factor Authentication & Configuration

Avoid passing credentials on the command line by mounting a `.megarc` file (`chmod 600 .megarc`):

```ini
[Login]
Username = your@email.com
Password = your-password
# Optional base32 secret from `megatools 2fa --setup`
# TwoFactorSecret = YOURBASE32SECRET
```

Mount `.megarc` (and optionally a persistent `/home/megatools/.cache` volume so Megatools can reuse your authenticated session):

```bash
docker run --rm \
  -v "$PWD/.megarc:/home/megatools/.megarc:ro" \
  -v megatools-cache:/home/megatools/.cache \
  -v "$PWD/downloads:/home/megatools/downloads" \
  ghcr.io/mhajder/megatools-docker:latest \
  ls /Root
```

> [!TIP]
> You can manage 2FA directly from the container using `megatools 2fa --setup` / `--enable` / `--disable`, or update your account password with `megatools passwd`.

## 🏷️ Image Tags & Architectures

Images are published to `ghcr.io/mhajder/megatools-docker` for:

| Architecture  | Platform       |
|---------------|----------------|
| `x86_64`      | `linux/amd64`  |
| `aarch64`     | `linux/arm64`  |

Available tag formats on release tags (e.g., `1.12.2`):

| Tag       | Description                                 |
|-----------|---------------------------------------------|
| `1.12.2`  | Exact Megatools release version             |
| `1.12`    | Latest patch within the `1.12` minor series |
| `1`       | Latest release within the `1` major series  |
| `latest`  | Latest release built from `main`            |
| `<sha>`   | Short git commit SHA                        |

## 🛠️ Building Locally

```bash
# Build with default version (1.12.2)
docker build -t megatools .

# Build a specific upstream release from https://xff.cz/megatools/builds/
docker build --build-arg MEGATOOLS_VERSION=1.12.2 -t megatools:1.12.2 .

# Build with a custom UID/GID matching your host user
docker build --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" -t megatools:1.12.2 .
```

## 🔒 Security & Permissions

- The container runs as non-root user `megatools` (`UID 10001`, `GID 10001`) with `WORKDIR /home/megatools`.
- When bind-mounting a host directory for downloads or uploads, ensure the directory is writable by UID `10001` (or pass `--user "$(id -u):$(id -g)"` to `docker run`).

> [!NOTE]
> Running with `--user "$(id -u):$(id -g)"` ensures downloaded files match your host user's ownership, and works cleanly as long as you pass `-u`/`--config` or mount `.megarc` explicitly.

## 📄 License

[GPL-2.0](LICENSE) — [Megatools](https://xff.cz/git/megatools/tree/LICENSE) and this repository are licensed under GPL-2.0.
