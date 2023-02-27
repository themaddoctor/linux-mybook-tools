#!/usr/bin/env python3

from sys import argv
from hashlib import sha256

KEK = "WDC." + argv[1]
KEK = KEK.encode("utf16")[2:]

for _ in range(1000):
    hash = sha256()
    hash.update(KEK)
    KEK = hash.digest()

print(KEK.hex())
