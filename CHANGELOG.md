# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-10-08

### Fixed
- `send_command` and `read_response` no longer call a CLIENT_SOCKET that has
  already failed or been closed by the server (that broke CLIENT_SOCKET's
  `is_connected` precondition once simple_net 1.2.0 made the socket real).
  A failed send now records `last_error` with the Winsock code.

### Added
- `TEST_SMTP_SESSION`: a full SMTP conversation over a real socket against a fake
  server (`SMTP_TEST_PEER`, a simple_net SERVER_SOCKET on its own SCOOP processor),
  and a send to a port nobody listens on. Before simple_net 1.2.0, `send` "succeeded"
  without opening a socket.
- The test target now monitors contracts (an extending target must repeat
  `<assertions>`) and uses SCOOP (`use="scoop"`) for the peer.

## [Unreleased]

### Changed
- Testing config updates, AutoTest fixes, .gitignore cleanup
- Add SCOOP concurrency capability
- Migrate to simple_testing library
- Remove redundant result_not_void postconditions
- Refactor to use simple_foundation_api
- Update docs and tests for UUID-based MIME boundary feature
- Add AUTH PLAIN authentication support
- Add Build Video link to README
- Add API reference documentation page
- Initial release: Native SMTP email sending library

## [1.0.0] - 2025-12-08

### Added
- Initial release
- Core functionality implemented
- Test suite with comprehensive coverage
- Documentation and examples

[Unreleased]: https://github.com/simple-eiffel/simple_smtp/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/simple-eiffel/simple_smtp/releases/tag/v1.0.0
