repLabel
========

The repLabel is a script written by perl to replace labels which in *.c/*.h/*.txt/... files.
It can work with multiple files, and multiple keyword couples is acceptable.

* Make sure that you have [Perl](http://www.perl.org/) installed.

Usage
-----
<pre><code>    perl repLabel.pl <dir> <list>
OPTIONS
       <dir>
           Directory of source code to replace.
       <list>
           A file listing strings looks like this:
             oldstring1,newstring1
             oldstring2,newstring2
             ...
             oldstringN,newstringN
EXAMPLES
       repLabel c:\project\source c:\list.txt
</pre></code>
