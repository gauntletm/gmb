#!/bin/bash
# gmb 0.4.1
# 2017-02-04
# Gauntlet O. Manatee <spukspital@openmailbox.org>

if [ -f ~/.config/gmb/gmbrc ]
then
  . ~/.config/gmb/gmbrc
else
  echo "Please create a config file at ~/.config/gmb/gmbrc"
  echo "See http://www.github.com/gauntletm/gmb/wiki for an example."
  exit
fi

if [ ! -f $blogdir/index.html ]
then
  postdate=$(date --utc +%Y-%m-%d)
  echo -e '<!DOCTYPE html>\n<html lang="'"$bloglang"'">\n<head>\n<title>'"$blogtitle"'</title>\n<meta charset="UTF-8">\n<meta name="author" content="'"$author"'">\n<link rel="alternate" type="application/rss+xml" title="'"$blogdesc"'" href="'"$blogurl"'rss.xml">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n</head>\n<body>\n<h1>'"$blogtitle"'</h1>\n<h3>'"$postdate"'</h3>\n<ul>\n</ul>\n</body>\n</html>' > $blogdir/index.html
fi

if [ ! -f $blogdir/rss.xml ]
then
  echo -e '<?xml version="1.0" encoding="UTF-8"?>\n<rss version="2.0">\n<channel>\n<title>'"$blogtitle"'</title>\n<link>'"$blogurl"'</link>\n<description>'"$blogdesc"'</description>\n<language>'"$bloglang"'</language>\n<!-- <item> -->\n</channel>\n</rss>' > $blogdir/rss.xml
fi

# check for a parameter to read; if non is present, ask for manual input
if [ -z "$1" ]
then
  echo "Type your new entry, then hit return."
  read typed
else
  typed=$(cat $1 | perl -pe "s/\n/ /")
fi

# get all the relevant times and dates
postdate=`date --utc +%Y-%m-%d`
permalink=`date --utc +%Y%m/%d%H%M%S`
time=`date --utc +%H:%M`

function writeinfile {

# will find the line with the most current date ... or rather check wether there was a post today
# set line to be an integer so we can calculate later
typeset -i line
line=$(grep -n -m 1 $postdate $workdir/index.html | cut -d: -f1)

# will find the line with the most current date ... or rather check wether there was a post today
# set line to be an integer so we can calculate later
typeset -i line
line=$(grep -n -m 1 $postdate $workdir/index.html | cut -d: -f1)

# check for postdate
if [ "$line" -eq "0" ]
then
  # find uppermost <h3>
  line=$(grep -n -m 1 "<h3>" $workdir/index.html | cut -d: -f1)
  # write new postdate plus entry above
  sed -i "$line i\<h3>$postdate</h3>\n<ul>\n<li><p>[<a href="$archpath$permalink.html">$time</a>] $typed</p></li>\n</ul>" $workdir/index.html
else
  line=$line+2
  # write only the entry 2 lines below postdate
  sed -i "$line i\<li><p>[<a href="$archpath$permalink.html">$time</a>] $typed</p></li>" $workdir/index.html
fi
}

archpath=archive/
workdir=$blogdir
writeinfile


# write into monthly archive
monarch=$(date --utc +%Y%m)
mkdir -p $archdir/$monarch
if [ ! -f $archdir/$monarch/index.html ]
then
echo -e '<!DOCTYPE html>\n<html lang="'"$bloglang"'">\n<head>\n<title>Archive of '"$blogtitle"'</title>\n<meta charset="UTF-8">\n<meta name="author" content="'"$author"'">\n<link rel="alternate" type="application/rss+xml" title="'"$blogdesc"'" href="'"$blogurl"'rss.xml">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n</head>\n<body>\n<h1>'"$blogtitle"'</h1>\n<p><a href="../..">blog</a> - <a href="..">archive</a></p>\n<h3>'"$postdate"'</h3>\n<ul>\n</ul>\n</body>\n</html>' > $archdir/$monarch/index.html
fi

archpath=../
workdir=$archdir/$monarch
writeinfile


link=$(date --utc +%B\ %Y)
if [ ! -f $archdir/index.html ]
then
echo -e '<!DOCTYPE html>\n<html lang="'"$bloglang"'">\n<head>\n<title>Archive of '"$blogtitle"'</title>\n<meta charset="UTF-8">\n<meta name="author" content="'"$author"'">\n<link rel="alternate" type="application/rss+xml" title="'"$blogdesc"'" href="'"$blogurl"'rss.xml">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n</head>\n<body>\n<h1>'"$blogtitle"'</h1>\n<p><a href="..">blog</a></p>\n<p><a href='"$monarch"'>'"$link"'</a></p>\n</body>\n</html>' > $archdir/index.html
fi
archline=$(grep -n -m 1 $(date --utc +%Y%m) $archdir/index.html | cut -d: -f1)
if [ -z "$archline" ]
then
  archline=$(grep -n -m 1 '<p><a' $archdir/index.html | cut -d: -f1)
 # link=`date --utc +%B\ %Y`
  sed -i "$archline i\<p><a href=\"$monarch\">$link</a></p>" $archdir/index.html
fi


# write standalone blog entry
echo -e '<!DOCTYPE html>\n<html lang="'"$bloglang"'">\n<head>\n<title>'"$blogtitle"'</title>\n<meta charset="UTF-8">\n<meta name="author" content="'"$author"'">\n<link rel="alternate" type="application/rss+xml" title="'"$blogdesc"'" href="'"$blogurl"'rss.xml">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n</head>\n<body>\n<h1>'"$blogtitle"'</h1>\n<a href="../..">blog</a> - <a href="..">archive</a>\n<h3>'"$postdate"'</h3>\n<ul>\n<li><p>['"$time"'] '"$typed"'</p></li>\n</ul>\n<p>(<a href=".">entire month</a>)</p>\n</body>\n</html>' > $archdir/$permalink.html


# delete oldest entries
if [ $(grep h3 $blogdir/index.html | wc -l) -gt $delblog ]
then
  h3del=$(grep -n "h3" $blogdir/index.html | tail -1 | cut -d: -f 1)
  uldel=$(grep -n "/ul" $blogdir/index.html | tail -1 | cut -d: -f 1)
  sed -i -e "$h3del,$(echo $uldel)d" $blogdir/index.html
fi


function rss {
  # write rss feed
    # cut the words for the title if the string is too long
    # remove html tags, because they cause trouble in the feed
    length=$(echo $typed | wc -w)
    if [ "$length" -gt "5" ]
    then
      title="$(echo $typed | sed -e 's/<[^>]*>//g' | cut -d' ' -f-5) ..."
    else
      title="$(echo $typed | sed -e 's/<[^>]*>//g')"
    fi

    link=''"$blogurl"'archive/'"$permalink"'.html'

    rssl='<item>\n<title>'"$title"'</title>\n<link>'"$link"'</link>\n<guid>'"$link"'</guid>\n<description><![CDATA[<p>'"$typed"'</p>]]></description>\n</item>'

    # write the new item to the rss file
    rline=$(grep -n -m 1 '<item>' $blogdir/rss.xml | cut -d: -f1)
    sed -i "$rline i\ $rssl" $blogdir/rss.xml


    # remove the oldest entries in the rss feed
    totrss=$(grep -n "</item>" $blogdir/rss.xml | wc -l)
    if [ $totrss -gt $delrss ]
    then
      gr=$(wc -l $blogdir/rss.xml | cut -d ' ' -f1)
      to=$[ $gr-2 ]
# set from 5 to 6. fix?
# set to 5 again. oO
      from=$[ $to-5 ]
      sed -i "$from , $to d" $blogdir/rss.xml
    fi
}

#if [ $rss -eq 1 ]
#then
rss
#fi
