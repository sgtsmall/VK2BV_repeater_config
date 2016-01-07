#!/opt/local/bin/perl

# this seems to be a test script only

use strict;
use warnings;


use XML::LibXML;

sub l2n {
    my ($self, $letter) = @_;

    my $lw = lc $letter;

    my $index = {
        'a' => 0,
        'b' => 1,
        'c' => 2,
        'd' => 3,
        'e' => 4,
        'f' => 5,
        'g' => 6,
        'h' => 7,
        'i' => 8,
        'j' => 9,
        'k' => 10,
        'l' => 11,
        'm' => 12,
        'n' => 13,
        'o' => 14,
        'p' => 15,
        'q' => 16,
        'r' => 17,
        's' => 18,
        't' => 19,
        'u' => 20,
        'v' => 21,
        'w' => 22,
        'x' => 23
    };

    return $index->{$lw};
}

sub n2l {
    my ($self, $number) = @_;

    my $index = {
        0  => 'a',
        1  => 'b',
        2  => 'c',
        3  => 'd',
        4  => 'e',
        5  => 'f',
        6  => 'g',
        7  => 'h',
        8  => 'i',
        9  => 'j',
        10 => 'k',
        11 => 'l',
        12 => 'm',
        13 => 'n',
        14 => 'o',
        15 => 'p',
        16 => 'q',
        17 => 'r',
        18 => 's',
        19 => 't',
        20 => 'u',
        21 => 'v',
        22 => 'w',
        23 => 'x'
    };

    return $index->{$number};
}

sub lnglat2loc {
    my ($self) = @_;

    if ($self->get_lnglat eq "") {
        return 0;
    }

    my $lnglat = $self->get_lnglat;

    my $field_lng = @{$lnglat}[0];
    my $field_lat = @{$lnglat}[1];

    my $locator;

    my $lat = $field_lat + 90;
    my $lng = $field_lng + 180;

    # Field
    $lat = ($lat / 10) + 0.0000001;
    $lng = ($lng / 20) + 0.0000001;
    $locator .= uc($self->n2l(floor($lng))) . uc($self->n2l(floor($lat)));

    # Square
    $lat = 10 * ($lat - floor($lat));
    $lng = 10 * ($lng - floor($lng));
    $locator .= floor($lng) . floor($lat);

    # Subsquare
    $lat = 24 * ($lat - floor($lat));
    $lng = 24 * ($lng - floor($lng));
    $locator .= $self->n2l(floor($lng)) . $self->n2l(floor($lat));

    # Extended square
    $lat = 10 * ($lat - floor($lat));
    $lng = 10 * ($lng - floor($lng));
    $locator .= floor($lng) . floor($lat);

    # Extended Subsquare
    $lat = 24 * ($lat - floor($lat));
    $lng = 24 * ($lng - floor($lng));
    $locator .= $self->n2l(floor($lng)) . $self->n2l(floor($lat));

    if ($self->get_precision) {
        return substr $locator, 0, $self->get_precision;
    }
    else {
        return $locator;
    }
}

my ($self) = @_;
my $parser = XML::LibXML->new();
my $doc    = $parser->parse_file(shift @ARGV);

foreach my $placemark ($doc->findnodes('/Document/Folder/Placemark')) {
    my ($coord)      = $placemark->findnodes('./Point/coordinates');
    my ($name)       = $placemark->findnodes('./name');
    my ($get_lnglat) = $coord;
    my ($lltomh)     = lnglat2loc($coord);
    foreach my $repeater ($placemark->findnodes('./repgroup/repeater')) {
        print $repeater->to_literal, ",", $name->to_literal, ",",
          $coord->to_literal, "\n";
    }
}
