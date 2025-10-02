# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.4...HEAD
[1.0.4]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/matiascariboni/action-dockerization/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/matiascariboni/action-dockerization/releases/tag/v1.0.0
