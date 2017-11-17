#!/bin/bash

FILE="$1"
DEVICE="`echo $FILE | cut -d / -f 3`"

SIZE=`cat /proc/partitions | grep -e "$DEVICE" | awk '{print $3}' | head -n 1`
SIZE=`expr $SIZE \* 2`

LOWERLIMIT=`expr $SIZE - 8192` # 4 MB should be enough

FOUND="n"
for i in `seq $SIZE -1 $LOWERLIMIT`; do
    FIRSTLINE=`dd if=/dev/$DEVICE skip=$i count=1 status=none | xxd -p | head -n 1`
    if [ `echo $FIRSTLINE | grep "^57447631"` ]; then
        echo "found JMicron keyblock at sector $i"
        FOUND="y"
        break
      fi
    if [ `echo $FIRSTLINE | grep "^574d5953"` ]; then
        echo "found Symwave keyblock at sector $i"
        FOUND="y"
        break
      fi
    if [ `echo $FIRSTLINE | grep "^57440114"` ]; then
        echo "found Initio keyblock at sector $i"
        FOUND="y"
        break
      fi
    if [ `echo $FIRSTLINE | grep "^53496e45"` ]; then
        echo "found PLX keyblock at sector $i"
        FOUND="y"
        break
      fi
  done
if [ "$FOUND" = "y" ]; then
    echo "dumping to keyblock-$i.bin"
    dd if=/dev/$DEVICE skip=$i count=1 of=keyblock-$i.bin status=none
    exit
  fi
echo "keyblock not found"
