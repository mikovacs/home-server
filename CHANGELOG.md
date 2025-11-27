# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added `.dockerignore` file to exclude unnecessary files from Docker context
- Added `update.sh` script for easy service updates
- Added `backup.sh` script with encrypted `.env` backup functionality
- Added `make update` command to [`Makefile`](Makefile)
- Added `make backup` command to [`Makefile`](Makefile)
- Added health checks to all services in [`docker-compose.yml`](docker-compose.yml)
- Added PUID/PGID environment variables to [`.env.example`](.env.example)
- Enhanced [`scripts/show-status.sh`](scripts/show-status.sh) with service health and recent logs
- Enhanced [`scripts/audit-env.sh`](scripts/audit-env.sh) with TZ and PUID/PGID validation
- Comprehensive documentation updates:
  - Added backup/restore procedures to [`README.md`](README.md)
  - Added update procedures to [`README.md`](README.md)
  - Added troubleshooting section to [`README.md`](README.md)
  - Added system requirements section to [`README.md`](README.md)
  - Added backup encryption requirements to [`SECURITY.md`](SECURITY.md)
  - Added incident response procedures to [`SECURITY.md`](SECURITY.md)
  - Added regular maintenance schedule to [`SECURITY.md`](SECURITY.md)

### Changed

- Removed `PLEX_CLAIM` environment variable from [`docker-compose.yml`](docker-compose.yml) - Plex claim token no longer required in configuration
- Fixed kids media volume paths in [`docker-compose.yml`](docker-compose.yml):
  - `media_kidsMovies` now correctly points to `/mnt/external-hdd/media/movies/kids_movies`
  - `media_kidsTV` now correctly points to `/mnt/external-hdd/media/tv/kids_tv`

### Removed

- Removed `PLEX_CLAIM` validation check from [`scripts/audit-env.sh`](scripts/audit-env.sh) security audit script

## [1.0.0] - Initial Release

### Added

- Docker Compose setup with Plex, qBittorrent, and Cloudflare Tunnel services
- Interactive setup script ([`scripts/start.sh`](scripts/start.sh)) with environment validation
- External HDD setup and management script ([`scripts/setup-hdd.sh`](scripts/setup-hdd.sh))
- Status monitoring script ([`scripts/show-status.sh`](scripts/show-status.sh))
- Security audit tool ([`scripts/audit-env.sh`](scripts/audit-env.sh))
- Makefile commands for easy service management
- Comprehensive security documentation in [`SECURITY.md`](SECURITY.md)
- User guide in [`README.md`](README.md)
