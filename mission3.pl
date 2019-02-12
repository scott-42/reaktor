#!/usr/bin/perl
#
# Copyright 2019 R. Scott Gustafson
#
# https://tracking-game.reaktor.com/flood/play
# analyze the soil levels to find suspicious one-day changes in flood danger

use JSON qw( decode_json );
use Data::Dumper;

open (LOG, "< mission3.txt")
    or die "Couldn't open mission3.txt for reading: $!\n";
# looks like JSON so decode it
$decoded_json = decode_json(<LOG>);
close (LOG);

# print Dumper $decoded_json->{"regions"};

foreach $region (@{$decoded_json->{"regions"}}) { # foreach day
    print $region->{"regionID"};
    foreach $reading (@{$region->{"readings"}}) {
        # print " " . $reading->{"reading"};
    }
    print "\n";
}