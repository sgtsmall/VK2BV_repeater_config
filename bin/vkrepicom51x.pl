#!/usr/bin/env perl
#
# Creates a data file for the Icom D-Star radios
#
# For newer radios the "digital" repeater group method allows DV and FM stations to be stored with location detail.
#
# repeaters are grouped into:
#  g3  - dv
#  g22 - FMAusSE (vk1,2,3,7)
#  g23 - FMAusNW (vk4,5,6,8)
#  g24 - Simplex, APRS
# The "memory" method requires groups of up to 100. These can be organised into banks for scan etc.
#
# Need to manage the simplex and personal memories better,
# currently selection of memories 100,200,300 are based on distance from std, mel and tmb.
# mem 400 is APRS and could include other simplex.
#
# 26 Bank Names A - Z
# A - Fav, B - CBD, C Sth, D Nth, E West, F Other, G MEL, H VK3, I TMB, J VK4, VK5-8, VK6, VK7, N APRS, O - Test, .. X- Marine
# Mem
# Bank
#CH No,Frequency,Dup,Offset,TS,Mode,Name,SKIP,TONE,Repeater Tone,TSQL Frequency,DTCS Code,DTCS Polarity,DV SQL,DV CSQL Code,Your Call Sign,RPT1 Call Sign,RPT2 Call Sign
#
use strict;
use warnings;

use Text::CSV_XS;
our @Favourds;
require My::Favourites;

my $csv = Text::CSV_XS->new({sep_char => ','});

#open vkrepdir.csv
my $file1 = $ARGV[0] or die "Need to main CSV file on the command line\n";

# open vkrepft-2dr.csv
my $file2pre = $ARGV[1] or die "Need to merge CSV file on the command line\n";
my $memcnt0  = '-1';
my $memcnt1  = '-1';
my $memcnt2  = '-1';
my $memcnt3  = '-1';
my $memcnt4  = '-1';

my $memcntba  = '-1'; #dstar
my $memcntbb  = '-1'; #syd
my $memcntbc  = '-1'; #vk2S
my $memcntbd  = '-1'; #vk2N
my $memcntbe  = '-1'; #vk2W
my $memcntbf  = '-1'; #simplex
my $memcntbg  = '-1'; #mel
my $memcntbh  = '-1'; #vk3
my $memcntbi  = '-1'; #tmb
my $memcntbj  = '-1'; #vk4
my $memcntbk  = '-1'; #vk5-8
my $memcntbl  = '-1'; #vk6
my $memcntbm  = '-1'; #vk7
my $memcntbn  = '-1'; #aprs
#my $memcntbo  = '-1'; #test


my @CallUuniq;

#my $cnt = 0;
my $call       = '';
my $cntfld     = '';
my $utcoffset  = '';
my @grpnum     = qw{3 22 23 24};
my @grpnam     = qw{AusDV FMAus FMAusNW Local};
my @utco10     = qw{VK1 VK2 Vk3 VK4 VK7};
my @utco95     = qw{VK5 VK8};
my @utco08     = qw{VK6};

# Load arrays with file contents
#Open input file
open(my $vkrdfh, '<', $file1) or die "Could not open '$file1' $!\n";

#open output file
my $file21 = sprintf("%sg3.csv",   $file2pre);
my $file22 = sprintf("%sg22.csv",  $file2pre);
my @g22    = qw{VK1 VK2 VK3 VK7};
my $file23 = sprintf("%sg23.csv",  $file2pre);
my @g23    = qw{VK4 VK5 VK6 VK8};
my $file24 = sprintf("%sg24.csv",  $file2pre);
my $file25 = sprintf("%smem0.csv", $file2pre);
my $file26 = sprintf("%smem1.csv", $file2pre);
my $file27 = sprintf("%smem2.csv", $file2pre);
my $file28 = sprintf("%smem3.csv", $file2pre);
my $file29 = sprintf("%smem4.csv", $file2pre);

my $banka = sprintf("%sbanka.csv", $file2pre);
my $bankb = sprintf("%sbankb.csv", $file2pre);
my $bankc = sprintf("%sbankc.csv", $file2pre);
my $bankd = sprintf("%sbankd.csv", $file2pre);
my $banke = sprintf("%sbanke.csv", $file2pre);
my $bankf = sprintf("%sbankf.csv", $file2pre);
my $bankg = sprintf("%sbankg.csv", $file2pre);
my $bankh = sprintf("%sbankh.csv", $file2pre);
my $banki = sprintf("%sbanki.csv", $file2pre);
my $bankj = sprintf("%sbankj.csv", $file2pre);
my $bankk = sprintf("%sbankk.csv", $file2pre);
my $bankl = sprintf("%sbankl.csv", $file2pre);
my $bankm = sprintf("%sbankm.csv", $file2pre);
my $bankn = sprintf("%sbankn.csv", $file2pre);
#my $banko = sprintf("%sbanko.csv", $file2pre);


open(my $icgfh1, '>', $file21) or die "Could not open '$file21' $!\n";
open(my $icgfh2, '>', $file22) or die "Could not open '$file22' $!\n";
open(my $icgfh3, '>', $file23) or die "Could not open '$file23' $!\n";
open(my $icgfh4, '>', $file24) or die "Could not open '$file24' $!\n";
open(my $icgfh5, '>', $file25) or die "Could not open '$file25' $!\n";
open(my $icgfh6, '>', $file26) or die "Could not open '$file26' $!\n";
open(my $icgfh7, '>', $file27) or die "Could not open '$file27' $!\n";
open(my $icgfh8, '>', $file28) or die "Could not open '$file28' $!\n";
open(my $icgfh9, '>', $file29) or die "Could not open '$file29' $!\n";

open(my $icbfha, '>', $banka) or die "Could not open '$banka' $!\n";
open(my $icbfhb, '>', $bankb) or die "Could not open '$bankb' $!\n";
open(my $icbfhc, '>', $bankc) or die "Could not open '$bankc' $!\n";
open(my $icbfhd, '>', $bankd) or die "Could not open '$bankd' $!\n";
open(my $icbfhe, '>', $banke) or die "Could not open '$banke' $!\n";
open(my $icbfhf, '>', $bankf) or die "Could not open '$bankf' $!\n";
open(my $icbfhg, '>', $bankg) or die "Could not open '$bankg' $!\n";
open(my $icbfhh, '>', $bankh) or die "Could not open '$bankh' $!\n";
open(my $icbfhi, '>', $banki) or die "Could not open '$banki' $!\n";
open(my $icbfhj, '>', $bankj) or die "Could not open '$bankj' $!\n";
open(my $icbfhk, '>', $bankk) or die "Could not open '$bankk' $!\n";
open(my $icbfhl, '>', $bankl) or die "Could not open '$bankl' $!\n";
open(my $icbfhm, '>', $bankm) or die "Could not open '$bankm' $!\n";
open(my $icbfhn, '>', $bankn) or die "Could not open '$bankn' $!\n";
#open(my $icbfho, '>', $banko) or die "Could not open '$banko' $!\n";


#open(my $icgfh2, '>', '$file2pre'g22.csv ) or die "Could not open '$file2' $!\n";
#open(my $icgfh3, '>', $file2) or die "Could not open '$file2' $!\n";
#open(my $icgfh4, '>', $file2) or die "Could not open '$file2' $!\n";
#
my $newhea1 =
  'Group No,Group Name,Name,Sub Name,Repeater Call Sign,Gateway Call Sign,';
my $newhea2 = 'Frequency,Dup,Offset,Mode,TONE,Repeater Tone,RPT1USE,';
my $newhea3 = 'Position,Latitude,Longitude,UTC Offset';

my $newhead = sprintf("%s%s%s", $newhea1, $newhea2, $newhea3);
#
if ($csv->parse($newhead)) {
    print $icgfh1 $csv->string, "\n";
    print $icgfh2 $csv->string, "\n";
    print $icgfh3 $csv->string, "\n";
    print $icgfh4 $csv->string, "\n";
}
else {
    print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
    $csv->error_diag();
}

my $newheb1 = 'CH No,Frequency,Dup,Offset,TS,Mode,Name,SKIP,';
my $newheb2 = 'TONE,Repeater Tone,TSQL Frequency,DTCS Code,DTCS Polarity,';
my $newheb3 =
  'DV SQL,DV SQL Code,Your Call Sign,RPT1 Call Sign,RPT2 Call Sign';

my $newhebd = sprintf("%s%s%s", $newheb1, $newheb2, $newheb3);
#
if ($csv->parse($newhebd)) {
    print $icgfh5 $csv->string, "\n";
    print $icgfh6 $csv->string, "\n";
    print $icgfh7 $csv->string, "\n";
    print $icgfh8 $csv->string, "\n";
    print $icgfh9 $csv->string, "\n";
    print $icbfha $csv->string, "\n";
    print $icbfhb $csv->string, "\n";
    print $icbfhc $csv->string, "\n";
    print $icbfhd $csv->string, "\n";
    print $icbfhe $csv->string, "\n";
    print $icbfhf $csv->string, "\n";
    print $icbfhg $csv->string, "\n";
    print $icbfhh $csv->string, "\n";
    print $icbfhi $csv->string, "\n";
    print $icbfhj $csv->string, "\n";
    print $icbfhk $csv->string, "\n";
    print $icbfhl $csv->string, "\n";
    print $icbfhm $csv->string, "\n";
    print $icbfhn $csv->string, "\n";
#    print $icbfho $csv->string, "\n";
    
}
else {
    print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
    $csv->error_diag();
}

#read the header line of the main input
my @fields = @{$csv->getline($vkrdfh)};

# Read each line from the CSV file, and store it in @rows
my @rows;
while (my $row = $csv->getline($vkrdfh)) {
    my %data;
    @data{@fields} = @$row;    # This is a hash slice

    push @rows, \%data;

# This radio can handle DStar and FM on 2 and 70
    if (   ($data{'mode'} ~~ ["DV", "FM"])
        && ($data{'band'} ~~ ["7", "2", "DST"])
        && ($data{'Output'} < '450.0'))
    {
#        $cnt +=1;
        my $CallUufld = sprintf("%s", $data{'Call U'});
        if (grep { $CallUufld eq $_ } @CallUuniq) {

            #   print "$CallUufld not unique\n";
            my $cuniq = '64';
            while (grep { $CallUufld eq $_ } @CallUuniq) {
                $cuniq += 1;
                my $ccuniq = chr($cuniq);
                my $tCallUufld = substr $CallUufld, 6, 1, $ccuniq;
            }
            print "Inserting $CallUufld\n";
            push @CallUuniq, $CallUufld;
        }
        else {
            push @CallUuniq, $CallUufld;
        }

#DEBUG      print "Station: $data{'Call U'}, Output: $data{Output}\n";
#
        my $CallG  = '';
        my $Urcall = '';
        if ($data{'mode'} eq 'DV') {
            $CallG = sprintf("%.7sG", $data{'Call U'});
            $Urcall = 'CQCQCQ';
        }
        my $prefix6  = sprintf("%.6s", $data{'Call U'});
# Name,Sub Name,
        my $dispname = '';
        if ($data{'mNemonic'} eq '-') {
            $dispname = sprintf("%.16s", $data{'Location'});
        }
        else {
            $dispname = sprintf("%.16s", $data{'mNemonic'});
        }
        my $newdat1 = sprintf("%s,%.8s,", $dispname, $data{'Service Area'});

#Repeater Call Sign,Gateway Call Sign,'
        my $newdat2 = sprintf("%s,%s,", $CallUufld, $CallG);

#Frequency,Dup,Offset,Mode,

        my $newdat3 = sprintf("%s,%s,%.3f,%s,",
            $data{'Output'}, $data{'tdup'}, $data{'absoff'}, $data{'mode'});
#

#TONE,Repeater Tone,RPT1USE,
#TONE - Tone only, TSQL - Tone Squelch
        my $tonemode = '';
        if ($data{'Tone'} eq '-') {
            $tonemode = 'OFF,';
        }
        else {
            $tonemode = sprintf("TSQL,%sHz", $data{'Tone'});
        }

# RPT1USE,
# use this logic for RPT1 USE
#
        my $Rptuseg = 'NO';
        my $Rptskip = 'PSkip';
        if (grep { $prefix6 eq $_ } @Favourds) {
            $Rptuseg = 'YES';
            $Rptskip = 'OFF'
        }

my $newdat4 = sprintf("%s,%s,", $tonemode, $Rptuseg);

#  'CH No,
#my $chnum = sprintf("%s,",$cnt);
#Frequency,Dup,Offset,TS,Mode,' ;
        my $newdab1 = sprintf("%s,%s,%.3f,,%s,",
            $data{'Output'}, $data{'tdup'}, $data{'absoff'}, $data{'mode'});

#$newdab1,
# 'Name,SKIP,TONE,Repeater Tone,TSQL Frequency,DTCS Code,DTCS Polarity,' ;
# $tonemode == TONE,Repeater Tone
        my $newdab2 = sprintf("%s,%s,%s,,,,", $dispname, $Rptskip, $tonemode);

#$newdab2
#'DV SQL,DV SQL Code,Your Call Sign,RPT1 Call Sign,RPT2 Call Sign' ;
        my $newdab3 = sprintf(",,%s,%s,%s,", $Urcall, $CallUufld, $CallG);

#,$newdab3,$newdab4
#


#
        my $dirn   = sprintf("%s", $data{'dirkat'});
        my $dirs = '';
        my $distcsyd = sprintf("%s", $data{'distsyd'});

#    my $distcmel = sprintf ("%s",$data{'distmel'});
#    my $distctmb = sprintf ("%s",$data{'disttmb'});
#DEBUG print ("$data{'Call U'}-$dirn-$dirs-$distc\n");

        my $prefix = sprintf("%.3s", $data{'Call U'});

#DEBUG print "$cnt,$prefix ";
#get this working with the array!!!

        my $grpnum = '';
        my $grpnam = '';
        my $outfh  = $icgfh1;
        my $oudfh  = $icgfh5;
        my $oubfh  = $icbfha;
        my $chnum  = 'UNDEF';
        my $bchnum = 'UNDEF';





        if ($data{'mode'} eq "DV") {
            $grpnum = '3,';
            $grpnam = 'AusDV,';
            $outfh  = $icgfh1;
            $oudfh  = $icgfh5;
            $oubfh  = $icbfha;
            $memcntba += 1;
            $bchnum = $memcntba;
            $memcnt0 += 1;
            $chnum = $memcnt0;
        }
        elsif (grep { $prefix eq $_ } @g22) {
            $grpnum = '22,';
            $grpnam = 'FMAusSE,';
            $outfh  = $icgfh2;
        }
        elsif (grep { $prefix eq $_ } @g23) {
            $grpnum = '23,';
            $grpnam = 'FMAusNW,';
            $outfh  = $icgfh3;
        }
        else {
            $grpnum = '24,';
            $grpnam = 'Simplex,';
            $outfh  = $icgfh4;
        }
        if ($data{'mode'} eq "FM" && ($data{'distsyd'} ne '')) {
            if (($prefix eq 'VK1') || ($prefix eq 'VK2')) {
                $oudfh = $icgfh6;
                $memcnt1 += 1;
                $chnum = $memcnt1;
                if ($data{'distsyd'} <= '60000') {
                    $oubfh = $icbfhb;
                    $memcntbb += 1;
                    $bchnum = $memcntbb;
                }
                else { # improve later
                    $dirs = $dirn + 157.5;
                    if (($dirs lt 180) || ($dirs gt 360)) { #west
                        $oubfh = $icbfhe;
                        $memcntbe += 1;
                        $bchnum = $memcntbe;                    
                    }
                    elsif ($dirs lt 270) {    #North
                        $oubfh = $icbfhd;
                        $memcntbd += 1;
                        $bchnum = $memcntbd;                    
                    }
                    elsif ($dirs le 360) {    #South
                        $oubfh = $icbfhc;
                        $memcntbc += 1;
                        $bchnum = $memcntbc;                    
                    }
                }
            }
            elsif ($prefix eq 'VK3') {
                $oudfh = $icgfh7;
                $memcnt2 += 1;
                $chnum = $memcnt2;
                if ($data{'distmel'} <= '80000') {
                    $oubfh = $icbfhg;
                    $memcntbg += 1;
                    $bchnum = $memcntbg;
                }
                else { # improve later
                    $oubfh = $icbfhh;
                    $memcntbh += 1;
                    $bchnum = $memcntbh;
                }
            }
            elsif ($prefix eq 'VK4')  {
                $oudfh = $icgfh8;
                $memcnt3 += 1;
                $chnum = $memcnt3;
                if ($data{'disttmb'} <= '80000') {
                    $oubfh = $icbfhi;
                    $memcntbi += 1;
                    $bchnum = $memcntbi;
                }
                else { # improve later
                    $oubfh = $icbfhj;
                    $memcntbj += 1;
                    $bchnum = $memcntbj;
                }
            }
            elsif (($prefix eq 'VK5') || ($prefix eq 'VK8')) {
                $oudfh = $icbfhk;
                $memcntbk += 1;
                $chnum = $memcntbk;
            }
            elsif ($prefix eq 'VK6') {
                $oudfh = $icbfhl;
                $memcntbl += 1;
                $chnum = $memcntbl;
            }
            elsif ($prefix eq 'VK7') {
                $oudfh = $icbfhm;
                $memcntbm += 1;
                $chnum = $memcntbm;
            }

        }
        elsif ($data{'mode'} eq "FM" && $prefix eq 'APR') {
            $oudfh = $icgfh9;
            $memcnt4 += 1;
            $chnum = $memcnt4;
            $oubfh = $icbfhn;
            $memcntbn += 1;
            $bchnum = $memcntbn;
        }
        elsif ($data{'mode'} eq "FM" ) {
            #$oudfh = $icgfh9;
            #$memcnt4 += 1;
            #$chnum = $memcnt4;
            $oubfh = $icbfhf;
            $memcntbf += 1;
            $bchnum = $memcntbf;
        }
        
        $utcoffset = '+10:00';
        if (grep { $prefix eq $_ } @utco10) {
            $utcoffset = '+10:00';
        }
        elsif (grep { $prefix eq $_ } @utco95) {
            $utcoffset = '+09:30';
        }
        elsif (grep { $prefix eq $_ } @utco08) {
            $utcoffset = '+08:00';
        }

# Position,Latitude,Longitude,UTC Offset
#
        my $newloc = sprintf("Approximate,%s,%s,", $data{'latitude'},
            $data{'longditude'});
#
        my $newline = sprintf(
            "%s%s%s%s%s%s%s%s",
            $grpnum,  $grpnam,  $newdat1, $newdat2,
            $newdat3, $newdat4, $newloc,  $utcoffset
        );
#
        if ($csv->parse($newline)) {
            print $outfh $csv->string, "\n";
        }
        else {
            print STDERR "parse () failed on argument: ", $csv->error_input,
              "\n";
            $csv->error_diag();
        }

# output to *mem.csv
        if ($chnum ne 'UNDEF') {
            my $newlinb =
              sprintf("%s,%s%s%s", $chnum, $newdab1, $newdab2, $newdab3);
            if ($csv->parse($newlinb)) {
                print $oudfh $csv->string, "\n";
            }
            else {
                print STDERR "parse () failed on argument: ",
                  $csv->error_input, "\n";
                $csv->error_diag();
            }
        }
        if ($bchnum ne 'UNDEF') {
            my $newlinb =
              sprintf("%s,%s%s%s", $bchnum, $newdab1, $newdab2, $newdab3);
            if ($csv->parse($newlinb)) {
                print $oubfh $csv->string, "\n";
            }
            else {
                print STDERR "parse () failed on argument: ",
                  $csv->error_input, "\n";
                $csv->error_diag();
            }
        }
    }
}

# Close the file handles.
close $vkrdfh;
close $icgfh1;

exit
