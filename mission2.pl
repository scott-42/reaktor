#!/usr/bin/perl
# Copyright 2019 R. Scott Gustafson

#use JSON::Parse;
use JSON qw( decode_json );
use Data::Dumper;
use Statistics::Basic  qw(:all nofill);
use List::Util qw(max sum);

$data = "";

while (<>) {
    chomp;
    @numbers = split ' ';
    foreach (@numbers) {
        $data .= chr(oct("0b$_"));
    }
    
}
# print Dumper $data;

@decoded_json = decode_json( $data );

#print Dumper $decoded_json;

foreach $item ($decoded_json[0]) {
    # @stddevs = ();
    # %stddevmap;
    foreach $subitem (@$item) {
        # print $subitem . "\n";
        $date = $subitem->{"date"};

        # if ($date == '25-Dec-2018') {
        #     print Dumper $subitem;
        # }

        # print $date . "\n";
        # print $subitem->{"readings"} . "\n";
        $readings = $subitem->{"readings"};
        # print @readings . "\n";
        # print Dumper @readings;
        @sums = ();
        @ids = ();
        @times = ();
        foreach $reading (@$readings) {

            %contaminants = $reading->{"contaminants"};
            $id = $reading->{"id"};
            $time = $reading->{"time"};
            $sum = 0;
            # @vals = ();
            while ( ($k,$v) = each $reading->{"contaminants"} ) {
                # push @vals, $v;
                $sum += $v;
            }
            # print "$sum @vals\n";
            push @sums, $sum;
            push @ids, $id;
            push @times, $time;
            # print $reading->{"id"} . " $sum\n";
            # print Dumper $reading;
        }
        # print "@sums\n";
        $stddevobj = stddev(@sums);
        $stddev = $stddevobj->query;
        push @stddevs, $stddev;
        $stddevmap{$stddev} = $date;
        # print "$stddev\n";
        push @{$sumsmap{$date}},  @sums;
        push @{$idsmap{$date}}, @ids;
        push @{$timesmap{$date}}, @times;
        # print Dumper $sumsmap{$date};
    }
}

# @sorted = reverse(sort @stddevs);
# # print Dumper @sorted[0];
# $date = %stddevmap{@sorted[0]};
# print "Date: " . $date . "\n";
$maxstddev = max @stddevs;
# print Dumper @sorted[0];
$date = %stddevmap{$maxstddev};
print "Date: " . $date . "\n";
# print Dumper %idsmap{%stddevmap{$maxstddev}};
# @sortedsums = reverse(sort @{%sumsmap{%stddevmap{@sorted[0]}}});
# $anomaly = @sortedsums[0];
# print "Anomaly: " . $anomaly . "\n";
$anomaly = max @{%sumsmap{$date}};
print "Anomaly: " . $anomaly . "\n";
$idx = 0;
for ($x = 0; $x < @{%sumsmap{$date}}; $x++) {
    if (@{%sumsmap{$date}}[$x] == $anomaly) {
        $idx = $x;
        last;
    }
}
# print Dumper $idx;
print "Time: " . @{%timesmap{$date}}[$idx] . "\n";
print "ID: " . @{%idsmap{$date}}[$idx] . "\n";
# print Dumper %stddevmap;
# print Dumper %sumsmap{%stddevmap{$date}};

#
# 1249458
# 'id' => '4B554E47524144',
# '25-Dec-2018' 'time' => 5
# '48722.6571584857';

# Date: 25-Dec-2018
# Anomaly: 1249458
# Time: 5
# ID: 4B554E47524144

