#!/bin/bash
# usage: bash oxuf943se-extract-DEK-from-EEPROM-keyblock.sh <kek file (hex)> <keyblock file (binary)>

KEK="$1"
KEYBLOCK="$2"
TEMPDIR=`mktemp -d ./WDXXXXXXXX`

cat "$KEK" | grep -o ........ | tac | echo "$(tr -d '\n')" > $TEMPDIR/kek1.hex

dd if="$KEYBLOCK" bs=2 skip=9 count=32 of=$TEMPDIR/kb1.bin status=none
openssl enc -d -aes-256-ecb -K `cat $TEMPDIR/kek1.hex` -nopad \
    -in $TEMPDIR/kb1.bin -out $TEMPDIR/kb2.bin

# hexdump -C $TEMPDIR/kb2.bin

checksum=`dd if=$TEMPDIR/kb2.bin bs=16 skip=3 count=1 status=none | md5sum | cut -d ' ' -f 1`
if [ "$checksum" != "4ae71336e44bf9bf79d2752e234818a5" ]; then
    echo "PROBABLE FAILURE in extracting the DEK"
  fi

dd if=$TEMPDIR/kb2.bin bs=32 count=1 status=none | xxd -p -c 32 > $TEMPDIR/dek1.hex
cat $TEMPDIR/dek1.hex | grep -o ........ | tac | echo "$(tr -d '\n')"

rm -rf $TEMPDIR

# end
