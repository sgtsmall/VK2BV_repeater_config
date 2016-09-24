#!/usr/bin/env perl
#
# merges wia and local data
#

use strict;
use warnings;
no warnings 'experimental::smartmatch';


use Text::CSV_XS;
use List::MoreUtils qw(first_index);

our @Favourft;
require My::Favourites;

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

my $sortseq = '0  sortseq,';

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
# output this header with sortseq 
print $vksofh $sortseq, join(',', @fieldsrd), "\n";

#read the header line of the local input
my @fieldssd = @{$csv->getline($vksdfh)};

# Read each line from the CSV file, and store it in @rows

# repeater list
while (my $rowrd = $csv->getline($vkrdfh)) {
    my %datard;
    @datard{@fieldsrd} = @$rowrd;
    if (   ($datard{'mode'} ~~ ["DV", "FM"])
        && ($datard{'band'} ~~ ["2", "7", "C4FM"])
        && ((($datard{'Input'} < '470.0') && ($datard{'Input'} > '400.0')) || (($datard{'Input'} < '148.0') && ($datard{'Input'} > '144.0')))
     ) {
         $sortseq = lsortseq(@$rowrd);
         print $vksofh $sortseq, join(',', @$rowrd), "\n";
    }
}
# local maintained file
while (my $rowrd = $csv->getline($vksdfh)) {
    my %datard;
    @datard{@fieldssd} = @$rowrd;
    if (   ($datard{'mode'} ~~ ["DV", "FM"])
        && ($datard{'band'} ~~ ["2", "7", "C4FM"])
        && ($datard{'Output'} < '470.0'))
    {
         $sortseq = lsortseq(@$rowrd);
         print $vksofh $sortseq, join(',', @$rowrd), "\n";
    }
}



# Close the file handle.
close $vkrdfh;
close $vksdfh;
close $vksofh;

sub lsortseq    {
        my %datard;
        @datard{@fieldsrd} = @_ ;
        $sortseq     = 'Z,';
        my $dirs     = '';        
        my $dirn     = sprintf("%s", $datard{'dirkat'});
        my $distcsyd = sprintf("%s", $datard{'distsyd'});
        my $distcmel = sprintf("%s", $datard{'distmel'});
        my $distctmb = sprintf("%s", $datard{'disttmb'});
        my $bankfld  = sprintf("%s", $datard{'bank'});
        my $prefix   = sprintf("%.3s", $datard{'Call U'});
        my $prefix6  = sprintf("%.6s", $datard{'Call U'});

#DEBUG print "$cnt,$prefix ";
        if (grep { $prefix6 eq $_ } @Favourft) {
        my $subsort = first_index { $prefix6 eq $_ } @Favourft ;
             $sortseq = sprintf('01%s,',$subsort );
        }
        elsif ($bankfld eq '') {
            for ($prefix) {
                if (($prefix eq 'VK1') || ($prefix eq 'VK2')) {
                    if ($distcsyd eq '') {
                        $sortseq = 'A1,';
                        }
                    elsif ($distcsyd <= '60000') {
                        $sortseq = '02,';
                        }
                    else {
                        if ($dirn eq '') {
                        $sortseq = 'A1,';
                        }
                        else {
                            $dirs = $dirn + 157.5;
                            if ($dirs lt 180) {    #West
                                $sortseq = '05,';
                            }
                            elsif ($dirs gt 360) {    #West
                                $sortseq = '05,';
                            }
                            elsif ($dirs lt 270) {    #North
                                $sortseq = '04,';
                            }
                            elsif ($dirs le 360) {    #South
                                $sortseq = '03,'; 
                            }
                        }
                    }
                }
                elsif ($prefix eq 'VK3') {
                    if ($distcmel eq '') {
                        $sortseq = 'A3,';
                        }
                    elsif ($distcmel <= '80000') {
                        $sortseq = '10,';
                        }
                    else {
                        $sortseq = '11,';
                        }
                }
                elsif ($prefix eq 'VK4') {
                    if ($distctmb eq '') {
                        $sortseq = 'A4,'; 
                        }
                    elsif ($distctmb <= '80000') {
                        $sortseq = '20,';
                        }
                    else {
                        $sortseq = '21,';
                        }
                }
                elsif ($prefix eq 'VK5') {
                    if ($distcmel eq '') {
                        $sortseq = 'A5,';
                        }
                    else {
                        $sortseq = '25,'
                        }
                }
                elsif ($prefix eq 'VK6') {
                    if ($distcmel eq '') {
                        $sortseq = 'A6,';
                        }
                    else {
                        $sortseq = '26,';
                        }
                }
                elsif ($prefix eq 'VK7') {
                    if ($distcmel eq '') {
                        $sortseq = 'A7,';
                        }
                    else {
                        $sortseq = '27,';
                        }
                }
                elsif ($prefix eq 'VK8') {
                    if ($distcmel eq '') {
                        $sortseq = 'A8,';
                        }
                    else {
                        $sortseq = '28,';
                        }
                }
                elsif ($prefix eq 'APR') {
                    if ($datard{'Call U'} eq 'APRSAU') {
                        $sortseq = '30,';
                    }
                    elsif ($datard{'Call U'} eq 'APRWIC') {
                        $sortseq = '31,';
                    }
                    elsif ($datard{'Call U'} eq 'APRISS') {
                        $sortseq = '32,';
                    }
                    else {
                        $sortseq = '33,';
                    }
                }
                else {
                        $sortseq = '40,';
                }
            }
        }
        else {
            $sortseq = '40,';
            if ($bankfld eq '6') {
                $sortseq = 'A,';
            }
            elsif ($bankfld eq '15'){
                $sortseq = 'B,';
            }
        }

        return $sortseq 
    }


exit
