#!/usr/bin/env python3
"""Test script for BulbDevice color conversion methods"""

import sys
import json
sys.path.insert(0, '/Users/shorn/.pyenv/versions/3.11.6/lib/python3.11/site-packages')

from tinytuya import BulbDevice

def test_color_conversions():
    """Test color conversion methods"""

    results = {
        'rgb_to_hex_rgb8_red': BulbDevice.rgb_to_hexvalue(255, 0, 0, 'rgb8'),
        'rgb_to_hex_rgb8_green': BulbDevice.rgb_to_hexvalue(0, 255, 0, 'rgb8'),
        'rgb_to_hex_rgb8_blue': BulbDevice.rgb_to_hexvalue(0, 0, 255, 'rgb8'),
        'rgb_to_hex_rgb8_white': BulbDevice.rgb_to_hexvalue(255, 255, 255, 'rgb8'),
        'rgb_to_hex_rgb8_mixed': BulbDevice.rgb_to_hexvalue(128, 64, 200, 'rgb8'),

        'rgb_to_hex_hsv16_red': BulbDevice.rgb_to_hexvalue(255, 0, 0, 'hsv16'),
        'rgb_to_hex_hsv16_green': BulbDevice.rgb_to_hexvalue(0, 255, 0, 'hsv16'),
        'rgb_to_hex_hsv16_blue': BulbDevice.rgb_to_hexvalue(0, 0, 255, 'hsv16'),
        'rgb_to_hex_hsv16_white': BulbDevice.rgb_to_hexvalue(255, 255, 255, 'hsv16'),
        'rgb_to_hex_hsv16_mixed': BulbDevice.rgb_to_hexvalue(128, 64, 200, 'hsv16'),

        # Skip hsv_to_hex for rgb8 format due to Python bug (passes float to rgb_to_hexvalue)

        'hsv_to_hex_hsv16_1': BulbDevice.hsv_to_hexvalue(0, 1.0, 1.0, 'hsv16'),
        'hsv_to_hex_hsv16_2': BulbDevice.hsv_to_hexvalue(0.33, 1.0, 1.0, 'hsv16'),
        'hsv_to_hex_hsv16_3': BulbDevice.hsv_to_hexvalue(0.66, 1.0, 1.0, 'hsv16'),

        'hex_to_rgb_rgb8': list(BulbDevice.hexvalue_to_rgb('ff0000', 'rgb8')),
        'hex_to_rgb_hsv16': list(BulbDevice.hexvalue_to_rgb('000003e803e8', 'hsv16')),
        'hex_to_rgb_auto_6': list(BulbDevice.hexvalue_to_rgb('00ff00')),
        'hex_to_rgb_auto_12': list(BulbDevice.hexvalue_to_rgb('007803e803e8')),
        'hex_to_rgb_auto_14': list(BulbDevice.hexvalue_to_rgb('0000ff00f0ffff')),

        'hex_to_hsv_rgb8': list(BulbDevice.hexvalue_to_hsv('ff0000', 'rgb8')),
        'hex_to_hsv_hsv16': list(BulbDevice.hexvalue_to_hsv('000003e803e8', 'hsv16')),
        'hex_to_hsv_auto_6': list(BulbDevice.hexvalue_to_hsv('00ff00')),
        'hex_to_hsv_auto_12': list(BulbDevice.hexvalue_to_hsv('007803e803e8')),
        'hex_to_hsv_auto_14': list(BulbDevice.hexvalue_to_hsv('0000ff00f0ffff')),
    }

    print(json.dumps(results))

if __name__ == '__main__':
    test_color_conversions()
