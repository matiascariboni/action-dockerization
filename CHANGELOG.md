# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.6...HEAD
[1.0.6]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.5...v1.0.6
[1.0.5]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/matiascariboni/action-dockerization/releases/tag/v1.0.0