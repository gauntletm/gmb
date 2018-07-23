#!/bin/bash
. ~/.config/gmb/gmbrc

# defining files
tempfile=$(mktemp)
blogpost=$archdir/$1
archiveindex=$archdir/$(echo $1 | head -c 6)/index.html
rss=$blogdir/rss.xml
blogindex=$blogdir/index.html

grep -m 1 "<p>" $archdir/$1 > $tempfile

$editor $tempfile
templine=]$(cat $tempfile | cut -d] -f 2)

# using } as delimiter because / is common in html and } is not
sed -i "$(grep -n $1 $blogpost | cut -d: -f 1)s}].*$}$templine}" $blogpost
sed -i "$(grep -n $1 $archiveindex | cut -d: -f 1)s}].*$}$templine}" $archiveindex

# replace if still on index page
if $(grep -q $1 $blogindex)
then
  sed -i "$(grep -n $1 $blogindex | cut -d: -f 1)s}].*$}$templine}" $blogindex
fi

# replace if still in rss feed
if $(grep -q $1 $rss)
then
templine=$(echo $templine | sed 's}] }<p>}' | sed 's}</li>}}')
sed -i "$[ $(grep -n "$1</guid>" $rss | cut -d: -f 1) +1 ]s}\[CDATA\[.*\]\]}\[CDATA\[$templine\]\]}" $rss
fi

rm $tempfile
