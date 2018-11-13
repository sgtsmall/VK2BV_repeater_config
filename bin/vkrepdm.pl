#!/opt/local/bin/perl
#
# merges wia and local data
#

use strict;
use warnings;
no warnings 'experimental::smartmatch';


use Text::CSV_XS;
use List::MoreUtils qw(first_index);
our @Favourds;
require My::Favourites;

my $csv = Text::CSV_XS->new({sep_char => ','});

#open vkrepdir.csv
my $filei1 = $ARGV[0] or die "Need orig CSV file on the command line\n";

#open vkrepstd.csv
my $filei2 = $ARGV[1] or die "Need standard,simplex CSV file on the command line\n";

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

my $sortseqfld = '0  sortseqfld,';

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
# output this header with sortseqfld
print $vksofh $sortseqfld, join(',', @fieldsrd), "\n";

#read the header line of the local input
my @fieldssd = @{$csv->getline($vksdfh)};

# Read each line from the CSV file, and store it in @rows

# repeater list
while (my $rowrd = $csv->getline($vkrdfh)) {
    my %datard;
    @datard{@fieldsrd} = @$rowrd;
    if (   ($datard{'mode'} ~~ ["DV", "FM"])
        && ($datard{'band'} ~~ ["2","7","DMR"])
        && ( (($datard{'Input'} < '470.0') && ($datard{'Input'} > '144.0')) && (($datard{'Output'} < '470.0') && ($datard{'Output'} > '144.0')))
     ) {
         $sortseqfld = lsortseqfld(@$rowrd);
         print $vksofh $sortseqfld, join(',', @$rowrd), "\n";
    }
}
# local maintained file
while (my $rowrd = $csv->getline($vksdfh)) {
    my %datard;
    @datard{@fieldssd} = @$rowrd;
    if (   ($datard{'mode'} ~~ ["DV", "FM"])
        && ($datard{'band'} ~~ ["2", "7", "DMR"])
        && ($datard{'Output'} < '480.0'))
    {
         $sortseqfld = lsortseqfld(@$rowrd);
         print $vksofh $sortseqfld, join(',', @$rowrd), "\n";
    }
}



# Close the file handle.
close $vkrdfh;
close $vksdfh;
close $vksofh;

sub lsortseqfld    {
        my %datard;
        @datard{@fieldsrd} = @_ ;
        $sortseqfld     = 'Z,';
        my $dirs     = '';
        my $dirn     = sprintf("%s", $datard{'dirkat'});
        my $distcsyd = sprintf("%s", $datard{'distsyd'});
        my $distcmel = sprintf("%s", $datard{'distmel'});
        my $distctmb = sprintf("%s", $datard{'disttmb'});
        my $bankfld  = sprintf("%s", $datard{'bank'});
        my $prefix   = sprintf("%.3s", $datard{'Call U'});
        my $prefix6  = sprintf("%.6s", $datard{'Call U'});

#DEBUG print "$cnt,$prefix6 ";
        if (grep { $prefix6 eq $_ } @Favourds) {
            my $subsort = first_index { $prefix6 eq $_ } @Favourds ;
            $sortseqfld = sprintf('01%s,',$subsort );
        }
        elsif ($bankfld eq '') {
            for ($prefix) {
                if (($prefix eq 'VK1') || ($prefix eq 'VK2')) {
                    if ($distcsyd eq '') {
                        $sortseqfld = 'A,';
                        }
                    elsif ($distcsyd <= '60000') {
                        $sortseqfld = '02,';
                    }
                    else {
                        if ($dirn eq '') {
                        $sortseqfld = 'A,';
                        }
                        else {
                            $dirs = $dirn + 157.5;
                            if ($dirs lt 180) {    #West
                        $sortseqfld = '05,';
                            }
                            elsif ($dirs gt 360) {    #West
                        $sortseqfld = '05,';
                            }
                            elsif ($dirs lt 270) {    #North

                        $sortseqfld = '04,';
                            }
                            elsif ($dirs le 360) {    #South

                        $sortseqfld = '03,';                            }
                        }
                    }
                }
                elsif ($prefix eq 'VK3') {
                    if ($distcmel eq '') {
                        $sortseqfld = 'A,';
                        }
                    elsif ($distcmel <= '80000') {
                        $sortseqfld = '10,';
                        }
                    else {
                        $sortseqfld = '11,';
                        }
                }
                elsif ($prefix eq 'VK4') {
                    if ($distctmb eq '') {
                        $sortseqfld = 'A,';
                        }
                    elsif ($distctmb <= '80000') {

                        $sortseqfld = '20,';
                        }
                    else {
                        $sortseqfld = '21,';
                        }
                }
                elsif (($prefix eq 'VK5') || ($prefix eq 'VK8')) {
                        $sortseqfld = '25,';
                        }
                elsif ($prefix eq 'VK6') {

                        $sortseqfld = '28,';
                        }
                elsif ($prefix eq 'VK7') {
                        $sortseqfld = '29,';
                        }
                elsif ($prefix eq 'APR') {
                    if ($datard{'Call U'} eq 'APRSAU') {
                        $sortseqfld = '30,';
                        }
                    elsif ($datard{'Call U'} eq 'APRWIC') {
                        $sortseqfld = '31,';
                        }
                    elsif ($datard{'Call U'} eq 'APRISS') {
                        $sortseqfld = '32,';
                        }
                    else {
                        $sortseqfld = '33,';
                        }
                }
                else {
                        $sortseqfld = '40,';
                        }
            }
        }
        else {
            $sortseqfld = '40,';
            if ($bankfld eq '6') {
                $sortseqfld = 'A,';
            }
            elsif ($bankfld eq '15'){
                $sortseqfld = 'B,';
            }
        }

        return $sortseqfld
    }

exit
