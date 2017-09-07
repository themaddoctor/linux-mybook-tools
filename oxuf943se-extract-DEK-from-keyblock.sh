#!/bin/bash
# usage: bash jms538s-extract-DEK-from-keyblock.sh <kek file (hex)> <keyblock file (binary)>

KEK="$1"
KEYBLOCK="$2"
TEMPDIR=`mktemp -d ./WDXXXXXXXX`

cat "$KEK" | grep -o ........ | tac | echo "$(tr -d '\n')" > $TEMPDIR/kek1.hex

dd if="$KEYBLOCK" bs=4 skip=5 count=64 of=$TEMPDIR/kb1.bin status=none
openssl enc -d -aes-256-ecb -K `cat $TEMPDIR/kek1.hex` -nopad \
    -in $TEMPDIR/kb1.bin -out $TEMPDIR/kb2.bin
dd if=$TEMPDIR/kb2.bin bs=32 count=1 status=none | xxd -p -c 32 > $TEMPDIR/dek1.hex
cat $TEMPDIR/dek1.hex | grep -o ........ | tac | echo "$(tr -d '\n')"

rm -rf $TEMPDIR

# end
