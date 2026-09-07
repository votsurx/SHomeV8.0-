#!/usr/bin/env python3
"""Test script for Cloud API signature generation"""

import sys
import json
import hmac
import hashlib
import time

sys.path.insert(0, '/Users/shorn/.pyenv/versions/3.11.6/lib/python3.11/site-packages')

def generate_signature(api_key, api_secret, timestamp, token=None, action='GET',
                       body='', headers=None, url_path='/v1.0/token'):
    """Generate HMAC-SHA256 signature for Tuya Cloud API - matches Cloud.py logic"""

    # Build payload
    if token is None:
        payload = api_key + str(timestamp)
    else:
        payload = api_key + token + str(timestamp)

    # Add new signature algorithm components (matching Cloud.py line 202-208)
    payload += '%s\n' % action  # HTTPMethod

    # Content-SHA256
    payload += hashlib.sha256(bytes((body or "").encode('utf-8'))).hexdigest() + '\n'

    # Headers - matches Python: ''.join(['%s:%s\n' % ...]) + '\n'
    if headers and 'Signature-Headers' in headers:
        for key in headers.get('Signature-Headers', '').split(':'):
            if key and key in headers:
                payload += '%s:%s\n' % (key, headers[key])
    payload += '\n'

    # URL Path
    payload += url_path

    # Generate signature
    signature = hmac.new(
        api_secret.encode('utf-8'),
        msg=payload.encode('utf-8'),
        digestmod=hashlib.sha256
    ).hexdigest().upper()

    return signature

def test_signatures():
    """Test signature generation with various inputs"""

    api_key = 'test_key_12345'
    api_secret = 'test_secret_abcde'
    timestamp = 1234567890000

    results = {
        # Test 1: GET request without token (initial token request)
        'get_token_no_token': generate_signature(
            api_key, api_secret, timestamp,
            token=None,
            action='GET',
            body='',
            headers={},
            url_path='/v1.0/token'
        ),

        # Test 2: GET request with token
        'get_with_token': generate_signature(
            api_key, api_secret, timestamp,
            token='access_token_xyz',
            action='GET',
            body='',
            headers={},
            url_path='/v1.0/iot-01/associated-users/devices'
        ),

        # Test 3: POST request with body
        'post_with_body': generate_signature(
            api_key, api_secret, timestamp,
            token='access_token_xyz',
            action='POST',
            body='{"commands":[{"code":"switch_1","value":true}]}',
            headers={
                'Content-Type': 'application/json',
                'Signature-Headers': 'Content-Type',
            },
            url_path='/v1.0/iot-03/devices/test_device_id/commands'
        ),

        # Test 4: GET request with query parameters in path
        'get_with_query': generate_signature(
            api_key, api_secret, timestamp,
            token='access_token_xyz',
            action='GET',
            body='',
            headers={},
            url_path='/v1.0/iot-01/associated-users/devices?size=100'
        ),

        # Test 5: PUT request
        'put_request': generate_signature(
            api_key, api_secret, timestamp,
            token='access_token_xyz',
            action='PUT',
            body='{"name":"Updated Name"}',
            headers={
                'Content-Type': 'application/json',
                'Signature-Headers': 'Content-Type',
            },
            url_path='/v1.0/devices/test_device_id'
        ),
    }

    print(json.dumps(results))

if __name__ == '__main__':
    test_signatures()
