# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2024-12-18

### Added
- **Smart cross-compilation detection**: Automatically detects if QEMU is needed by comparing runner architecture with target platform
- `USE_QEMU` input parameter with three modes: `'auto'` (default), `'true'`, `'false'`
- `detect_qemu.sh` script for intelligent architecture detection
- Runner architecture reporting in build summary
- Build type indication (Native vs Cross-compilation) in build summary
- QEMU emulation status in build summary
- Architecture-aware cache keys to prevent conflicts between ARM64 and x86_64 builds
- Platform information in Image Details section of build summary

### Changed
- **BREAKING:** `CACHE` now defaults to `'true'` (was `'false'` in v1.x)
- **BREAKING:** Cache keys now include runner architecture for better isolation
- QEMU is now only enabled when cross-compilation is detected (huge performance improvement for native builds)
- Docker Buildx setup simplified - removed unnecessary driver-opts
- Enhanced build summary with comprehensive architecture and performance information
- Improved cache restore-keys to include architecture hierarchy

### Performance
- **Native builds are now 5-10x faster** by avoiding unnecessary QEMU emulation
- ARM64 builds on ARM64 runners: 5-8 minutes (vs 25-40 minutes with QEMU)
- x86 builds on x86 runners: 5-8 minutes (unchanged, still optimal)
- Architecture-specific caching prevents cache corruption and improves hit rates

### Documentation
- Added comprehensive architecture detection documentation
- Added runner recommendations for ARM64 and x86 targets
- Added performance comparison table (native vs cross-compilation)
- Added migration guide from v1.x to v2.0.0
- Added examples for native ARM64 builds with self-hosted runners
- Added USE_QEMU configuration options and use cases

### Migration Guide (v1.0.x → v2.0.0)

**Breaking Changes:**
1. Cache now enabled by default
2. Cache keys include architecture
3. QEMU behavior changed to auto-detection

**Before (v1.0.7):**
```yaml
- name: Docker build
  uses: matiascariboni/action-dockerization@v1.0.7
  with:
    IMAGE_ARCH: linux/arm64
    COMPOSE_NAME: my-app
    ENV_NAME: production
    CACHE: 'false'  # Default was false
```

**After (v2.0.0):**
```yaml
- name: Docker build
  uses: matiascariboni/action-dockerization@v2.0.0
  with:
    IMAGE_ARCH: linux/arm64
    COMPOSE_NAME: my-app
    ENV_NAME: production
    # CACHE: 'true' is now default
    # USE_QEMU: 'auto' is default - automatically detects if needed
```

**For native ARM64 builds (NEW - recommended):**
```yaml
jobs:
  build:
    runs-on: [self-hosted, ARM64]  # Use ARM64 runner
    steps:
      - uses: matiascariboni/action-dockerization@v2.0.0
        with:
          IMAGE_ARCH: linux/arm64
          COMPOSE_NAME: my-app
          # Auto-detects native build - no QEMU needed!
```

**If you want old behavior (cache disabled):**
```yaml
- uses: matiascariboni/action-dockerization@v2.0.0
  with:
    IMAGE_ARCH: linux/arm64
    COMPOSE_NAME: my-app
    CACHE: 'false'  # Explicitly disable
```

## [1.0.7] - 2024-11-11

### Added
- Build summary step displaying comprehensive build information
- Image size reporting (human-readable and bytes)
- Disk space availability check after build
- Configuration outputs display in build summary
- Build status validation with error reporting

### Changed
- Enhanced build process visibility with detailed summary output
- Improved troubleshooting capabilities with size and configuration data

## [1.0.6] - 2024-10-16

### Changed
- `ENV_NAME` isn't required anymore. Branch name will be the default value on that case.

## [1.0.5] - 2024-10-02

### Added
- `CACHE` boolean input to enable/disable Docker layer caching (default: `'false'`)
- Automatic cache management fully integrated within the action
- Cache status notifications with recommendations after each build
- Automatic cache restoration and saving (when enabled)
- Automatic cache cleanup/move after build completion
- Conditional build steps based on cache setting for optimized workflow execution

### Changed
- **BREAKING (Minor):** Replaced `CACHE_FROM` and `CACHE_TO` inputs with simplified `CACHE` boolean input
- Cache management is now fully internal - users don't need to manage cache paths or GitHub Actions cache setup manually
- Users must explicitly opt-in to caching by setting `CACHE: 'true'`

### Removed
- `CACHE_FROM` input (replaced by automatic internal handling)
- `CACHE_TO` input (replaced by automatic internal handling)

### Documentation
- Added comprehensive caching guide in README
- Added cache cleanup workflow example
- Added performance comparison with/without cache
- Added tips and best practices section

### Migration Guide (v1.0.4 → v1.0.5)

**Before (v1.0.4):**
```yaml
- name: Cache Docker layers
  uses: actions/cache@v4
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ needs.resolve-env.outputs.env_name }}-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-buildx-${{ needs.resolve-env.outputs.env_name }}-

- name: Docker build
  uses: matiascariboni/action-dockerization@v1.0.4
  with:
    IMAGE_ARCH: linux/arm64
    COMPOSE_NAME: my-app
    ENV_NAME: production
    CACHE_FROM: type=local,src=/tmp/.buildx-cache
    CACHE_TO: type=local,dest=/tmp/.buildx-cache-new,mode=max

- name: Move cache
  if: always()
  run: |
    rm -rf /tmp/.buildx-cache
    mv /tmp/.buildx-cache-new /tmp/.buildx-cache
```

**After (v1.0.5) - Without Cache:**
```yaml
- name: Docker build
  uses: matiascariboni/action-dockerization@v1.0.5
  with:
    IMAGE_ARCH: linux/arm64
    COMPOSE_NAME: my-app
    ENV_NAME: production
    # No CACHE input = disabled by default
```

**After (v1.0.5) - With Cache:**
```yaml
- name: Docker build
  uses: matiascariboni/action-dockerization@v1.0.5
  with:
    IMAGE_ARCH: linux/arm64
    COMPOSE_NAME: my-app
    ENV_NAME: production
    CACHE: 'true'  # Explicitly enable caching
```

## [1.0.4] - 2024-10-02

### Added
- `CACHE_FROM` input parameter for Docker buildx cache source (optional)
- `CACHE_TO` input parameter for Docker buildx cache destination (optional)
- Docker layer caching support for significantly faster builds
- Comprehensive documentation with caching examples in README

### Changed
- Enhanced README with performance benefits section
- Updated examples to include cache usage patterns

### Performance
- Builds with unchanged dependencies now use cached layers (5-7 minutes saved on average)
- Only changed layers are rebuilt, dramatically improving CI/CD pipeline speed

## [1.0.3]

### Fixed
- Minor bug fixes and stability improvements

## [1.0.2]

### Added
- `ENV_NAME` input added in order to be compatible with the new environments functions on Github repositories

## [1.0.1]

### Fixed
- Bug fixes and improvements

## [1.0.0]

### Added
- Initial release of Dockerization action
- Automatic Docker tag detection (tag name or commit hash)
- Environment-specific Dockerfile resolution (`Dockerfile.<env>`)
- Port extraction and formatting from Dockerfile comments
- Network extraction from Dockerfile comments
- Volume extraction from Dockerfile comments
- Docker Compose file name generation
- Multi-architecture build support with buildx
- QEMU setup for cross-platform builds


[Unreleased]: https://github.com/matiascariboni/action-dockerization/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.7...v2.0.0
[1.0.7]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.6...v1.0.7
[1.0.6]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.5...v1.0.6
[1.0.5]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/matiascariboni/action-dockerization/releases/tag/v1.0.0