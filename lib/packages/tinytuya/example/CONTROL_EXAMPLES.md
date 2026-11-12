# Tuya Device Control Examples

This directory contains working examples for controlling Tuya devices across all three protocol versions (v3.3, v3.4, v3.5).

## Control Examples

### v3.3 Control
```bash
dart run example/control_v33.dart
```

### v3.4 Control
```bash
dart run example/control_v34.dart
```

### v3.5 Control
```bash
dart run example/control_v35.dart
```

## What These Examples Do

Each example demonstrates:
1. Reading the current device status
2. Turning the device ON using `device.turnOn()`
3. Waiting 2 seconds
4. Reading status again
5. Turning the device OFF using `device.turnOff()`
6. Waiting 2 seconds
7. Reading final status

## Key Points

### DPS Keys Are Strings
Important: DPS keys in the status response are **strings**, not integers:
```dart
// ✅ Correct
var switchState = result['dps']?["1"];

// ❌ Wrong
var switchState = result['dps']?[1];  // Returns null!
```

### Available Control Methods

The Device class provides several control methods:

- `turnOn({String switchNum = '1'})` - Turn on a switch
- `turnOff({String switchNum = '1'})` - Turn off a switch
- `setStatus({required bool on, String switchNum = '1'})` - Set switch state
- `setValue({required dynamic index, required dynamic value})` - Set any DPS value
- `setMultipleValues(Map<dynamic, dynamic> dps)` - Set multiple DPS values at once

### Example: Control Multiple Switches
```dart
// Turn on switch 2
await device.turnOn(switchNum: '2');

// Set multiple values at once
await device.setMultipleValues({
  '1': true,   // Main switch ON
  '2': false,  // Second switch OFF
  '20': 100,   // Some numeric value
});
```

### Response After Control Commands

After executing control commands, the response may not always include the full DPS state. This is normal Tuya device behavior - the device confirms the command succeeded but doesn't always echo back all DPS values. The `success: true` field indicates the command was executed successfully.

## Protocol Versions Tested

- ✅ **v3.3** - Working with standard AES encryption
- ✅ **v3.4** - Working with session key negotiation and HMAC
- ✅ **v3.5** - Working with GCM encryption

All three protocol versions can successfully control real Tuya devices!
