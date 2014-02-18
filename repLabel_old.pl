#!/usr/local/bin/perl
use strict;
use warnings;
use File::Find;
use Win32::Console::ANSI;
use Term::ANSIColor;

my $total = $#ARGV + 1;

if ( $total != 1 ){
    print "  usage: repLabel path\n\n  eg: repLabel c:\\project\\source\n";
    exit;
}

my @list;
my $len;
#my $root="D:\\sunyt\\40_71_DF\\02_Script\\replbl\\sample_new";
my $root=$ARGV[0];

init();
find(\&handle, $root);


sub init
{
    my $i = 0;
    
    open (MYFILE, 'list.txt');
    while (<MYFILE>) {
        chomp;
        /([^,]*),(.*)/;
        $list[0][$i] = $1;
        $list[1][$i] = $2;
        $i += 1;
    }
    close (MYFILE);
    
    $len = $i;
}


sub handle
{
    my $file = $File::Find::name;
    my $line;
    my $j;
    return if -d $file;
    
    print "$file ";
    
    open (IN, $file) or die "$!, opening $file\n";
    open (OUT, ">TEMP") or die "$!, opening TEST\n";
    
    while ($line = <IN>)
    {
        for ($j = 0; $j < $len; $j += 1){
            $line =~ s/\b$list[0][$j]\b/$list[1][$j]/g;
        }
        print OUT $line;
    }
    
    close OUT;
    close IN;
    
    rename("TEMP", $file);
    unlink("TEMP");
    
    print "[", color("green"), "Complete", color("reset"), "]\n";
}

