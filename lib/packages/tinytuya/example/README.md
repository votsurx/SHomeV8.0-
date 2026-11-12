# TinyTuya Dart Examples

This directory contains practical examples for testing TinyTuya Dart with real devices.

## Quick Start

### 1. Scan for Devices

First, scan your network to find Tuya devices:

```bash
dart run example/enhanced_scanner.dart
```

This will:
- Scan for 15 seconds
- Display all discovered devices
- Show device IDs, IPs, and protocol versions
- Provide code examples for each device

### 2. Configure Your Devices

Edit `example/devices.json` with your device information:

```json
{
  "devices": [
    {
      "name": "My Device",
      "device_id": "your_device_id",
      "local_key": "your_local_key",
      "ip": "192.168.1.100",
      "version": 3.3,
      "type": "outlet"
    }
  ]
}
```

**Getting Local Keys:**
- Use the Tuya Cloud API (see cloud_example.dart)
- Use [tinytuya wizard](https://github.com/jasonacox/tinytuya#setup-wizard---getting-local-keys)
- Extract from the Smart Life/Tuya app

### 3. Test Your Devices

Run the comprehensive test suite:

```bash
dart run example/test_real_devices.dart
```

This will:
1. **Scan network** and verify all configured devices are present
2. **Test connectivity** for each device
3. **Retrieve status** and display all DPS values
4. **Test controls** (turn on/off)
5. **Test device-specific features** (bulb colors, outlet dimming, etc.)

## Example Files

### enhanced_scanner.dart
Comprehensive network scanner that displays detailed information about all Tuya devices on your network.

**Features:**
- Multi-port UDP listening (6666, 6667, 7000)
- Support for all protocol versions (v3.1-v3.5)
- Grouped display by protocol version
- Code generation for controlling each device

**Usage:**
```bash
dart run example/enhanced_scanner.dart
```

### test_real_devices.dart
Complete test suite for your configured devices.

**Features:**
- Network scanning and device verification
- Connection testing for each protocol version
- Status retrieval and DPS detection
- Control commands (on/off, dimming, colors)
- Device-specific feature testing
- Comprehensive error handling and debugging output

**Usage:**
```bash
# 1. Configure devices.json with your device info
# 2. Run the test suite
dart run example/test_real_devices.dart
```

**Test Flow:**
1. Load device configuration from devices.json
2. Scan network to verify devices are online
3. Ask for confirmation before testing
4. Test each device:
   - Get device status
   - Detect available DPS
   - Test turn on/off
   - Test device-specific features

### cloud_example.dart
Cloud API integration example.

**Features:**
- OAuth2 authentication
- Get all devices with local keys
- Query device status via cloud
- Send commands via cloud

**Usage:**
```bash
# Set your credentials in the file or environment variables
dart run example/cloud_example.dart
```

## Device Configuration

### Device Types

Specify the correct type for device-specific testing:

- **`outlet`** - Smart plugs, switches (tests dimming)
- **`bulb`** - Smart bulbs, LED strips (tests colors, brightness)
- **`cover`** - Blinds, curtains (tests open/close/stop)
- **`unknown`** - Generic device (basic tests only)

### Protocol Versions

- **v3.1** - Older devices, basic encryption
- **v3.3** - Most common, improved security
- **v3.4** - Additional HMAC validation
- **v3.5** - Latest, AES-GCM encryption

## Troubleshooting

### Devices Not Found in Scan

1. **Check network connection**
   - Devices must be on same network as your computer
   - Verify WiFi is working on both devices and computer

2. **Check firewall**
   - Ensure UDP ports 6666, 6667, 7000 are not blocked
   - Temporarily disable firewall to test

3. **Device compatibility**
   - Some devices don't respond to UDP broadcasts
   - Use the Tuya/Smart Life app to verify device is online
   - Try using the device's IP directly

### Connection Errors

**"Connection refused"**
- Verify IP address is correct
- Check device is powered on
- Try pinging the device: `ping 192.168.1.xxx`

**"Invalid JSON"**
- Try different protocol versions (3.1, 3.3, 3.4, 3.5)
- Verify local key is correct
- Check device is not in pairing mode

**"Timeout"**
- Device may be slow to respond
- Try increasing timeout in device configuration
- Check network latency

### Control Errors

**"DPS not supported"**
- Device doesn't support this control
- Use `detectAvailableDps()` to see what's available
- Check device documentation for supported DPS

**"Device does not respond"**
- Try turning device off and on
- Reset device to factory settings
- Update device firmware in Tuya app

## Example Device Configuration

The `devices.json.example` file provides a template. Copy it to `devices.json` and configure with your device information:

1. **Device v3.3** (v3.3 protocol)
   - ID: YOUR_DEVICE_ID_HERE
   - IP: 192.168.1.100
   - Type: outlet

2. **Device v3.4** (v3.4 protocol)
   - ID: YOUR_DEVICE_ID_HERE
   - IP: 192.168.1.101
   - Type: outlet

3. **Device v3.5** (v3.5 protocol)
   - ID: YOUR_DEVICE_ID_HERE
   - IP: 192.168.1.102
   - Type: bulb

## Adding More Devices

To test additional devices:

1. Run the scanner to find device ID and version
2. Get the local key (see "Getting Local Keys" above)
3. Add entry to devices.json
4. Run test_real_devices.dart

## Example Output

```
╔══════════════════════════════════════════════════════════════╗
║         TinyTuya Dart - Real Device Test Suite              ║
╚══════════════════════════════════════════════════════════════╝

Loading device configuration from devices.json...
✓ Loaded 3 device(s)

══════════════════════════════════════════════════════════════
Step 1: Scanning local network for Tuya devices...
══════════════════════════════════════════════════════════════
Scan duration: 10 seconds
Listening on ports: 6666, 6667, 7000

✓ Scan complete! Found 3 device(s):

  Device: 192.168.1.100
    Gateway ID: YOUR_DEVICE_ID_HERE
    Version: 3.3
    Product Key: YOUR_PRODUCT_KEY

Verifying configured devices are on network:
  ✓ Device v3.3 (YOUR_DEVICE_ID_HERE)
    Found at: 192.168.1.100
    Version: 3.3

Continue with device control tests? (y/n)
```

## Resources

- [TinyTuya Dart Documentation](../README.md)
- [Python TinyTuya](https://github.com/jasonacox/tinytuya)
- [Tuya IoT Platform](https://iot.tuya.com/)
- [Getting Local Keys Guide](https://github.com/jasonacox/tinytuya#setup-wizard---getting-local-keys)
