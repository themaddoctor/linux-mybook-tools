#!/bin/bash
# usage: bash jms538s-extract-DEK-from-keyblock.sh <kek file (hex)> <keyblock file (binary)>

KEK="$1"
KEYBLOCK="$2"
TEMPDIR=`mktemp -d ./WDXXXXXXXX`

cat > $TEMPDIR/unwrap.py << "EOF"
#!/usr/bin/python

import struct
from Crypto.Cipher import AES

QUAD = struct.Struct('>Q')

def aes_unwrap_key_and_iv(kek, wrapped):
    n = len(wrapped)/8 - 1
    R = [None]+[wrapped[i*8:i*8+8] for i in range(1, n+1)]
    A = QUAD.unpack(wrapped[:8])[0]
    decrypt = AES.new(kek).decrypt
    for j in range(5,-1,-1): #counting down
        for i in range(n, 0, -1): #(n, n-1, ..., 1)
            ciphertext = QUAD.pack(A^(n*j+i)) + R[i]
            B = decrypt(ciphertext)
            A = QUAD.unpack(B[:8])[0]
            R[i] = B[8:]
    return "".join(R[1:]), A

def aes_unwrap_key(kek, wrapped, iv=0xa6a6a6a6a6a6a6a6):
    key, key_iv = aes_unwrap_key_and_iv(kek, wrapped)
    if key_iv != iv:
        raise ValueError("Integrity Check Failed: "+hex(key_iv)+
                " (expected "+hex(iv)+")")
    return key

if __name__ == "__main__":
    import sys
    import binascii
    CIPHER = binascii.unhexlify(sys.argv[1])
    KEK = binascii.unhexlify(sys.argv[2])
    print binascii.hexlify(aes_unwrap_key(KEK, CIPHER))
EOF
chmod +x $TEMPDIR/unwrap.py

xxd -p -c 16 "$KEYBLOCK" | grep -o ........ | tac | echo "$(tr -d '\n')" | \
    grep -o .. | tac | echo "$(tr -d '\n')" | xxd -p -r > $TEMPDIR/kb.bin
dd if=$TEMPDIR/kb.bin bs=8 skip=2 count=5 of=$TEMPDIR/edek.bin status=none
$TEMPDIR/unwrap.py `xxd -p -c 40 $TEMPDIR/edek.bin` `cat "$KEK"` > $TEMPDIR/dek0.hex
TEST=`xxd -p -c 16 $TEMPDIR/kb.bin | head -n 1 | cut -b 17-32`
if [ "$TEST" = "0000000200000002" ]; then
    echo "encryption mode is XTS" 1>&2
    dd if=$TEMPDIR/kb.bin bs=8 skip=7 count=5 of=$TEMPDIR/edek2.bin status=none
    $TEMPDIR/unwrap.py `xxd -p -c 40 $TEMPDIR/edek2.bin` `cat "$KEK"` >> $TEMPDIR/dek0.hex
  else
    echo "encryption mode is ECB" 1>&2
  fi
cat $TEMPDIR/dek0.hex | grep -o ........ | tac | echo "$(tr -d '\n')" | \
    grep -o .. |tac | echo "$(tr -d '\n')"

rm -rf $TEMPDIR

# end
