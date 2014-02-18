#!/usr/local/bin/perl
use strict;
use warnings;
use File::Find;
use Win32::Console::ANSI;
use Term::ANSIColor;
use File::Copy;

my $total = $#ARGV + 1;

if ( $total != 1 ){
    print "  usage: repLabel path\n\n  eg: repLabel c:\\project\\source\n";
    exit;
}

my @list;
my $len = 0;
my $root = $ARGV[0];
my $fileNum = 0;
my $fileCompleted = 0;

init($root);
print "There is(are) $fileNum file(s) under $root.\n";

replace($root);

exit 0;

sub init {
    my $path = $_[0];
    my $i = 0;
    my $j = 0;
    
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
    my $j;
    
    opendir my $DIR, $path or die "$!";
    while (my $file = readdir($DIR)) {
        if (-f "$path\\$file") {
            print "$path\\$file";
            
            #open (IN, "$path\\$file") or die "$!, opening $path\\$file\n";
            open (IN, "$path\\$file") or next;
            open (OUT, ">TEMP") or die "$!, opening TEMP\n";
            
            while ($line = <IN>) {
                for ($j = 0; $j < $len; $j += 1){
                    $line =~ s/\b$list[0][$j]\b/$list[1][$j]/g;
                }
                print OUT $line;
            }
            
            close OUT;
            close IN;
            
            rename("TEMP", "$path\\$file");
            unlink("TEMP");
            
            $fileCompleted += 1;
            
            print " ", color("green"), "completed\.", color("reset"), " [$fileCompleted/$fileNum]\n";
        } elsif ( $file ne "." and $file ne ".." ) {
            replace("$path\\$file");
        }
    }
    closedir($DIR);
}

