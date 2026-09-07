#!/usr/bin/env python3
"""
Test session timeout behavior in Python TinyTuya
"""
import tinytuya
import json
import time

# Load devices
with open('../../../example/devices.json') as f:
    config = json.load(f)

# Find v3.5 device
v35_device = None
for d in config['devices']:
    if d['version'] == 3.5:
        v35_device = d
        break

if not v35_device:
    print("No v3.5 device found")
    exit(1)

print('=' * 60)
print('Python TinyTuya - Session Timeout Test')
print('=' * 60)
print(f"Testing with: {v35_device['name']}")
print(f"IP: {v35_device['ip']}")
print(f"Version: {v35_device['version']}")
print(f"Device ID: {v35_device['device_id']}")
print()

# Create device
device = tinytuya.Device(
    dev_id=v35_device['device_id'],
    address=v35_device['ip'],
    local_key=v35_device['local_key'],
    version=v35_device['version']
)

# Test 1: Initial connection and status
print('-' * 60)
print('Test 1: Initial connection and status query')
print('-' * 60)
try:
    status = device.status()
    print('✓ Status query successful')
    print(f"  DPS: {status.get('dps', {})}")
except Exception as e:
    print(f'✗ Status query failed: {e}')

# Test 2: Wait 1 minute idle, then try again
print()
print('-' * 60)
print('Test 2: Idle for 1 minute, then query status')
print('-' * 60)
print('Waiting 1 minute (60 seconds) with idle connection...')
time.sleep(60)

print('1 minute elapsed. Attempting status query...')
try:
    status = device.status()
    print('✓ Status query successful after 1 minute idle')
    print(f"  DPS: {status.get('dps', {})}")
except Exception as e:
    print(f'✗ Status query failed after 1 minute idle: {e}')

# Test 3: Turn device on
print()
print('Attempting to turn device ON...')
try:
    result = device.turn_on()
    print('✓ Turn ON successful')
except Exception as e:
    print(f'✗ Turn ON failed: {e}')

# Test 4: Wait 2 minutes idle, then try again
print()
print('-' * 60)
print('Test 4: Idle for 2 minutes, then query status')
print('-' * 60)
print('Waiting 2 minutes (120 seconds) with idle connection...')
time.sleep(120)

print('2 minutes elapsed. Attempting status query...')
try:
    status = device.status()
    print('✓ Status query successful after 2 minutes idle')
    print(f"  DPS: {status.get('dps', {})}")
except Exception as e:
    print(f'✗ Status query failed after 2 minutes idle: {e}')

# Test 5: Turn device off
print()
print('Attempting to turn device OFF...')
try:
    result = device.turn_off()
    print('✓ Turn OFF successful')
except Exception as e:
    print(f'✗ Turn OFF failed: {e}')

print()
print('=' * 60)
print('Python Test Complete')
print('=' * 60)
