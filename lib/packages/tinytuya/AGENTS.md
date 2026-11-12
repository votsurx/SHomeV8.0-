# AGENTS.md - TinyTuya Dart

## Project Overview

TinyTuya Dart is a pure Dart implementation of the TinyTuya protocol for controlling Tuya IoT devices locally without cloud dependencies. This package supports Tuya protocol versions 3.3, 3.4, and 3.5, each with different encryption schemes and session management requirements.

**Critical Context**: This codebase was developed to match the behavior and reliability of the Python TinyTuya implementation. Understanding socket lifecycle management, error recovery, and protocol version differences is essential for working on this project.

## Architecture Overview

### Core Components

- **`lib/src/core/device.dart`**: Main device communication class
  - Socket lifecycle management
  - Operation locking (prevents concurrent operations)
  - Protocol version-specific encryption/decryption
  - Error recovery and automatic reconnection

- **Protocol Versions**:
  - **v3.3**: Simple AES-ECB encryption, no session key negotiation
  - **v3.4**: AES-ECB with session key negotiation, nested response format
  - **v3.5**: AES-GCM encryption with session key negotiation, longer timeouts needed

### Critical Architecture Decisions

#### 1. Single Code Path Through `_sendReceive()`

**All** device operations flow through the `_sendReceive()` method (lib/src/core/device.dart:701):
```
status() → _sendReceive()
turnOn() → setStatus() → _sendReceive()
turnOff() → setStatus() → _sendReceive()
setValue() → _sendReceive()
```

This ensures:
- Consistent operation locking across all versions
- Uniform error handling and recovery
- Single point for socket cleanup

#### 2. Operation Lock Pattern

**Why**: Tuya devices cannot handle concurrent operations. Sending multiple commands simultaneously corrupts the receive buffer.

**Implementation** (lib/src/core/device.dart:707-809):
```dart
await _acquireLock();  // Line 707

try {
  // ... operation code ...
} finally {
  // CRITICAL: Always release lock
  _releaseLock();  // Line 808
}
```

**Never** skip the finally block - this prevents deadlocks when timeouts occur outside `_sendReceive()`.

#### 3. Socket Cleanup Order

**Critical Fix** (lib/src/core/device.dart:107-126):

Socket MUST be closed BEFORE canceling the stream subscription:
```dart
// CRITICAL: Close socket FIRST, then cancel subscription
// This prevents "StreamSink is bound to a stream" errors
if (_socket != null) {
  await _socket!.close();
  _socket = null;
}

// Cancel subscription after socket is closed
if (_socketSubscription != null) {
  await _socketSubscription!.cancel();
  _socketSubscription = null;
}
```

**Wrong order causes**: `Bad state: StreamSink is bound to a stream` errors on retry.

#### 4. Error Recovery Pattern

On ANY error in `_sendReceive()`, the socket MUST be closed to ensure clean state:

```dart
catch (e) {
  // CRITICAL: Always close socket on error to ensure clean state
  await _closeSocket();

  return {
    'Error': e.toString(),
  };
} finally {
  _releaseLock();
}
```

**Why**: After an error, socket and receive buffer are in corrupted/unknown state. Closing ensures next operation starts fresh.

## Setup Commands

```bash
# Install dependencies
dart pub get

# Run code analysis
dart analyze

# Format code
dart format .

# Run all tests (unit + integration)
dart test

# Run only integration tests (requires devices.json)
dart test test/integration/
```

## Testing

### Unit Tests

Located in `test/`. Run with:
```bash
dart test test/
```

### Integration Tests

**IMPORTANT**: Integration tests require real Tuya devices configured in `test/integration/devices.json`.

#### Setting Up Integration Tests

1. Copy the example config:
   ```bash
   cp test/integration/devices.json.example test/integration/devices.json
   ```

2. Fill in your device credentials:
   ```json
   {
     "devices": [
       {
         "name": "Device v3.3",
         "device_id": "your-device-id",
         "local_key": "your-local-key",
         "ip": "192.168.1.x",
         "version": 3.3,
         "type": "switch"
       }
     ]
   }
   ```

3. Run integration tests:
   ```bash
   dart test test/integration/
   ```

**Test Skipping**: All integration tests gracefully skip if `devices.json` is missing:
```dart
final config = await loadDeviceConfig();
if (config == null) {
  print('Skipped: No devices.json found...');
  return;
}
```

### Stress Test

The stress test (`test/integration/stress_test.dart`) validates error recovery across protocol versions:

```bash
dart test test/integration/stress_test.dart
```

**Version-Specific Timeouts** (learned from testing):
- v3.3: 500ms timeout (simple protocol)
- v3.4: 1000ms timeout (+ session key negotiation overhead)
- v3.5: 1500ms timeout (+ GCM encryption overhead)

**Expected Results**: 100% success rate across all protocol versions.

## Code Style and Patterns

### Error Handling

**Pattern for Socket Operations**:
```dart
try {
  await _acquireLock();

  try {
    // ... socket operations ...
    await _getSocket();
    _socket!.add(data);
    // ...
  } catch (e) {
    await _closeSocket();  // CRITICAL: Clean up on error
    return {'Error': e.toString()};
  } finally {
    _releaseLock();  // CRITICAL: Always release lock
  }
} catch (e) {
  // Handle lock acquisition errors
}
```

### Async/Await Guidelines

1. **Always** await `_closeSocket()` - it performs async cleanup
2. **Never** call `_releaseLock()` conditionally - use finally blocks
3. **Timeout pattern**:
   ```dart
   final result = await operation().timeout(
     Duration(milliseconds: timeoutMs),
     onTimeout: () => {'success': false, 'error': 'Timeout'},
   );
   ```

### Version-Specific Code

When adding version-specific logic:

```dart
// Check version first
if (version >= 3.5) {
  // v3.5-specific code
} else if (version >= 3.4) {
  // v3.4-specific code
} else {
  // v3.3 and below
}
```

**Common version checks**:
- Session key negotiation: `version >= 3.4`
- GCM encryption: `version >= 3.5`
- Longer receive retries: `version >= 3.5 ? 4 : 2`

## Protocol Version Differences

### v3.3
- **Encryption**: AES-ECB (no IV, PKCS7 padding)
- **Session Key**: None (uses local_key directly)
- **Complexity**: Lowest
- **Reliability**: Less reliable, needs more retries in tests

### v3.4
- **Encryption**: AES-ECB for payload + session
- **Session Key**: 3-step negotiation required on connection
- **Response Format**: Nested `data.dps` structure
- **Complexity**: Medium
- **Special Handling**: Decrypt payload BEFORE checking version header

### v3.5
- **Encryption**: AES-GCM (authenticated encryption)
- **Session Key**: 3-step negotiation required on connection
- **Response Format**: May include 4-byte retcode prefix
- **Complexity**: Highest
- **Special Handling**:
  - Multiple receive buffer flush cycles needed
  - Longer timeouts for GCM overhead
  - Plain JSON for control responses (not GCM encrypted)

## Security Considerations

### Device Credentials

**NEVER commit** `test/integration/devices.json` with real device credentials.

The file is gitignored. Always use `devices.json.example` for examples.

### Local Key Handling

Device `local_key` values are sensitive. They're required for AES encryption/decryption but should never be logged or exposed.

## Build & Publish

### Pre-publish Checklist

```bash
# 1. Ensure all tests pass
dart test

# 2. Run analysis with no issues
dart analyze

# 3. Format code
dart format .

# 4. Update version in pubspec.yaml

# 5. Update CHANGELOG.md
```

### Publishing to pub.dev

```bash
# Dry run first
dart pub publish --dry-run

# Publish
dart pub publish
```

## Common Issues and Solutions

### Issue: "Bad state: StreamSink is bound to a stream"

**Cause**: Socket subscription cancelled before socket closed.

**Solution**: Already fixed in `_closeSocket()` (lib/src/core/device.dart:107-126). If you see this, the fix was likely reverted.

### Issue: Deadlock (operations hang forever)

**Cause**: Operation lock not released after timeout.

**Solution**: Ensure `_releaseLock()` is in finally block of `_sendReceive()` (lib/src/core/device.dart:805-809).

### Issue: v3.5 device operations timeout

**Cause**: GCM encryption overhead requires longer timeout.

**Solution**: Use 1500ms timeout for v3.5 devices (see stress_test.dart:110).

### Issue: Operations fail after first error

**Cause**: Socket not closed after error, leaving corrupted state.

**Solution**: Ensure `await _closeSocket()` is called in catch block (lib/src/core/device.dart:798-800).

## File Organization

```
lib/
├── src/
│   ├── core/
│   │   ├── device.dart         # Main device class - CRITICAL FILE
│   │   ├── exceptions.dart     # Custom exceptions
│   │   └── crypto/
│   │       ├── aes_cipher.dart # AES encryption wrapper
│   │       └── message_codec.dart # Protocol encode/decode
│   └── tinytuya_base.dart
│
test/
├── integration/                # Integration tests (require real devices)
│   ├── devices.json.example   # Template for device config
│   ├── devices.json           # Actual config (gitignored)
│   ├── test_helpers.dart      # Shared test utilities
│   ├── stress_test.dart       # Error recovery validation
│   ├── persist_modes_test.dart
│   ├── socket_behavior_test.dart
│   └── session_timeout_test.dart
│
└── unit/                      # Unit tests (no devices needed)
```

## Development Workflow

### Making Changes to Core Device Logic

1. **Read `lib/src/core/device.dart`** - understand current flow
2. **Check protocol version impacts** - does change affect all versions?
3. **Test with stress_test.dart** - validates error recovery
4. **Verify socket cleanup** - ensure `_closeSocket()` called on errors
5. **Check operation locking** - ensure finally block releases lock

### Adding New Device Methods

New methods should follow this pattern:

```dart
Future<Map<String, dynamic>> myNewMethod() async {
  final payload = generatePayload(
    command: myCommand,
    data: {...},
  );

  return await _sendReceive(payload);
}
```

**Do NOT**:
- Call `_getSocket()` directly
- Manage locks manually
- Handle socket cleanup - `_sendReceive()` does this

## Known Limitations

1. **No concurrent operations**: Operation lock ensures serial execution
2. **Session timeout**: v3.4+ devices timeout after ~60 seconds idle
3. **Buffer size**: Hardcoded limits in `_recvAll()` (lib/src/core/device.dart:329)
4. **v3.5 requires longer operations**: GCM overhead adds 200-500ms per operation

## References

- Python TinyTuya: https://github.com/jasonacox/tinytuya
- Tuya Protocol Docs: https://github.com/codetheweb/tuyapi/blob/master/docs/PROTOCOL.md
- pub.dev Package: https://pub.dev/packages/tinytuya

## Key Learnings

### Socket Lifecycle is Critical

The most challenging aspect of this implementation was getting socket lifecycle management right. Key insights:

1. **Close order matters**: Socket → Subscription (not the reverse)
2. **Error = corrupted state**: Always close socket after ANY error
3. **Lock release is mandatory**: Use finally blocks, never conditional release
4. **Buffer must be cleared**: Stale data causes decode errors

### Protocol Versions Behave Differently

Don't assume patterns from one version work for others:

- v3.3: Fast, simple, but unreliable
- v3.4: Medium speed, nested responses, needs session key
- v3.5: Slowest, most complex, but most secure

### Testing Validates Architecture

The stress test was crucial for validating error recovery. It revealed:

1. StreamSink errors from wrong cleanup order
2. Deadlocks from missing finally blocks
3. Version-specific timeout requirements
4. Socket corruption after errors

Without rapid consecutive operations testing, these issues wouldn't surface in normal usage.

## Agent-Specific Guidance

When modifying this codebase:

1. **Run stress test immediately** after changes to `device.dart`
2. **Never remove finally blocks** from `_sendReceive()`
3. **Test all three protocol versions** - they have different code paths
4. **Check Python TinyTuya** for behavior reference when uncertain
5. **Preserve socket cleanup order** in `_closeSocket()`

If integration tests fail:
- Check `devices.json` exists and has correct credentials
- Verify devices are online and reachable on network
- Check protocol version matches device actual version
- Try increasing timeout for v3.4/v3.5 if operations timeout
