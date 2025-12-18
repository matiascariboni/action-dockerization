# 🚀 Dockerization GitHub Action

This composite GitHub Action simplifies and automates the Dockerization process for your CI/CD workflows. It dynamically determines the Docker image tag, selects the appropriate Dockerfile, formats ports and networks for Docker Compose, and builds your image using Buildx with **intelligent cross-compilation detection**, support for multiple architectures, and optional layer caching.

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

7. **Automatically detects if cross-compilation is needed**
   - Compares runner architecture with target platform
   - Only enables QEMU emulation when necessary
   - Provides native builds for maximum performance when possible

8. **Builds the Docker image** with `buildx`, using the correct tag, Dockerfile, platform(s), and **optional layer caching** for faster builds.

9. **Provides detailed build summary** including architecture information, build type (native vs cross-compiled), and caching status.

---

## 📁 Required Files in Your Repository

Your repository must contain:

- ✅ A `Dockerfile` (default) **or** a `Dockerfile.<env_name>` matching the current Git ref.
- ✅ A valid Git structure to differentiate between environments and tags.
- 🔄 You don't need to include any Compose file — the filename is only generated and exposed as output in case it's useful in later workflow steps (e.g., for deployment scripts).

---

## 📦 Inputs

| Name           | Description                                                              | Required | Default                  |
| -------------- | ------------------------------------------------------------------------ | -------- | ------------------------ |
| `IMAGE_ARCH`   | Platform target for Docker Buildx (e.g., `linux/amd64`, `linux/arm64`)   | ✅ Yes    | -                        |
| `COMPOSE_NAME` | Prefix for the compose file name                                         | ✅ Yes    | -                        |
| `ENV_NAME`     | Environment name used to determine the correct Dockerfile                | ❌ No     | `${{ github.ref_name }}` |
| `CACHE`        | Enable Docker layer caching for faster builds (`'true'` or `'false'`)    | ❌ No     | `'true'`                 |
| `USE_QEMU`     | Enable QEMU for cross-platform builds (`'auto'`, `'true'`, or `'false'`) | ❌ No     | `'auto'`                 |

---

## 📤 Outputs

| Output name         | Description                                   |
| ------------------- | --------------------------------------------- |
| `IMAGE_NAME`        | Full image name in the format `<repo>_<env>`  |
| `COMPOSE_PORTS`     | Comma-separated port mappings from Dockerfile |
| `COMPOSE_NETWORKS`  | Comma-separated list of network names         |
| `COMPOSE_VOLUMES`   | Comma-separated list of volume mappings       |
| `COMPOSE_FILE_NAME` | Compose file name generated from repo and env |

---

## 🧪 Example Usage

### Basic Usage (With Cache - Recommended)
```yaml
jobs:
  dockerize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Dockerization
        id: dockerization
        uses: matiascariboni/action-dockerization@v2.0.0
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

### Native ARM64 Build (Self-Hosted Runner)
```yaml
jobs:
  dockerize:
    runs-on: [self-hosted, ARM64]
    steps:
      - uses: actions/checkout@v4

      - name: Dockerization (native ARM64)
        id: dockerization
        uses: matiascariboni/action-dockerization@v2.0.0
        with:
          IMAGE_ARCH: linux/arm64
          COMPOSE_NAME: my-app
          ENV_NAME: production
          CACHE: 'true'
          # USE_QEMU: 'auto' is default - will detect native build automatically

      - name: Print results
        run: |
          echo "Image: ${{ steps.dockerization.outputs.IMAGE_NAME }}"
```

### Multi-Architecture Build
```yaml
- name: Dockerization (multi-arch)
  uses: matiascariboni/action-dockerization@v2.0.0
  with:
    IMAGE_ARCH: linux/amd64,linux/arm64
    COMPOSE_NAME: my-app
    ENV_NAME: production
    CACHE: 'true'
    USE_QEMU: 'true'  # Required for multi-arch
```

### Cross-Compilation (Force QEMU)
```yaml
- name: Dockerization (ARM64 on x86 runner)
  uses: matiascariboni/action-dockerization@v2.0.0
  with:
    IMAGE_ARCH: linux/arm64
    COMPOSE_NAME: my-app
    ENV_NAME: production
    USE_QEMU: 'true'  # Explicitly enable QEMU
```

### Without Cache
```yaml
- name: Dockerization (no cache)
  uses: matiascariboni/action-dockerization@v2.0.0
  with:
    IMAGE_ARCH: linux/amd64
    COMPOSE_NAME: my-app
    ENV_NAME: production
    CACHE: 'false'
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

## ⚡ Smart Cross-Compilation Detection

The action automatically detects whether cross-compilation is needed:

### Native Build (Fast)
```yaml
Runner: ARM64 (aarch64)
Target: linux/arm64
Result: 🚀 Native build - No QEMU needed
Performance: Maximum speed
```

### Cross-Compilation (Slower)
```yaml
Runner: x86_64
Target: linux/arm64
Result: ⚠️  Cross-compilation - QEMU enabled
Performance: 5-10x slower than native
```

### How It Works

1. **Detects runner architecture** using `uname -m`
2. **Compares with target platform** from `IMAGE_ARCH`
3. **Enables QEMU only when needed** for cross-compilation
4. **Reports build type** in build summary

### USE_QEMU Options

| Value   | Behavior                                            |
| ------- | --------------------------------------------------- |
| `auto`  | (Default) Auto-detect based on runner vs target     |
| `true`  | Always enable QEMU (useful for multi-arch builds)   |
| `false` | Never use QEMU (fails if architectures don't match) |

---

## 🚀 Performance Benefits

### Native Builds vs Cross-Compilation

| Build Type        | Example                | Typical Time | Performance            |
| ----------------- | ---------------------- | ------------ | ---------------------- |
| **Native ARM64**  | ARM runner → ARM image | 5-8 min      | ⚡⚡⚡ Optimal            |
| **Native x86**    | x86 runner → x86 image | 5-8 min      | ⚡⚡⚡ Optimal            |
| **Cross-compile** | x86 runner → ARM image | 25-40 min    | 🐌 Slow (QEMU overhead) |

### Caching Benefits

Enabling the `CACHE` option can significantly reduce build times:

- **Without cache**: Full rebuild on every push (~10-15 minutes for Node.js apps)
- **With cache**: Only changed layers rebuild (~2-5 minutes for code changes)

#### Cache Savings Example:
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

#### Architecture-Aware Caching

The action uses **architecture-specific cache keys** to prevent conflicts:
```
Cache Key Format:
{OS}-buildx-{ARCH}-{ENV}-{SHA}

Examples:
Linux-buildx-aarch64-production-abc123
Linux-buildx-x86_64-production-abc123
```

This ensures ARM and x86 builds maintain separate caches.

---

## 📊 Build Summary

After each build, the action provides a comprehensive summary including:

**Example output (Native ARM64 Build):**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 BUILD SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Docker image built successfully

📊 Image Details:
   Name: my-app_production.tar
   Size: 450M (471859200 bytes)
   Tag: v1.2.3
   Platform: linux/arm64

🏗️  Build Configuration:
   Runner Architecture: aarch64
   Target Platform: linux/arm64
   Build Type: 🚀 Native (optimized)
   QEMU Emulation: No
   Docker Cache: Enabled ✅
   Cache Size: 1.2G

🔧 Compose Configuration:
   IMAGE_NAME: my-app_production
   COMPOSE_FILE_NAME: docker-compose.my-app.yml
   COMPOSE_PORTS: 80:3000
   COMPOSE_NETWORKS: my-network
   COMPOSE_VOLUMES: /app/data:/data

💾 Disk Space After Build:
   Available: 98G / 150G (35% used)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Example output (Cross-Compilation):**
```
🏗️  Build Configuration:
   Runner Architecture: x86_64
   Target Platform: linux/arm64
   Build Type: ⚠️  Cross-compilation
   QEMU Emulation: Yes
   Docker Cache: Enabled ✅
```

---

## 📝 Tips and Best Practices

### For Maximum Performance

1. **Use native runners when possible**
   - ARM64 target → Use ARM64 runners (GitHub-hosted or self-hosted)
   - x86 target → Use standard GitHub runners
   - This avoids QEMU overhead (5-10x speed improvement)

2. **Enable caching** for development and staging environments
   - Significantly reduces iteration time
   - Automatically architecture-aware

3. **Consider cache strategy by environment**
   - Development: `CACHE: 'true'` (fast iteration)
   - Production: `CACHE: 'true'` (still beneficial, ensures consistency)

4. **Use `USE_QEMU: 'auto'`** (default)
   - Automatically optimizes based on runner/target match
   - No manual configuration needed

### For Multi-Architecture Support

5. **Use matrix strategy** for building multiple architectures efficiently:
```yaml
   strategy:
     matrix:
       include:
         - arch: linux/amd64
           runner: ubuntu-latest
         - arch: linux/arm64
           runner: [self-hosted, ARM64]

   runs-on: ${{ matrix.runner }}
   steps:
     - uses: matiascariboni/action-dockerization@v2.0.0
       with:
         IMAGE_ARCH: ${{ matrix.arch }}
```

### Cache Maintenance

6. **Set up monthly cache cleanup** to prevent old caches from accumulating

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

## 🏃 Runner Recommendations

### For ARM64 Targets

| Option                  | Cost             | Build Time      | Setup  |
| ----------------------- | ---------------- | --------------- | ------ |
| **Self-hosted ARM64**   | ~$12-24/month    | ⚡ Fast (native) | Medium |
| **GitHub-hosted ARM64** | $0.006-0.008/min | ⚡ Fast (native) | None   |
| **x86 + QEMU**          | Free/included    | 🐌 Slow (5-10x)  | None   |

### For x86 Targets

| Option                | Cost            | Build Time      | Setup |
| --------------------- | --------------- | --------------- | ----- |
| **GitHub-hosted x86** | Free (2000 min) | ⚡ Fast (native) | None  |
| **ARM64 + QEMU**      | Variable        | 🐌 Slower        | None  |

**Recommendation:** Always match runner architecture to target architecture for best performance.

---

## 🔄 Migration from v1.x

### Breaking Changes

- `CACHE` now defaults to `'true'` (was `'false'`)
- Cache keys now include runner architecture
- New `USE_QEMU` input (defaults to `'auto'`)

### Migration Steps

1. Update action version:
```yaml
   # Before
   uses: matiascariboni/action-dockerization@v1.0.7

   # After
   uses: matiascariboni/action-dockerization@v2.0.0
```

2. (Optional) Explicitly set `CACHE` if you were relying on default `false`:
```yaml
   with:
     CACHE: 'false'  # Only if you specifically want no cache
```

3. (Optional) Configure QEMU behavior:
```yaml
   with:
     USE_QEMU: 'auto'  # Default, or 'true'/'false' for explicit control
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License.

---

❤️ Made with love by Matias Cariboni