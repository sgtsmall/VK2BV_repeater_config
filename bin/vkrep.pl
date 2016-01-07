#!/opt/local/bin/perl

use strict;
use warnings;


use XML::LibXML;

my $parser = XML::LibXML->new();
my $doc    = $parser->parse_file(shift @ARGV);

foreach my $placemark ($doc->findnodes('/Document/Folder/Placemark')) {
    my ($coord) = $placemark->findnodes('./Point/coordinates');
    my ($name)  = $placemark->findnodes('./name');
    foreach my $repeater ($placemark->findnodes('./repgroup/repeater')) {
        print $repeater->to_literal, ",", $name->to_literal, ",",
          $coord->to_literal, "\n";
    }
}
