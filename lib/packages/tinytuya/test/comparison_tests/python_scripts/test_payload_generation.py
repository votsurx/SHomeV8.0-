#!/usr/bin/env python3
"""
Python reference script for testing Device payload generation
Compares Dart Device.generatePayload with Python XenonDevice.generate_payload
"""

import sys
import json

try:
    import tinytuya
    XenonDevice = tinytuya.XenonDevice
except ImportError:
    print(json.dumps({"error": "tinytuya not installed. Run: pip install tinytuya"}))
    sys.exit(1)

# Command type constants (from tinytuya)
STATUS = tinytuya.STATUS
CONTROL = tinytuya.CONTROL
HEART_BEAT = tinytuya.HEART_BEAT
DP_QUERY = tinytuya.DP_QUERY
UPDATEDPS = tinytuya.UPDATEDPS


def test_generate_payload(data):
    """Test payload generation for various commands"""
    dev_id = data.get('dev_id', 'test_device_id_001')
    local_key = data.get('local_key', 'test_key_1234567')
    version = float(data.get('version', '3.3'))
    command = data.get('command', STATUS)
    command_data = data.get('data', None)

    # Create device
    # We use a dummy IP address to avoid network auto-discovery
    device = XenonDevice(
        dev_id=dev_id,
        address='192.168.1.100',  # Dummy address, we won't actually connect
        local_key=local_key,
        version=version,
        connection_timeout=1
    )

    # Generate payload
    try:
        payload = device.generate_payload(command, data=command_data)

        # Convert MessagePayload to dict for JSON serialization
        result = {
            'success': True,
            'command': payload.cmd,
            'payload_data': json.loads(payload.payload) if payload.payload else None,
            'seqno': device.seqno - 1,  # seqno gets incremented in generate_payload
        }

        return result
    except Exception as e:
        return {
            'success': False,
            'error': str(e),
            'error_type': type(e).__name__
        }


def main():
    if len(sys.argv) != 2:
        print(json.dumps({"error": "Usage: test_payload_generation.py <input.json>"}))
        sys.exit(1)

    input_file = sys.argv[1]

    with open(input_file, 'r') as f:
        data = json.load(f)

    result = test_generate_payload(data)
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
