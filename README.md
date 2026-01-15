# Megatools Docker

A lightweight Docker image for [Megatools](https://xff.cz/megatools/), a command-line client for Mega.nz file storage.

## Features

- **Minimal image**: Based on Alpine Linux
- **Version pinning**: Install specific Megatools versions from Alpine testing repository
- **Non-root user**: Runs as unprivileged `megatools` user (UID 1000)
- **Multi-arch builds**: Supports `linux/amd64` and `linux/arm64`
- **Automated CI/CD**: GitHub Actions builds and publishes to GitHub Container Registry on git tags

## Usage

### Pull from GitHub Container Registry

```bash
docker pull ghcr.io/mhajder/megatools-docker:latest
```

### Build locally

```bash
# Build with default version
docker build -t megatools .

# Build with specific version that exists in Alpine testing repo
docker build --build-arg MEGATOOLS_VERSION=1.11.5 -t megatools:1.11.5 .
```

### Run

```bash
# Show help
docker run --rm megatools --help

# Download a file
docker run --rm -v ./downloads:/home/megatools megatools dl "https://mega.nz/#!YOUR_LINK"

# Login and list files
docker run --rm -it megatools login your@email.com
```

## License

[GPL-2.0](LICENSE) - [Megatools](https://xff.cz/git/megatools/tree/LICENSE) and this repo license