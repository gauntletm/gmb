#!/bin/bash
# gauntlet's microblog
# by Gauntlet O. Manatee

# read config file; ask to create if not present
if [ -f ~/.config/gmb/gmbrc ]
then
  . ~/.config/gmb/gmbrc
else
  echo "Please create a config file at ~/.config/gmb/gmbrc"
  echo "See http://www.github.com/gauntletm/gmb/wiki for an example."
  exit
fi

# generate output files in case they are not available
if [ ! -f $drc/index.html ]
then
  echo -e '<!DOCTYPE html>\n<html lang='"$blgl"'>\n<head>\n<title>'"$blgt"'</title>\n<link rel="stylesheet" type="text/css" href="../css/style.css">\n<meta charset="UTF-8">\n<meta name="author" content="Gauntlet O. Manatee">\n</head>\n<body><div class="nav">&bull; <a href="..">home</a> &bull; microblog &bull; <a href="../projects">projects</a> &bull; <a href="../contact">contact</a> &bull; <a href="http://ctrl-c.club">host</a> &bull; </div>\n<hr>\n<div class="subnav"><a href="rss.xml">rss</a> <a href="archive.html">archive</a> <a href="../projects/gmb/">about</a></div>\n<hr>\n<div class="cont">\n<!-- class="ew" do not remove this line! !.mfg! -->\n</div\n</body>\n</html>' > $drc/index.html
fi

if [ ! -f $drc/rss.xml ]
then
  echo -e '<?xml version="1.0" encoding="UTF-8"?>\n<rss version="2.0">\n<channel>\n<title>'"$blgt"'</title>\n<link>'"$blgu"'</link>\n<description>'"$blgd"'</description>\n<language>'"$blgl"'</language>\n<!-- do not remove this line at all! <item> <!.mfg!> -->\n</channel>\n</rss>' > $drc/rss.xml
fi

# check for a parameter to read; if non is present, ask for manual input
if [ -z "$1" ]
then
  echo "Type your new entry, then hit return."
  read typed
else
  typed=`cat $1 | perl -pe "s/\n/ /"`
fi

# read the date after input, so if the script is invoked and left alone, the
# timestamp is not wrong.
date=`date --utc +%Y-%m-%d\ %H:%M`
id=`date --utc +%d%H%M%S`

# wrap the input in html, then find the line of the newest entry, then write before it.
# todo: id unneeded in actual blog; href to archive needed
aentry='  <div class="ew"><span id="'"$id"'" class="date"><a href="#'"$id"'">'"$date"'</a> </span><span>'"$typed"'</span></div>'
if [ $archive = 1 ]
then
  dpath=`date --utc +%y/%m`
  bentry='<div class="ew"><span class="date"><a href="'"$dpath"'#'"$id"'">'"$date"'</a> </span><span>'"$typed"'</span></div>'
else
  bentry='<div class="ew"><span class="date"><a href="#'"$id"'">'"$date"'</a> </span><span>'"$typed"'</span></div>'
fi
line=`grep -n -m 1 'class="ew"' $drc/index.html | cut -d: -f1`
sed -i "$line i\ $bentry" $drc/index.html

#
# rss from here on
#

function rss {
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
  link=''"$blgu"'#'"$id"
  rss='<item>\n<title>'"$title"'</title>\n<link>'"$link"'</link>\n<guid>'"$link"'</guid>\n<description><![CDATA['"$typed"']]></description>\n</item>'

  # write the new item to the rss file
  rline=`grep -n -m 1 '<item>' $drc/rss.xml | cut -d: -f1`
  sed -i "$rline i\ $rss" $drc/rss.xml


  # remove the oldest entries in the rss feed
  totrss=`grep -n "</item>" $drc/rss.xml | wc -l`
  if [ $totrss -gt $delr ]
  then
    gr=`grep -n "! <item> <!.mfg!>" $drc/rss.xml | cut -d: -f1 | tail -1`
    to=$[ $gr-1 ]
    from=$[ $to-5 ]
    sed -i "$from , $to d" $drc/rss.xml
  fi
}

#
# archive
#

function archive {
  # generate archive overview, if not present
  if [ ! -f $drc/archive.html ]
  then
    echo -e '<!DOCTYPE html>\n<html lang='"$blgl"'>\n<head>\n<title>'"$blgt"'</title>\n<link rel="stylesheet" type="text/css" href="../css/style.css">\n<meta charset="UTF-8">\n<meta name="author" content="Gauntlet O. Manatee">\n</head>\n<body><div class="nav">&bull; <a href="..">home</a> &bull; <a href=".">microblog</a> &bull; <a href="../projects">projects</a> &bull; <a href="../contact">contact</a> &bull; <a href="http://ctrl-c.club">host</a> &bull; </div>\n<hr>\n<p>Archive of '"$blgt"'</p>\n<div class="cont">\n<!-- class="arc" do not remove this line! -->\n</div\n</body>\n</html>' > $drc/archive.html
  fi
  # generate the archive
  mkdir -p $drc/$dpath
  # check for file (current month)
  if [ ! -f $drc/$dpath/index.html ]
  then
    arc=`date +%B\ %Y`
    echo -e '<!DOCTYPE html>\n<html>\n<head>\n<title>'"$blgt"', '"$arc"'</title>\n<link rel="stylesheet" type="text/css" href="../../../css/style.css">\n<meta charset="UTF-8">\n<meta name="author" content="Gauntlet O. Manatee">\n</head>\n<body><div class="nav">&bull; <a href="../../..">home</a> &bull; <a href="../..">microblog</a> &bull; <a href="../../../projects">projects</a> &bull; <a href="../../../contact">contact</a> &bull; <a href="http://ctrl-c.club">host</a> &bull; </div>\n<hr>\n<div class="cont">\n<!-- class="ew" -->\n</body>\n</html>' > $drc/$dpath/index.html
    # arcl is line in archive, arct is text to write in archive overview
    arct='<div class="arc"><a href="'"$drc"'/'"$dpath"'/index.html">'"$arc"'</a></div>'
    arcl=`grep -n -m 1 'class="arc"' $drc/archive.html | cut -d: -f1`
    sed -i "$arcl i\ $arct" $drc/archive.html
  fi

  # write content to archive
  line=`grep -n -m 1 'class="ew"' $drc/$dpath/index.html | cut -d: -f1`
  sed -i "$line i\ $aentry" $drc/$dpath/index.html

  # delete oldest entries on index page
  if [ `grep -n 'div class="ew"' $drc/index.html | wc -l` -gt $delb ]
  then
    # rm last matching line
    gr=`grep -n "line! !.mfg! --" $drc/index.html | cut -d: -f1 | tail -1`
    to=$[ $gr-1 ]
    sed -i "$to d" $drc/index.html
  fi
}

# actually generate rss feed and archive, if turned on in gmbrc
if [ $rss = 1 ]
then
  rss
fi

if [ $archive = 1 ]
then
  archive
fi
