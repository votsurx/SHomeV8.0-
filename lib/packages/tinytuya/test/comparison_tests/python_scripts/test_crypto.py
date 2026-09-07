#!/usr/bin/env python3
"""
Python reference script for testing crypto functions
Reads input from JSON file and outputs result as JSON
"""

import sys
import json
import os

# Add tinytuya to path (assumes it's installed via pip)
try:
    import tinytuya
except ImportError:
    print(json.dumps({"error": "tinytuya not installed. Run: pip install tinytuya"}))
    sys.exit(1)

def test_encrypt(data):
    """Test AES encryption"""
    from tinytuya.core import AESCipher

    key_str = data.get('key', 'test_key_1234567')
    plaintext_str = data.get('plaintext', 'Hello World')
    plaintext = plaintext_str.encode()

    # Pad or truncate key to 16 bytes for AES-128
    key_bytes = key_str.encode('utf-8')[:16].ljust(16, b'\x00')

    # Create cipher
    cipher = AESCipher(key_bytes)

    # Encrypt (use_base64=True by default, pad=True, iv=False)
    encrypted = cipher.encrypt(plaintext, use_base64=True, pad=True, iv=False)

    return {
        'encrypted': encrypted.decode('utf-8') if isinstance(encrypted, bytes) else encrypted,
        'key': key_str,
        'plaintext_length': len(plaintext)
    }

def test_decrypt(data):
    """Test AES decryption"""
    from tinytuya.core import AESCipher

    key_str = data.get('key', 'test_key_1234567')
    ciphertext = data.get('ciphertext', '')

    # Pad or truncate key to 16 bytes for AES-128
    key_bytes = key_str.encode('utf-8')[:16].ljust(16, b'\x00')

    # Create cipher
    cipher = AESCipher(key_bytes)

    # Decrypt (use_base64=True by default, decode_text=True)
    try:
        decrypted = cipher.decrypt(ciphertext, use_base64=True, decode_text=True)
        return {
            'decrypted': decrypted,
            'success': True
        }
    except Exception as e:
        return {
            'error': str(e),
            'success': False
        }

def main():
    if len(sys.argv) != 2:
        print(json.dumps({"error": "Usage: test_crypto.py <input.json>"}))
        sys.exit(1)

    input_file = sys.argv[1]

    with open(input_file, 'r') as f:
        data = json.load(f)

    test_type = data.get('test_type')

    if test_type == 'encrypt':
        result = test_encrypt(data)
    elif test_type == 'decrypt':
        result = test_decrypt(data)
    else:
        result = {"error": f"Unknown test type: {test_type}"}

    print(json.dumps(result))

if __name__ == '__main__':
    main()
