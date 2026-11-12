# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2025-11-03

### Fixed
- **Critical**: Fixed socket cleanup order to prevent "StreamSink is bound to a stream" errors
  - Socket now closes BEFORE stream subscription is cancelled
  - Prevents retry failures after initial errors
- **Critical**: Fixed operation lock deadlock when timeouts occur outside `_sendReceive()`
  - Added mandatory `finally` block to always release operation lock
  - Prevents devices from hanging indefinitely after errors
- **Critical**: Fixed error recovery by always closing socket on ANY error
  - Ensures clean state for next operation after failures
  - Socket and receive buffer corruption no longer persists across operations
- Fixed version-specific timeout handling for v3.4 and v3.5 devices
  - v3.3: 500ms timeout (simple protocol)
  - v3.4: 1000ms timeout (+ session key negotiation overhead)
  - v3.5: 1500ms timeout (+ GCM encryption overhead)

### Added
- Comprehensive integration test suite with real device testing
  - `test/integration/stress_test.dart` - Validates error recovery across all protocol versions
  - `test/integration/persist_modes_test.dart` - Tests socket persistence modes
  - `test/integration/socket_behavior_test.dart` - Verifies socket state management
  - `test/integration/session_timeout_test.dart` - Tests idle timeout reconnection
  - `test/integration/test_helpers.dart` - Shared test utilities
  - `test/integration/devices.json.example` - Template for device configuration
- Retry logic for unreliable v3.3 devices in stress tests
- AGENTS.md documentation for AI coding agents
  - Architecture overview and critical patterns
  - Protocol version differences and gotchas
  - Common issues and solutions
  - Development workflow guidance

### Changed
- Improved error messages with operation timeouts to include timeout duration
- Integration tests now gracefully skip when devices.json is missing

### Technical Details
- All device operations flow through single `_sendReceive()` code path
- Operation locking prevents concurrent operations that corrupt receive buffer
- Socket cleanup follows strict order: close socket → cancel subscription → clear buffers
- Error recovery pattern: ANY error → close socket → return error → next operation gets clean state
- Stress test achieves 100% success rate across v3.3, v3.4, and v3.5 devices

## [0.1.0] - 2025-01-30

### Added
- Complete Tuya protocol support (v3.1, v3.3, v3.4, v3.5)
- AES encryption (ECB for v3.1-v3.4, GCM for v3.5)
- Message packing and unpacking for all protocol versions
- Device class for direct LAN communication
- OutletDevice class with dimmer control
- BulbDevice class with full RGB/HSV color control
- CoverDevice class for blinds and curtains
- UDP device scanner with multi-port listening
- Cloud API client with OAuth2 authentication
- Device discovery and management via cloud
- Comprehensive test suite (56+ tests)
- Python TinyTuya comparison tests for validation
- Support for all Tuya cloud regions (US, EU, CN, IN, SG)
- HMAC-SHA256 signature generation for cloud API
- Auto-detection of bulb types (A, B, C)
- Color conversion utilities (RGB ↔ HSV)
- Status caching for efficient device communication
- Socket persistence control via `persist` parameter (matches Python's `socketPersistent`)
- Automatic session timeout detection and reconnection
- Session key negotiation for v3.4+ devices

### Technical Details
- Byte-for-byte compatible with Python TinyTuya
- Uses `cryptography` package for reliable AES-GCM
- Supports both 55AA (v3.1-v3.4) and 6699 (v3.5) message formats
- Automatic retcode detection in message unpacking
- UDP broadcast decryption for all protocol versions
- Token refresh handling in cloud API

### Documentation
- Comprehensive README with examples
- API documentation in code
- Multiple usage examples
- Troubleshooting guide
- Comparison with Python TinyTuya

[0.1.0]: https://github.com/yourusername/tinytuya_dart/releases/tag/v0.1.0
