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
    # Added date, ids, and times since the anomaly didn't seem to be the answer
    # keeping track of everything and then just printing them out at the end.
    $date = $item->{"date"};
    @ids = ();
    @times = ();
    
    # get the data for each hour and sum it
    foreach $reading (@{$item->{"readings"}}) {
        push @sums, sum values $reading->{"contaminants"};
        push @ids, $reading->{"id"};
        push @times, $reading->{"time"};
    }
    $stddev = stddev(@sums)->query; # calculate the standard deviation for the day
    push @stddevs, $stddev;
    $stddevmap{$stddev} = $date;
    push @{$sumsmap{$date}},  @sums;
    push @{$idsmap{$date}}, @ids;
    push @{$timesmap{$date}}, @times;
}

$maxstddev = max @stddevs; # find the largest standard deviation of all the days
$date = %stddevmap{$maxstddev}; # lookup what day that happened
print "Date: " . $date . "\n";
$anomaly = max @{%sumsmap{$date}}; # find the largest anomaly for that day
print "Anomaly: " . $anomaly . "\n";
# since the answer didn't seem to be the largest anomaly like the sample data shows,
# then I ended up keeping more data and trying that, so tried the ID for the given hour
# it happened as well
for ($x = 0; $x < @{%sumsmap{$date}}; $x++) {
    if (@{%sumsmap{$date}}[$x] == $anomaly) {
        last;
    }
}
print "Time: " . @{%timesmap{$date}}[$x] . "\n";
print "ID: " . @{%idsmap{$date}}[$x] . "\n";

# Date: 25-Dec-2018
# Anomaly: 1249458
# Time: 5
# ID: 4B554E47524144

# if the answer was just the anomaly, this would be a lot shorter.
# 
# Not sure what the answer they are expecting for this puzzle as I tried 
# several different ones. Since the original puzzle said that each contaminat
# could varry widely, then the stddev of those is meaningless.
