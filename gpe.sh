#!/bin/bash
. ~/.config/gmb/gmbrc

mkdir -p ~/tmp
# better use mktemp

# defining files
pedfile=~/tmp/ped
blogpost=$archdir/$1
archiveindex=$archdir/$(echo $1 | head -c 6)/index.html
rss=$blogdir/rss.xml
blogindex=$blogdir/index.html

grep -m 1 "<p>" $archdir/$1 > $pedfile

$editor $pedfile
ped=]$(cat $pedfile | cut -d] -f 2)

# using } as delimiter because / is common in html and } is not
sed -i "$(grep -n $1 $blogpost | cut -d: -f 1)s}].*$}$ped}" $blogpost
sed -i "$(grep -n $1 $archiveindex | cut -d: -f 1)s}].*$}$ped}" $archiveindex

# replace if still on index page
if $(grep -q $1 $blogindex)
then
  sed -i "$(grep -n $1 $blogindex | cut -d: -f 1)s}].*$}$ped}" $blogindex
fi

# replace if still in rss feed
if $(grep -q $1 $rss)
then
ped=$(echo $ped | sed 's}] }<p>}' | sed 's}</li>}}')
sed -i "$[ $(grep -n "$1</guid>" $rss | cut -d: -f 1) +1 ]s}\[CDATA\[.*\]\]}\[CDATA\[$ped\]\]}" $rss
fi

rm ~/tmp/ped
