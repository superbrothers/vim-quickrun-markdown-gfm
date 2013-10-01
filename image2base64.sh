#!/usr/bin/env bash

html=`cat /dev/stdin`
images=''

IFS=$'\n'
for line in $html; do
    matches=`echo "$line" | egrep -o 'src=".*?"' | sed -e 's/src="\(.*\)"/\1/g' | egrep -v '^https?|js$|css$'`
    images="$images $matches"
done

for image in `echo "$images" | tr ' ' '\n' | sort | uniq`; do
    test ! -e "$image" && continue

    ext=`echo "$image" | grep -o '\w\+$'`
    base64=`cat "$image" | base64 | tr -d '\n'`
    html=`echo "$html" | sed -e 's#src="'$image'"#src="data:image/'$ext';base64,'$base64'"#g'`
done
echo "$html"
