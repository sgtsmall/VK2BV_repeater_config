#!/usr/bin/env perl
#

use strict;
use warnings;
my $command=`perl -v`;
print $command;
use XML::LibXML;
use Ham::Locator;
use Geo::Direction::Distance;
use Text::CSV_XS;

my $lltomh = Ham::Locator->new();

#VK3RCG
my @fromsydlatlng = (-33.86429172, 151.2115417);

#VK3RCC
my @frommellatlng = (-37.81382239, 144.9694815);
printf ("\n\nThis script tests some of the functions that are needed\n\n");

my ($dirtest, $disttest) = latlng2dirdist(@fromsydlatlng, @frommellatlng);
printf ("Test latlng calculation direction: %s distance: %s\n", $dirtest, $disttest) ;
$lltomh->set_latlng($fromsydlatlng[0], $fromsydlatlng[1]);
printf ("Test maidenhead: %s \n", $lltomh->latlng2loc) ;