# gmb
gmb or gauntlet's microblog is a minimal interface to generate a static microblog and an appendant RSS feed.
It consists of one bash script using sed, grep, cut, date, echo and a bit of perl.
gmb will take either direkt input when invoked with no parameter or read a text file and process it when pointed to it at launch. Within the entries, all HTML elements that are legal in the body may be used (well, apart from header and footer).

It needs two prepared files, html and xml respectively, to write the blog and the RSS feed into. Sample files are in the output subfolder.

As the output is basic HTML, it can be styled quite extensively. While initially intended to be a microblog (hence the name), it turned out it may also be made to look just like a normal weblog.

See http://ctrl-cl.club/~gauntlet/gmb and http://ctrl-c.club/~gauntlet/projects/gmb/example.html for two different examples.
