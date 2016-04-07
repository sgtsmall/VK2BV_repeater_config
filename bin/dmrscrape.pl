#!/usr/bin/perl
# Simple DMR Contacts extraction.

# You might have to get this package from CPAN or PPM:
use strict;
use warnings;

use Text::CSV_XS;

my $csv = Text::CSV_XS->new({sep_char => ','});

#open userwork.dat
my $filei1 = $ARGV[0]
  or die "Need userwork.dat file on the command line\n";

# open contacts.csv
my $fileo1 = $ARGV[1] or die "Need output CSV file on the command line\n";

#Open Simplex-std file
open(my $dmrwfh, '<', $filei1) or die "Could not open '$filei1' $!\n";

#open output file
open(my $dmrofh, '>', $fileo1) or die "Could not open '$fileo1' $!\n";
#

my @fieldsrd = @{$csv->getline($dmrwfh)};

# repeater list
while (my $rowrd = $csv->getline($dmrwfh)) {
    my %datard;
    @datard{@fieldsrd} = @$rowrd;
    my $fullname = $datard{'Name'};
	my ($firstname, $lastname) = split (' ', $fullname);

    # Print the three items: ID, Callsign, Firstname
	print $dmrofh join (',', $datard{'Radio ID'}, $datard{'Callsign'}, $firstname), "\n";
    }
close $dmrofh;