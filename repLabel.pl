#!/usr/local/bin/perl
use strict;
use warnings;
use File::Find;
use Win32::Console::ANSI;
use Term::ANSIColor;
use File::Copy;
use IO::Handle;
use Text::Tabs;
$tabstop = 4;

if ( ($#ARGV + 1) != 2 ){
    print "\n";
    print "USAGE\n";
    print "       perl repLabel.pl <dir> <list>\n";
    print "OPTIONS\n";
    print "       <dir>\n";
    print "           Directory of source code to replace.\n";
    print "       <list>\n";
    print "           A file listing strings looks like this:\n";
    print "             oldstring1,newstring1\n";
    print "             oldstring2,newstring2\n";
    print "             ...\n";
    print "             oldstringN,newstringN\n";
    print "EXAMPLES\n";
    print "       repLabel c:\\project\\source\ c:\\list.txt\n";
    print "\n";
    print "repLabel v1.0\n";
    exit;
}

my @list;
my $list_len = 0;
my $root = $ARGV[0];
my $listfile = $ARGV[1];

my $fileNum = 0;
my $fileCompleted = 1;

init($root,$listfile);
print "There is(are) $fileNum file(s) under $root.\n\n";
STDOUT->autoflush;
replace($root);
EndInfo();
exit 0;

sub init {
    my $path = $_[0];
    my $listfile = $_[1];
    my $i = 0;
    
    open (MYFILE, $listfile);
    while (<MYFILE>) {
        chomp;
        /([^,]*),(.*)/;
        $list[0][$i] = $1;  # old string
        $list[1][$i] = $2;  # new string
        $list[2][$i] = 0;   # replace counter
        $i += 1;
    }
    close (MYFILE);
    
    $list_len = $i;
    
    $fileNum = FileNum($path);
}


sub FileNum {
    my $path = $_[0];
    my $i = 0;
    
    opendir my $DIR, $path or die "$!";
    while (my $file = readdir($DIR)) {
        if (-f "$path\\$file") {
            $i += 1;
        } elsif ( $file ne "." and $file ne ".." ) {
            $i += FileNum("$path\\$file");
        }
    }
    closedir($DIR);
    
    return $i;
}


sub replace {
    my $path = $_[0];
    my $line;
    my $lineNum;
    my $j;
    my $old;
    my $rep_cnt_file;
    my $rep_cnt_line;
    my $align_succeed_cnt;
    my $align_failed_cnt;
    my $align_neednot_cnt;
    
    
    opendir my $DIR, $path or die "$!";
    while (my $file = readdir($DIR)) {
        if (-f "$path\\$file") {
            print " [$fileCompleted/$fileNum] $path\\$file";
            
            open (IN, "$path\\$file") or next;
            open (OUT, ">TEMP") or die "$!, opening TEMP\n";
            
            $lineNum = 1;
            $rep_cnt_file = 0;
            $align_succeed_cnt = 0;
            $align_failed_cnt = 0;
            $align_neednot_cnt = 0;
            while ($line = <IN>) {
                for ($j = 0; $j < $list_len; $j += 1){
                    $old = $line;
                    $rep_cnt_line = $line =~ s/\b$list[0][$j]\b/$list[1][$j]/g;
                    if ($rep_cnt_line) {
                        $list[2][$j] += 1;
                        $rep_cnt_file += $rep_cnt_line;
                        if (length(expand($line)) == length(expand($old))) {
                            $align_neednot_cnt += 1;
                        } else {
                            if ($line =~ m/\/\//) {
                                if (length(expand($line)) - length(expand($old)) == 4) {
                                    $line =~ s/\t\/\//\/\//g;
                                }
                                
                                if (length(expand($line)) != length(expand($old))) {
                                    $align_failed_cnt += 1;
                                    print "\n   Align comments failed:$path\\$file($lineNum)";
                                } else {
                                    $align_succeed_cnt += 1;
                                }
                            } else {
                                $align_neednot_cnt += 1;
                            }
                        }
                    }
                }
                print OUT $line;
                $lineNum += 1;
            }
            
            close OUT;
            close IN;
            
            rename("TEMP", "$path\\$file");
            unlink("TEMP");
            
            $fileCompleted += 1;
            
            print "\n   ", color("cyan"), "Replace:$rep_cnt_file  ", color("reset");
            print color("green"), "Align succeed: $align_succeed_cnt  ", color("reset");
            print color("yellow"), "Align not need: $align_neednot_cnt  ", color("reset");
            print color("red"), "Align failed: $align_failed_cnt\n", color("reset");
        } elsif ( $file ne "." and $file ne ".." ) {
            replace("$path\\$file");
        }
    }
    closedir($DIR);
}

sub EndInfo {
    my $j;
    
    print "\nReplace count of every keyword:\n\n";
    
    for ($j = 0; $j < $list_len; $j += 1){
        print "$list[0][$j],$list[1][$j],$list[2][$j]\n";
    }
}

