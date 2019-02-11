#!/usr/bin/perl
#
# Copyright 2019 R. Scott Gustafson
#
# https://tracking-game.reaktor.com/signal/vs/noise/play
# Find the message in the text.
# 16 bytes long and contains no repeating characters

use MIME::Base64;

open (MESSAGE, "< mission1.txt")
    or die "Couldn't open mission1.txt for reading: $!\n";

while (<MESSAGE>) {
    chomp;
    $line = $_;
    for ($x = 0; $x < length $line; $x++) {
        $substring = substr $line, $x, 16;
        %seen = ( );
        @uniq = grep { ! $seen{$_} ++ } unpack('C*' , $substring);
        if ($#uniq == (16 - 1)) {
            print decode_base64($substring) . "\n";
            last;
        }
    }
}

close (MESSAGE);

# Curtisisland
