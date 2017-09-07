KEK=`echo -n "WDC.$1" | iconv -f UTF-8 -t UTF-16LE | xxd -p -c 64`
for i in `seq 1 1000`; do
    KEK=`echo -n $KEK | xxd -p -r | sha256sum | cut -d ' ' -f 1`
  done
echo $KEK
