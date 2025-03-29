# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2024-03-29

### Fixed
- Added custom `build_access_token` method to properly handle DNSimple's OAuth2 token endpoint requirements
- Fixed compatibility with DNSimple's OAuth2 implementation

## [0.1.0] - 2024-03-29

### Added
- Initial release
- Basic OmniAuth strategy for DNSimple OAuth2 authentication
- Support for fetching account information through the DNSimple API 