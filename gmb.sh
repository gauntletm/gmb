#!/bin/bash
# gauntlet's micro blog
# by Gauntlet O. Manatee
# 2016-07-15

# check for a parameter to read; if non is present, ask for manual input
if [ -z "$1" ]; then
  echo "Type your new entry, then hit return."
  read typed
else
  typed=`cat $1 | perl -pe "s/\n/ /"`
fi

# read the date after input, so if the script is invoked and left alone, the
# timestamp is not wrong.
# time set to UTC to be coherent when used on different servers.
date=`date --utc +%Y-%m-%d\ %H:%M`
id=`date --utc +%Y%m%d%H%M%S`

# wrap the input in html, then find the line of the newest entry, then write before it.
entry='  <div class="ew"><span id="'"$id"'" class="date"><a href="#'"$id"'">'"$date"'</a> </span><span>'"$typed"'</span></div>'
line=`grep -n -m 1 'class="ew"' blog.html | cut -d: -f1`
sed -i "$line i $entry" blog.html

# rss from here on

# cut the words for the title if the string is too long
# remove html tags, because they cause trouble in the feed
length=$(echo $typed | wc -w)
if [ "$length" -gt "5" ]
then
  title="`echo $typed | sed -e 's/<[^>]*>//g' | cut -d' ' -f-5` ..."
else
  title="`echo $typed | sed -e 's/<[^>]*>//g'`"
fi

# insert the link to your blog here for RSS to work
# also, keep the # so the anchor is set correctly
link='YOUR_URL_HERE#'"$id"
rss='<item>\n<title>'"$title"'</title>\n<link>'"$link"'</link>\n<guid>'"$link"'</guid>\n<description><![CDATA['"$typed"']]></description>\n</item>'

# as above, find the newest entry line, then write the new item right before it
# to the rss file.
rline=`grep -n -m 1 '<item>' rss.xml | cut -d: -f1`
sed -i "$rline i $rss" rss.xml
