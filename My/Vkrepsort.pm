#!/usr/bin/env perl
#
# merges wia and local data
#
package My::Vkrepsort;

use strict;
use warnings;

use Text::CSV_XS;
use List::MoreUtils qw(first_index);

our @Favourft;
require My::Favourites;
our @EXPORT_OK =qw(ltsortseq);

#use List::Util qw(first);
#use Scalar::Util qw(looks_like_number);

my @fieldsrd;
sub ltsortseq    {
        my (%datard, %fieldsrd);
        @datard{@fieldsrd} = @_ ;    # This is a hash slice
        my $sortseq     = 'Z,';
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
                        $sortseq = 'A,';
                        }
                    elsif ($distcsyd <= '60000') {
                        $sortseq = '02,';
                    }
                    else {
                        if ($dirn eq '') {
                        $sortseq = 'A,';
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

                        $sortseq = '03,';                            }
                        }
                    }
                }
                elsif ($prefix eq 'VK3') {
                    if ($distcmel eq '') {
                        $sortseq = 'A,';
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
                        $sortseq = 'A,'; 
                        }
                    elsif ($distctmb <= '80000') {

                        $sortseq = '20,';
                        }
                    else {
                        $sortseq = '21,';
                        }
                }
                elsif (($prefix eq 'VK5') || ($prefix eq 'VK8')) {
                        $sortseq = '25,';
                        }
                elsif ($prefix eq 'VK6') {

                        $sortseq = '28,';
                        }
                elsif ($prefix eq 'VK7') {
                        $sortseq = '29,';
                        }
                else {
                        $sortseq = '30,';
                        }
            }
        }
        else {
                        $sortseq = '30,';
            if ($bankfld eq '6') {
                                    $sortseq = 'A,';
            }
        }

        return $sortseq 
    }

1;