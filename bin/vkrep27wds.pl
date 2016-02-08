#!/usr/bin/env perl
#
# merges wia and local data
#

use strict;
use warnings;

use Text::CSV_XS;

#use List::Util qw(first);
#use Scalar::Util qw(looks_like_number);

my $csv = Text::CSV_XS->new({sep_char => ','});

#open vkrepdir.csv
my $filei1 = $ARGV[0] or die "Need orig CSV file on the command line\n";

#open vkrepstd.csv
my $filei2 = $ARGV[1]
  or die "Need standard,simplex CSV file on the command line\n";

# open vkrepout.csv
my $fileo1 = $ARGV[2] or die "Need output CSV file on the command line\n";

my $cnt  = 2;
my $call = '';

#my $head = '';
#my $sort = '0Sort';
#my $type = '';
#my $offdata = '';
#my @kmllist ;
my $cntfld     = '';
#my @Favourites = qw{'VK2RBV 4'};


# Load arrays with file contents
#Open input file
open(my $vkrdfh, '<', $filei1) or die "Could not open '$filei1' $!\n";

#Open Simplex-std file
open(my $vksdfh, '<', $filei2) or die "Could not open '$filei2' $!\n";

#open output file
open(my $vksofh, '>', $fileo1) or die "Could not open '$fileo1' $!\n";
#

#read the header line of the main input
my @fieldsrd = @{$csv->getline($vkrdfh)};

#
print $vksofh join(',', @fieldsrd), "\n";

#read the first line of the standard input this contains our p1 (home)
#my @rowssd = @{ $csv->getline( $vkrdfh ) };
#my $rowsd = $csv->getline ($vksdfh);
#print $vksofh join (',',@$rowsd),"\n";

#read the second line of the standard input for now this is vk2rbv as fm
#my @rowssd = @{ $csv->getline( $vkrdfh ) };
#$rowsd = $csv->getline ($vksdfh);
#print $vksofh join (',',@$rowsd),"\n";


# Read each line from the wia CSV file, and store it in @rows
my @rowsrd;
while (my $rowrd = $csv->getline($vkrdfh)) {
    my %datard;
    @datard{@fieldsrd} = @$rowrd;    # This is a hash slice
    push @rowsrd, \%datard;
    if (   ($datard{'mode'} ~~ ["DV", "FM"])
        && ($datard{'band'} ~~ ["7", "2", "DST"]))
    {
        print $vksofh join(',', @$rowrd), "\n";
    }
}

# Read each line from the std (local) CSV file, and store it in @rows
while (my $rowsd = $csv->getline($vksdfh)) {
    my %datard;
    @datard{@fieldsrd} = @$rowsd;    # This is a hash slice
    push @rowsrd, \%datard;
    if (   ($datard{'mode'} ~~ ["DV", "FM"])
        && ($datard{'band'} ~~ ["7", "2", "DST"]))
    {
        print $vksofh join(',', @$rowsd), "\n";
    }
}


# Close the file handle.
close $vkrdfh;
close $vksdfh;
close $vksofh;

exit
