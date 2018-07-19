# gmb
gmb or gauntlet's microblog is a minimal interface to generate a static microblog and an appendant RSS feed.
It consists of one bash script using sed, grep, cut, date, echo.
gmb will take either direkt input when invoked with no parameter or read a text file and process it when pointed to it at launch. Within the entries, all HTML elements that are legal in the body may be used.

See http://ctrl-c.club/~gauntlet/gmb/ for an example.

## Setup

1. Download gmbrc, gmb.sh and gpe.sh
2. Move gmbrc to ``~/.config/gmb/gmbrc`` and edit it to set appropriate values.
3. Move gmb.sh and gpe.sh to ``~/bin`` and make them executable. If necessary, add ``~/bin`` to your $PATH.
4. gmb is now ready for use.

## Usage

Either launch gmb in interactive mode by simple invoking the script, then type your entry or prepare a textfile anywhere in your ~ and hand the absolute path to gmb as an argument.

Note that, as of now, gmb will only read one single line. Line breaks may be forced by either using the br tag or by closing the automatically added p tag and opening a new one.

## Updating/editing entries
gpe.sh (gauntlet's post editor) helps to update the individual files that store the content of each blog post.

The string behind the second to last forward slash in an entries permanent path is handed to gpe.sh as an argument. The script will then read the necessary line, open nano (I know, I know ... noob editor hardcoded to the script) and allow for changes to be made. Saving and closing the editor will then have gpe.sh update the affected files.

As an example, suppose an entry was written on 2018-01-02 at 22:42:11 UTC. gpe.sh would be launched like so:

``$ gpe.sh 201801/02224211.html``

