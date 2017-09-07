#!/bin/bash
# usage: bash jms538s-extract-DEK-from-keyblock.sh <kek file (hex)> <keyblock file (binary)>

KEK="$1"
KEYBLOCK="$2"
TEMPDIR=`mktemp -d ./WDXXXXXXXX`

cat "$KEK" | grep -o .. | tac | echo "$(tr -d '\n')" > $TEMPDIR/kek1.hex
for i in `seq 0 31`; do
    dd if="$KEYBLOCK" bs=16 count=1 skip=$i status=none | \
        xxd -p | grep -o .. | tac | echo "$(tr -d '\n')" | \
        xxd -p -r >> $TEMPDIR/kb1.bin
  done
openssl enc -d -aes-256-ecb -K `cat $TEMPDIR/kek1.hex` \
    -nopad -in $TEMPDIR/kb1.bin -out $TEMPDIR/kb2.bin
for i in `seq 0 31`; do
    dd if=$TEMPDIR/kb2.bin bs=16 count=1 skip=$i status=none | \
        xxd -p | grep -o .. | tac | echo "$(tr -d '\n')" | \
        xxd -p -r >> $TEMPDIR/kb3.bin
  done

TEST=`dd if=$TEMPDIR/kb3.bin bs=16 skip=16 count=1 status=none | grep -ao "^DEK1"`
if [ -z "$TEST" ]; then
    echo "decryption of keyblock failed" 1>&2
    rm -rf $TEMPDIR
    exit 1;
  fi

dd if=$TEMPDIR/kb3.bin bs=1 skip=268 count=16 of=$TEMPDIR/dek0.bin status=none
dd if=$TEMPDIR/kb3.bin bs=1 skip=288 count=16 status=none >> $TEMPDIR/dek0.bin
xxd -p -c 32 $TEMPDIR/dek0.bin | grep -o .. | tac | echo "$(tr -d '\n')"

rm -rf $TEMPDIR

# end
