#!/usr/bin/perl
# Copyright 2019 R. Scott Gustafson

while (<>) {
    chomp;
    $line = $_;
    for ($x = 0; $x < length $line; $x++) {
        $substring = substr $line, $x, 16;
        %seen = ( );
        @uniq = grep { ! $seen{$_} ++ } unpack('C*' , $substring);
        if ($#uniq == 15) {
            print $substring . "\n";
        }
    }
}

# cat message.txt | ./mission1.pl - | openssl enc -d -base64
# Curtisisland
