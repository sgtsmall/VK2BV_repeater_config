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
