#!/usr/bin/env python3
"""
Python reference script for testing ECB encryption
Compares Dart AES-ECB with Python PyCrypto/PyCryptodome
"""

import sys
import json

try:
    # Try PyCryptodome first (preferred)
    from Cryptodome.Cipher import AES
except ImportError:
    try:
        # Fall back to PyCrypto
        from Crypto.Cipher import AES
    except ImportError:
        print(json.dumps({"error": "Neither PyCryptodome nor PyCrypto installed"}))
        sys.exit(1)

def pad_pkcs7(data, block_size=16):
    """PKCS7 padding"""
    pad_len = block_size - (len(data) % block_size)
    return data + bytes([pad_len] * pad_len)

def unpad_pkcs7(data):
    """PKCS7 unpadding"""
    pad_len = data[-1]
    return data[:-pad_len]

def test_ecb_encrypt(data):
    """Test ECB encryption"""
    key_str = data.get('key', 'test_key_1234567890abcdef')
    plaintext_str = data.get('plaintext', 'Hello, World!')

    # Convert to bytes and pad key to 16 bytes
    key = key_str.encode('utf-8')[:16].ljust(16, b'\x00')
    plaintext = plaintext_str.encode('utf-8')

    # Pad plaintext
    padded = pad_pkcs7(plaintext)

    # Encrypt with ECB
    cipher = AES.new(key, AES.MODE_ECB)
    ciphertext = cipher.encrypt(padded)

    return {
        'key': key.hex(),
        'plaintext': plaintext_str,
        'plaintext_padded_hex': padded.hex(),
        'ciphertext_hex': ciphertext.hex(),
        'ciphertext_length': len(ciphertext)
    }

def test_ecb_decrypt(data):
    """Test ECB decryption"""
    key_str = data.get('key', 'test_key_1234567890abcdef')
    ciphertext_hex = data.get('ciphertext_hex', '')

    # Convert to bytes
    key = key_str.encode('utf-8')[:16].ljust(16, b'\x00')
    ciphertext = bytes.fromhex(ciphertext_hex)

    # Decrypt with ECB
    cipher = AES.new(key, AES.MODE_ECB)
    padded = cipher.decrypt(ciphertext)
    plaintext = unpad_pkcs7(padded)

    return {
        'key': key.hex(),
        'plaintext': plaintext.decode('utf-8'),
        'ciphertext_hex': ciphertext_hex,
        'success': True
    }

def test_ecb_roundtrip(data):
    """Test ECB encrypt then decrypt"""
    key_str = data.get('key', 'test_key_1234567890abcdef')
    plaintext_str = data.get('plaintext', 'Hello, World!')

    # Encrypt
    encrypt_result = test_ecb_encrypt({'key': key_str, 'plaintext': plaintext_str})

    # Decrypt
    decrypt_result = test_ecb_decrypt({
        'key': key_str,
        'ciphertext_hex': encrypt_result['ciphertext_hex']
    })

    return {
        'key': key_str,
        'original_plaintext': plaintext_str,
        'decrypted_plaintext': decrypt_result['plaintext'],
        'match': plaintext_str == decrypt_result['plaintext'],
        'ciphertext_hex': encrypt_result['ciphertext_hex']
    }

def main():
    if len(sys.argv) != 2:
        print(json.dumps({"error": "Usage: test_ecb_crypto.py <input.json>"}))
        sys.exit(1)

    input_file = sys.argv[1]

    with open(input_file, 'r') as f:
        data = json.load(f)

    test_type = data.get('test_type')

    if test_type == 'encrypt':
        result = test_ecb_encrypt(data)
    elif test_type == 'decrypt':
        result = test_ecb_decrypt(data)
    elif test_type == 'roundtrip':
        result = test_ecb_roundtrip(data)
    else:
        result = {"error": f"Unknown test type: {test_type}"}

    print(json.dumps(result, indent=2))

if __name__ == '__main__':
    main()
