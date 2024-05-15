"""
Minimal entrypoint of template
"""

import os

print(os.environ)
__version__ = os.environ["APP_VERSION"]
