# 🚀 Dockerization GitHub Action

This composite GitHub Action simplifies and automates the Dockerization process for your CI/CD workflows. It dynamically determines the Docker image tag, selects the appropriate Dockerfile, formats ports and networks for Docker Compose, and builds your image using Buildx with support for multiple architectures and optional layer caching.

---

## 🔧 What It Does

This action performs the following tasks:

1. **Detects whether the push is a tag or a branch**
   → If it's a tag: uses the tag name as Docker tag.
   → If it's a branch: uses the short commit hash as Docker tag.

2. **Resolves the appropriate Dockerfile** based on environment name:
   - If a file named `Dockerfile.<environment>` exists (e.g., `Dockerfile.dev`), it uses that.
   - Otherwise, it falls back to the default `Dockerfile`.

3. **Generates the Docker Compose file name** using the repository name and environment.

4. **Extracts and formats ports** from the Dockerfile for Compose using custom comment syntax like:
   ```Dockerfile
   EXPOSE 3000
   # TO 80
   ```
   ➤ This will map `3000` to `80` in Compose.

5. **Parses networks** from comments like:
   ```Dockerfile
   # NETWORK my-network
   ```

6. **Parses volumes** from comments like:
   ```Dockerfile
   # VOLUME /data:/app/data
   ```

7. **Builds the Docker image** with `buildx`, using the correct tag, Dockerfile, platform(s), and **optional layer caching** for faster builds.

8. **Provides caching recommendations** to help optimize your CI/CD pipeline.

---

## 📁 Required Files in Your Repository

Your repository must contain:

- ✅ A `Dockerfile` (default) **or** a `Dockerfile.<env_name>` matching the current Git ref.
- ✅ A valid Git structure to differentiate between environments and tags.
- 🔄 You don't need to include any Compose file — the filename is only generated and exposed as output in case it's useful in later workflow steps (e.g., for deployment scripts).

---

## 📦 Inputs

| Name           | Description                                                                     | Required | Default                |
| -------------- | ------------------------------------------------------------------------------- | -------- | ---------------------- |
| `IMAGE_ARCH`   | Platform target for Docker Buildx (e.g., `linux/amd64`, `linux/arm64`)          | ✅ Yes   | -                      |
| `COMPOSE_NAME` | Prefix for the compose file name                                                | ✅ Yes   | -                      |
| `ENV_NAME`     | Environment name used to determine the correct Dockerfile                       | ❌ No    |`${{ github.ref_name }}`|
| `CACHE`        | Enable Docker layer caching for faster builds (`'true'` or `'false'`)           | ❌ No    | `'false'`              |

---

## 📤 Outputs

| Output name         | Description                                         |
| ------------------- | --------------------------------------------------- |
| `IMAGE_NAME`        | Full image name in the format `<repo>_<env>`        |
| `COMPOSE_PORTS`     | Comma-separated port mappings from Dockerfile       |
| `COMPOSE_NETWORKS`  | Comma-separated list of network names               |
| `COMPOSE_VOLUMES`   | Comma-separated list of volume mappings             |
| `COMPOSE_FILE_NAME` | Compose file name generated from repo and env       |

---

## 🧪 Example Usage

### Basic Usage (Without Cache)

```yaml
jobs:
  dockerize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Dockerization
        id: dockerization
        uses: matiascariboni/action-dockerization@v1.0.7
        with:
          IMAGE_ARCH: linux/amd64
          COMPOSE_NAME: my-app
          ENV_NAME: production

      - name: Print results
        run: |
          echo "Image: ${{ steps.dockerization.outputs.IMAGE_NAME }}"
          echo "Compose file: ${{ steps.dockerization.outputs.COMPOSE_FILE_NAME }}"
          echo "Ports: ${{ steps.dockerization.outputs.COMPOSE_PORTS }}"
          echo "Networks: ${{ steps.dockerization.outputs.COMPOSE_NETWORKS }}"
```

### With Layer Caching (Recommended for Faster Builds)

```yaml
jobs:
  dockerize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Dockerization with cache
        id: dockerization
        uses: matiascariboni/action-dockerization@v1.0.7
        with:
          IMAGE_ARCH: linux/arm64
          COMPOSE_NAME: my-app
          ENV_NAME: production
          CACHE: 'true'

      - name: Print results
        run: |
          echo "Image: ${{ steps.dockerization.outputs.IMAGE_NAME }}"
```

### Multi-Architecture Build

```yaml
- name: Dockerization (multi-arch)
  uses: matiascariboni/action-dockerization@v1.0.7
  with:
    IMAGE_ARCH: linux/amd64,linux/arm64
    COMPOSE_NAME: my-app
    ENV_NAME: production
    CACHE: 'true'
```

---

## 🎯 Dockerfile Comment Syntax

This action uses special comments in your Dockerfile to extract metadata for Docker Compose:

### Port Mapping

```Dockerfile
EXPOSE 3000
# TO 80
```

This will generate: `80:3000` in the Compose ports section.

### Network Assignment

```Dockerfile
# NETWORK my-network
```

This will assign the container to `my-network` in Compose.

### Volume Mapping

```Dockerfile
# VOLUME /host/path:/container/path
```

This will create a volume mapping in Compose.

---

## 🚀 Performance Benefits with Caching

Enabling the `CACHE` option can significantly reduce build times:

- **Without cache**: Full rebuild on every push (~10-15 minutes for Node.js apps)
- **With cache**: Only changed layers rebuild (~2-5 minutes for code changes)

### Cache Savings Example:

```
Scenario 1: Code change (no dependency changes)
├─ npm ci layer:      ✅ CACHED (saves 5-7 minutes)
├─ Build layer:       ❌ Rebuilt (necessary)
└─ Total time:        ~3 minutes (instead of 10+)

Scenario 2: Dependency change
├─ npm ci layer:      ❌ Rebuilt (necessary)
├─ Build layer:       ❌ Rebuilt (necessary)
└─ Total time:        ~10 minutes
```

### Cache Maintenance

When using caching, it's recommended to set up a scheduled workflow to clean old caches periodically. This prevents cache accumulation and ensures fresh system packages.

**Example cleanup workflow** (`.github/workflows/cache-cleanup.yml`):

```yaml
name: Monthly Cache Cleanup

on:
  schedule:
    - cron: '0 3 1 * *'  # First day of each month at 3 AM UTC
  workflow_dispatch:

permissions:
  actions: write

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cleanup buildx caches
        run: |
          gh extension install actions/gh-actions-cache

          cacheKeys=$(gh actions-cache list -R $REPO | cut -f 1)

          for cacheKey in $cacheKeys; do
            if [[ $cacheKey == *"buildx"* ]]; then
              echo "Deleting cache: $cacheKey"
              gh actions-cache delete $cacheKey -R $REPO --confirm
            fi
          done
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          REPO: ${{ github.repository }}
```

---

## 📊 Build Summary

After each build, the action provides a comprehensive summary including:

- ✅ Build status and validation
- 📦 Image file size (human-readable and bytes)
- 🔧 All configuration outputs (ports, networks, volumes)
- 💾 Available disk space after build
- ⚡ Cache status and recommendations (when caching is enabled)

This information is crucial for:
- Troubleshooting deployment issues
- Monitoring image size growth over time
- Verifying configuration before deployment
- Ensuring sufficient disk space on target servers

**Example output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 BUILD SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Docker image built successfully

📊 Image Details:
   Name: my-app_production.tar
   Size: 450M (471859200 bytes)
   Tag: v1.2.3

🔧 Configuration Outputs:
   IMAGE_NAME: my-app_production
   COMPOSE_FILE_NAME: my-app_production.yml
   COMPOSE_PORTS: 80:3000
   COMPOSE_NETWORKS: my-network
   COMPOSE_VOLUMES: ./data:/app/data
```

---

## 📝 Tips and Best Practices

1. **Enable caching for development environments** to speed up iteration cycles
2. **Consider disabling cache for production deployments** if you need guaranteed fresh builds
3. **Set up monthly cache cleanup** to prevent old caches from accumulating
4. **Monitor cache hit rates** in your workflow logs to ensure caching is effective
5. **Use environment-specific caches** (handled automatically via `ENV_NAME`)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License.

---

❤️ Made with love by Matias Cariboni