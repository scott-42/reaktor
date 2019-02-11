#!/usr/bin/perl
#
# Copyright 2019 R. Scott Gustafson
#
# https://tracking-game.reaktor.com/parts/per/billion/play
# While the levels of any given contaminant vary wildly over time,
# the total level of all contaminants combined should remain within
# a standard deviation at all times.

use JSON qw( decode_json );
use Statistics::Basic  qw(:all nofill);
use List::Util qw(max sum);

open (LOG, "< mission2.txt")
    or die "Couldn't open mission2.txt for reading: $!\n";

$data = "";

# the input file is in binary, so convert it back to text
# one byte at a time
while (<LOG>) {
    chomp;
    @numbers = split ' ';
    foreach (@numbers) {
        $data .= chr(oct("0b$_"));
    }
}
close (LOG);

# turn out the text is JSON so decode it
@decoded_json = decode_json( $data );

# this is not a generalized json parsing but more specific
# to this problem.
foreach $item (@{$decoded_json[0]}) { # foreach day
    @sums = ();
    $date = $item->{"date"};
    @ids = ();
    
    # get the data for each hour and sum it
    foreach $reading (@{$item->{"readings"}}) {
        push @sums, sum values $reading->{"contaminants"};
        push @ids, $reading->{"id"};
    }
    $stddev = stddev(@sums)->query; # calculate the standard deviation for the day
    push @stddevs, $stddev;
    $stddevmap{$stddev} = $date;
    push @{$sumsmap{$date}},  @sums;
    push @{$idsmap{$date}}, @ids;
}

$maxstddev = max @stddevs; # find the largest standard deviation of all the days
$date = %stddevmap{$maxstddev}; # lookup what day that happened
$anomaly = max @{%sumsmap{$date}}; # find the largest anomaly for that day

for ($x = 0; $x < @{%sumsmap{$date}}; $x++) {
    if (@{%sumsmap{$date}}[$x] == $anomaly) {
        last;
    }
}

# dumb answer incoming. The ID is apparently ASCII characters represented as hex
print join '', map chr, map hex, unpack "(A2)*", @{%idsmap{$date}}[$x];
print "\n";

# KUNGRAD
