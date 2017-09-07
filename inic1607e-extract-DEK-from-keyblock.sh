#!/bin/bash
# usage: bash inic1607e-extract-DEK-from-keyblock.sh <kek file (hex)> <keyblock file (binary)>

KEK="$1"
KEYBLOCK="$2"
TEMPDIR=`mktemp -d ./WDXXXXXXXX`

cat "$KEYBLOCK" | xxd -p -c 32 | grep -o ........ | tac | \
   echo "$(tr -d '\n')" | grep -o .. | tac | \
   echo "$(tr -d '\n')" | xxd -p -r > $TEMPDIR/kb1.bin
cat "$KEK" | grep -o ................................ | tac | \
    echo "$(tr -d '\n')" | grep -o .. | tac | \
    echo "$(tr -d '\n')" > $TEMPDIR/kek1.hex
openssl enc -d -aes-256-ecb -K `cat $TEMPDIR/kek1.hex` \
    -nopad -in $TEMPDIR/kb1.bin -out $TEMPDIR/kb2.bin

TEST=`dd if=$TEMPDIR/kb2.bin bs=16 skip=25 count=1 status=none | xxd -p | grep "^275dba35"`
if [ -z "$TEST" ]; then
    echo "decryption of keyblock failed" 1>&2
    rm -rf $TEMPDIR
    exit 1;
  fi

dd if=$TEMPDIR/kb2.bin bs=4 skip=103 count=8 status=none | xxd -p -c 32 > $TEMPDIR/dek1.hex
cat $TEMPDIR/dek1.hex | grep -o ................................ | tac | \
    echo "$(tr -d '\n')" | grep -o ........ | tac | \
    echo "$(tr -d '\n')"

rm -rf $TEMPDIR

# end
