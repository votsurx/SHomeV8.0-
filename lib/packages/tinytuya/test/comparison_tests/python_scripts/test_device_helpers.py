#!/usr/bin/env python3
"""
Test script for Device helper methods (turnOn, turnOff, setTimer, updatedps)
Compares Python tinytuya implementation outputs
"""

import sys
import json
import tinytuya

def test_helper_methods(data):
    """Test Device helper methods"""

    # Extract test parameters
    test_type = data.get('test_type')
    dev_id = data.get('dev_id', 'test_device_001')
    local_key = data.get('local_key', 'test_key_1234567')
    version = data.get('version', 3.3)

    # Create device
    device = tinytuya.Device(
        dev_id=dev_id,
        address='192.168.1.100',
        local_key=local_key,
        version=version
    )

    if test_type == 'turn_on':
        switch = data.get('switch', 1)
        # Generate payload for turn_on (which calls set_status)
        # turn_on just calls set_status(True, switch)
        payload = device.generate_payload(tinytuya.DP_QUERY if False else 7, {str(switch): True})
        return {
            'success': True,
            'command': payload.cmd,
            'payload_data': json.loads(payload.payload),
        }

    elif test_type == 'turn_off':
        switch = data.get('switch', 1)
        # turn_off just calls set_status(False, switch)
        payload = device.generate_payload(7, {str(switch): False})
        return {
            'success': True,
            'command': payload.cmd,
            'payload_data': json.loads(payload.payload),
        }

    elif test_type == 'set_timer':
        num_secs = data.get('num_secs', 3600)
        dps_id = data.get('dps_id', 0)
        # set_timer calls set_value(dps_id, num_secs)
        payload = device.generate_payload(7, {str(dps_id): num_secs})
        return {
            'success': True,
            'command': payload.cmd,
            'payload_data': json.loads(payload.payload),
        }

    elif test_type == 'updatedps':
        index = data.get('index', [1])
        # updatedps sends UPDATEDPS command (0x12 = 18)
        payload = device.generate_payload(18, index)
        return {
            'success': True,
            'command': payload.cmd,
            'payload_data': json.loads(payload.payload),
        }

    else:
        return {'error': f'Unknown test_type: {test_type}'}

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(json.dumps({'error': 'Usage: test_device_helpers.py <input_json_file>'}))
        sys.exit(1)

    try:
        with open(sys.argv[1], 'r') as f:
            input_data = json.load(f)

        result = test_helper_methods(input_data)
        print(json.dumps(result))
    except Exception as e:
        print(json.dumps({'error': str(e)}))
        sys.exit(1)
