#!/usr/bin/env python3
"""
Python tinytuya scanner for comparison
"""

import sys
import json
import tinytuya.scanner

def scan_devices(scantime=5):
    """Scan for Tuya devices using Python tinytuya"""
    print("Python Scanner - Starting scan...", file=sys.stderr)

    # Scan for devices (verbose=False to avoid stdout clutter)
    devices_dict = tinytuya.scanner.devices(
        verbose=False,
        scantime=scantime,
        color=False,
        poll=False,
        discover=True
    )

    # Convert to list format
    devices = []
    for ip, device_info in devices_dict.items():
        devices.append({
            'ip': ip,
            'gwId': device_info.get('gwId'),
            'productKey': device_info.get('productKey'),
            'version': device_info.get('version'),
            'mac': device_info.get('mac'),
            'name': device_info.get('name'),
            'key': device_info.get('key'),
        })

    print(f"Python Scanner - Found {len(devices)} devices", file=sys.stderr)
    return devices

if __name__ == '__main__':
    scantime = int(sys.argv[1]) if len(sys.argv) > 1 else 5

    try:
        devices = scan_devices(scantime)
        # Output JSON to stdout for parsing
        print(json.dumps(devices, indent=2))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
