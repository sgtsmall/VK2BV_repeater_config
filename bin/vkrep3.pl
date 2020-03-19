#!/usr/bin/perl
#
# Reads in Steve's VK2MD kml files and creates data with location and direction
#

use strict;
use warnings;


use XML::LibXML;
use Ham::Locator;
use Geo::Direction::Distance;

my $lltomh = Ham::Locator->new();
my $parser = XML::LibXML->new();
my $doc    = $parser->parse_file(shift @ARGV);

#VK3RCG
my @fromsydlatlng = (-33.8677935,151.2077336);

#VK3RCC
my @frommellatlng = (-37.81382239, 144.9694815);

# Tamborine in SE Queensland
my @fromtmblatlng = (-27.8702329, 153.0609623);

# calculate location for west point (katoomba)
my ($dir, $dist) = (281.000, 85000.00);
my @frommtnlatlng = dirdist2latlng(@fromsydlatlng, $dir, $dist);

# set txpower to 5 as default;
my $txpower = '5';

# bearing North-North-East (Coastal North) 22.5
# bearing South-South-West (Coastal South) 202.5

print
  "Call,freq,offset,ctcss,type,location,longditude,latitude,height,maidenhead,distsyd,dirsyd,dirkat,distmel,disttmb,txpower,bank\n";

foreach my $placemark ($doc->findnodes('/Document/Folder/Placemark')) {
    my ($coord) = $placemark->findnodes('./Point/coordinates');
    my ($name)  = $placemark->findnodes('./name');
    my @loc = split(',', $coord->to_literal);

    $lltomh->set_latlng($loc[1], $loc[0]);
    my @tolatlng = ($loc[1], $loc[0]);
    my ($dirsyd, $distsyd) = latlng2dirdist(@fromsydlatlng, @tolatlng);
    my ($dirmel, $distmel) = latlng2dirdist(@frommellatlng, @tolatlng);
    my ($dirtmb, $disttmb) = latlng2dirdist(@fromtmblatlng, @tolatlng);
    my ($dirmtn, $distmtn) = latlng2dirdist(@frommtnlatlng, @tolatlng);
    foreach my $repeater ($placemark->findnodes('./repgroup/repeater')) {

# dropping the dist from mtn
        my $line = sprintf(
            "%s,%s,%s,%s,%d,%.1f,%.1f,%.1f,%.1f,%s,\n",
            $repeater->to_literal, $name->to_literal,
            $coord->to_literal,    $lltomh->latlng2loc,
            $distsyd,              $dirsyd,
            $dirmtn,               $distmel,
            $disttmb,              $txpower
        );
        print $line;
    }
}
