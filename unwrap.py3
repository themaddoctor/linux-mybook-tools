#!/usr/bin/env python3

from sys import argv
from Crypto.Cipher import AES

def xor(x,y):
    result = bytearray()
    for i in range(len(x)):
        result.append(x[i]^y[i])
    return bytes(result)

IV = bytes.fromhex("a6a6a6a6a6a6a6a6")

def unwrap(key,data):
    A = data[:8]
    n = len(data) // 8 - 1
    R = []
    for i in range(n):
        R.append(data[(i+1)*8:(i+2)*8])
    cipher = AES.new(key,1)
    for j in range(5,-1,-1):
        for i in range(n-1,-1,-1):
            X = xor(A,int.to_bytes(n*j+i+1,8,"big"))
            B = cipher.decrypt(X+R[i])
            A = B[:8]
            R[i] = B[8:]
    assert (A == IV), f"integrity check failed ({A.hex()} != {IV.hex()})"
    P = b""
    for i in range(n):
        P += R[i]
    return P

key = bytes.fromhex(argv[2])
data = bytes.fromhex(argv[1])
print(unwrap(key,data).hex())
