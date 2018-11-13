#!/opt/local/bin/perl
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
# A - Fav, B - CBD, C Sth, D Nth, E West, F Other, G MEL, H VK3, I TMB, J VK4, K VK5-8, L VK6, M VK7, N APRS, O - Test, S - ESO .., U Marine, V UHF
# Mem
# Bank
#CH No,Frequency,Dup,Offset,TS,Mode,Name,SKIP,TONE,Repeater Tone,TSQL Frequency,DTCS Code,DTCS Polarity,DV SQL,DV CSQL Code,Your Call Sign,RPT1 Call Sign,RPT2 Call Sign
#
use strict;
use warnings;
no warnings 'experimental::smartmatch';

use Text::CSV_XS;
our @Favourds;
our @FavdstrUR;
our @FavdstrR1;
require My::Favourites;

my $csv = Text::CSV_XS->new( { sep_char => ',' } );

#open vkrepdir.csv
my $file1 = $ARGV[0] or die "Need main CSV file on the command line\n";

# get output folder
my $file2pre = $ARGV[1] or die "Need output folder on the command line\n";
my $memcnt0  = '-1';
my $memcnt1  = '-1';
my $memcnt2  = '-1';
my $memcnt3  = '-1';
my $memcnt4  = '-1';

my $memcntba = '-1';    #dstar
my $memcntbb = '-1';    #syd
my $memcntbc = '-1';    #vk2S
my $memcntbd = '-1';    #vk2N
my $memcntbe = '-1';    #vk2W
my $memcntbf = '-1';    #simplex
my $memcntbg = '-1';    #mel
my $memcntbh = '-1';    #vk3
my $memcntbi = '-1';    #tmb
my $memcntbj = '-1';    #vk4
my $memcntbk = '-1';    #vk5-8
my $memcntbl = '-1';    #vk6
my $memcntbm = '-1';    #vk7
my $memcntbn = '-1';    #aprs
my $memcntbs = '-1';    #eso
my $memcntbu = '-1';    #marine
my $memcntbv = '-1';    #UHF
my $memcntbw = '-1';    #wicen
my $memcntbz = '-1';    #wicen

#my $memcntbx  = '-1'; #marine
#my $memcntbz = '-1';    #wicenemerg

#my $memcntbo  = '-1'; #test

my @CallUuniq;

#my $cnt = 0;
my $call      = '';
my $cntfld    = '';
my $TStext    = '';
my $utcoffset = '';
my $dstlab    = '';
my @grpnum    = qw{3 22 23 24 25 26};
my @grpnam    = qw{AusDV FMAus FMAusNW Local UHF Wicen};
my @utco10    = qw{VK1 VK2 Vk3 VK4 VK7};
my @utco95    = qw{VK5 VK8};
my @utco08    = qw{VK6};

# Load arrays with file contents
#Open input file
open( my $vkrdfh, '<', $file1 ) or die "Could not open '$file1' $!\n";

# to add more banks add to @bfiles and use in $oubfh;
#
#open output file
my @gfiles   = qw{ g3 g22 g23 g24 g25 g26 };
my @mfiles   = qw{ m0 m1 m2 m3 m4 };
my @bfiles   = qw{ ba bb bc bd be bf bg bh bi bj bk bl bm bn bs bu bv bw bz};
my @allfiles = ( @gfiles, @mfiles, @bfiles );
my %handles  = get_write_handles(@allfiles);
my @g22      = qw{VK1 VK2 VK3 VK7};
my @g23      = qw{VK4 VK5 VK6 VK8};
my @g25      = qw{UHF };
my @g26      = qw{ESO VRA WIC };
#
#
my $newhea1 =
  'Group No,Group Name,Name,Sub Name,Repeater Call Sign,Gateway Call Sign,';
my $newhea2 = 'Frequency,Dup,Offset,Mode,TONE,Repeater Tone,RPT1USE,';
my $newhea3 = 'Position,Latitude,Longitude,UTC Offset';

my $newhead = sprintf( "%s%s%s", $newhea1, $newhea2, $newhea3 );
#
if ( $csv->parse($newhead) ) {
    foreach (@gfiles) {
        print { $handles{$_} } $csv->string, "\n";
    }
}
else {
    print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
    $csv->error_diag();
}

my $newheb1 = 'CH No,Frequency,Dup,Offset,TS,Mode,Name,SKIP,';
my $newheb2 = 'TONE,Repeater Tone,TSQL Frequency,DTCS Code,DTCS Polarity,';
my $newheb3 = 'DV SQL,DV SQL Code,Your Call Sign,RPT1 Call Sign,RPT2 Call Sign';

my $newhebd = sprintf( "%s%s%s", $newheb1, $newheb2, $newheb3 );
#
if ( $csv->parse($newhebd) ) {
    foreach (@mfiles) {
        print { $handles{$_} } $csv->string, "\n";
    }
    foreach (@bfiles) {
        print { $handles{$_} } $csv->string, "\n";
    }
}
else {
    print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
    $csv->error_diag();
}

#exit;
#read the header line of the main input
my @fields = @{ $csv->getline($vkrdfh) };

# Read each line from the CSV file, and store it in @rows
my @rows;
while ( my $row = $csv->getline($vkrdfh) ) {
    my %data;
    @data{@fields} = @$row;    # This is a hash slice

    push @rows, \%data;

    # This radio can handle DStar and FM on 2 and 70
    if (   ( $data{'mode'} ~~ [ "DV", "FM" ] )
        && ( $data{'band'} ~~ [ "7", "2", "DST" ] )
        && ( $data{'Output'} < '490.0' )
        && ( $data{'bank'} ne "20" ) )
    {
        #        $cnt +=1;
        my $CallUufld = sprintf( "%s", $data{'Call U'} );
        if ( grep { $CallUufld eq $_ } @CallUuniq ) {

            #   print "$CallUufld not unique\n";
            my $cuniq = '64';
            while ( grep { $CallUufld eq $_ } @CallUuniq ) {
                $cuniq += 1;
                my $ccuniq = chr($cuniq);
                my $tCallUufld = substr $CallUufld, 6, 1, $ccuniq;
            }

            #            print "Inserting $CallUufld\n";
            push @CallUuniq, $CallUufld;
        }
        else {
            push @CallUuniq, $CallUufld;
        }

        #DEBUG      print "Station: $data{'Call U'}, Output: $data{Output}\n";
        #
        my $CallG  = '';
        my $Urcall = '';
        if ( $data{'mode'} eq 'DV' ) {
            $CallG = sprintf( "%.7sG", $data{'Call U'} );
            $Urcall = 'CQCQCQ';
        }
        my $prefix6 = sprintf( "%.6s", $data{'Call U'} );

        # Name,Sub Name,
        my $dispname = '';
        if ( $data{'mNemonic'} eq '-' ) {
            $dispname = sprintf( "%.16s", $data{'Location'} );
        }
        else {
            $dispname = sprintf( "%.16s", $data{'mNemonic'} );
        }
        my $newdat1 = sprintf( "%s,%.8s,", $dispname, $data{'Service Area'} );

        #Repeater Call Sign,Gateway Call Sign,'
        my $newdat2 = sprintf( "%s,%s,", $CallUufld, $CallG );

        #Frequency,Dup,Offset,Mode,

        my $newdat3 = sprintf( "%s,%s,%.3f,%s,",
            $data{'Output'}, $data{'tdup'}, $data{'absoff'}, $data{'mode'} );
        #

        #TONE,Repeater Tone,RPT1USE,
        #TONE - Tone only, TSQL - Tone Squelch
        my $tonemode = '';
        my $tonesql  = '';
        if ( $data{'Tone'} eq '-' ) {
            $tonemode = 'OFF,';
            $tonesql  = ',';
        }
        else {
#            $tonemode = sprintf( "TSQL,%sHz", $data{'Tone'} );
            $tonemode = sprintf( "TONE,%sHz", $data{'Tone'} );
            $tonesql  = sprintf( ",%sHz",     $data{'Tone'} );
        }

        # RPT1USE,
        # use this logic for RPT1 USE
        #
        my $Rptuseg = 'NO';
        my $Rptskip = 'PSkip';
        if ( grep { $prefix6 eq $_ } @Favourds ) {
            $Rptuseg = 'YES';
            $Rptskip = 'OFF';
        }

        my $newdat4 = sprintf( "%s,%s,", $tonemode, $Rptuseg );

        #  'CH No,
        #my $chnum = sprintf("%s,",$cnt);
        #Frequency,Dup,Offset,TS,Mode,' ;
        if ( $data{'TS'} ne '' ) {
            $TStext = sprintf( "%skHz", $data{'TS'} );
        }
        else {
            $TStext = '25kHz';
        }
        my $newdab1 = sprintf(
            "%s,%s,%.3f,%s,%s,",
            $data{'Output'}, $data{'tdup'}, $data{'absoff'},
            $TStext,         $data{'mode'}
        );

      #$newdab1,
      # 'Name,SKIP,TONE,Repeater Tone,TSQL Frequency,DTCS Code,DTCS Polarity,' ;
      # $tonemode == TONE,Repeater Tone
        my $newdab2 =
          sprintf( "%s,%s,%s%s,,,", $dispname, $Rptskip, $tonemode, $tonesql );

        #$newdab2
        #'DV SQL,DV SQL Code,Your Call Sign,RPT1 Call Sign,RPT2 Call Sign' ;
        my $newdab3 = sprintf( ",,%s,%s,%s", $Urcall, $CallUufld, $CallG );

        #         my $newdab3 = sprintf(",,%s,%s,", $Urcall, $CallUufld);

        #,$newdab3,$newdab4
        #

        #
        my $dirn     = sprintf( "%s", $data{'dirkat'} );
        my $dirs     = '';
        my $distcsyd = sprintf( "%s", $data{'distsyd'} );

        #    my $distcmel = sprintf ("%s",$data{'distmel'});
        #    my $distctmb = sprintf ("%s",$data{'disttmb'});
        #DEBUG print ("$data{'Call U'}-$dirn-$dirs-$distc\n");

        my $prefix = sprintf( "%.3s", $data{'Call U'} );

        #DEBUG print "$cnt,$prefix ";
        #get this working with the array!!!

        my $grpnum    = '';
        my $grpnam    = '';
        my $ougfh     = '';
        my $oumfh     = '';
        my $oubfh     = '';
        my $chnum     = 'UNDEF';
        my $bchnum    = 'UNDEF';
        my $ldispname = $dispname;

        if ( $data{'mode'} eq "DV" ) {
            $grpnum = '3,';
            $grpnam = 'AusDV,';
            $ougfh  = 'g3';
            $oumfh  = 'm0';
            $oubfh  = 'ba';
            $memcntba += 1;
            $bchnum = $memcntba;
            $memcnt0 += 1;
            $chnum     = $memcnt0;
            $dstlab    = 'CQ';
            $ldispname = sprintf( "%s %s", $dispname, $dstlab );
        }
        elsif ( grep { $prefix eq $_ } @g22 ) {
            $grpnum = '22,';
            $grpnam = 'FMAusSE,';
            $ougfh  = 'g22';
        }
        elsif ( grep { $prefix eq $_ } @g23 ) {
            $grpnum = '23,';
            $grpnam = 'FMAusNW,';
            $ougfh  = 'g23';
        }
        elsif ( grep { $prefix eq $_ } @g25 ) {
            $grpnum = '25,';
            $grpnam = 'UHF,';
            $ougfh  = 'g25';
        }
        elsif ( grep { $prefix eq $_ } @g26 ) {
            $grpnum = '26,';
            $grpnam = 'Wicen,';
            $ougfh  = 'g26';
        }
        else {
            $grpnum = '24,';
            $grpnam = 'Simplex,';
            $ougfh  = 'g24';
        }
        if ( $data{'mode'} eq "FM" && ( $data{'distsyd'} ne '' ) ) {
            if ( ( $prefix eq 'VK1' ) || ( $prefix eq 'VK2' ) ) {
                if ( $data{'distsyd'} <= '60000' ) {
                    $oumfh = 'm1';
                    $memcnt1 += 1;
                    $chnum = $memcnt1;
                    $oubfh = 'bb';
                    $memcntbb += 1;
                    $bchnum = $memcntbb;
                }
                else {    # improve later
                    $dirs = $dirn + 157.5;
                    if ( ( $dirs lt 180 ) || ( $dirs gt 360 ) ) {    #west
                        $oubfh = 'be';
                        $memcntbe += 1;
                        $bchnum = $memcntbe;
                    }
                    elsif ( $dirs lt 270 ) {                         #North
                        $oumfh = 'm1';
                        $memcnt1 += 1;
                        $chnum = $memcnt1;
                        $oubfh = 'bd';
                        $memcntbd += 1;
                        $bchnum = $memcntbd;
                    }
                    elsif ( $dirs le 360 ) {                         #South
                        $oubfh = 'bc';
                        $memcntbc += 1;
                        $bchnum = $memcntbc;
                    }
                }
            }
            elsif ( $prefix eq 'VK3' ) {

                if ( $data{'distmel'} <= '80000' ) {
                    $oubfh = 'bg';
                    $memcntbg += 1;
                    $bchnum = $memcntbg;
                    $oumfh  = 'm2';
                    $memcnt2 += 1;
                    $chnum = $memcnt2;
                }
                else {    # improve later
                    $oubfh = 'bh';
                    $memcntbh += 1;
                    $bchnum = $memcntbh;
                }
            }
            elsif ( $prefix eq 'VK4' ) {

                if ( $data{'disttmb'} <= '90000' ) {
                    $oumfh = 'm3';
                    $memcnt3 += 1;
                    $chnum = $memcnt3;
                    $oubfh = 'bi';
                    $memcntbi += 1;
                    $bchnum = $memcntbi;
                }
                else {    # improve later
                    $oubfh = 'bj';
                    $memcntbj += 1;
                    $bchnum = $memcntbj;
                }
            }
            elsif ( ( $prefix eq 'VK5' ) || ( $prefix eq 'VK8' ) ) {
                $oubfh = 'bk';
                $memcntbk += 1;
                $bchnum = $memcntbk;
            }
            elsif ( $prefix eq 'VK6' ) {
                $oubfh = 'bl';
                $memcntbl += 1;
                $bchnum = $memcntbl;
            }
            elsif ( $prefix eq 'VK7' ) {
                $oubfh = 'bm';
                $memcntbm += 1;
                $bchnum = $memcntbm;
            }

        }
        elsif ( $data{'mode'} eq "FM" && $prefix eq 'APR' ) {
            $oumfh = 'm4';
            $memcnt4 += 1;
            $chnum = $memcnt4;
            $oubfh = 'bn';
            $memcntbn += 1;
            $bchnum = $memcntbn;
        }

        elsif ( $data{'mode'} eq "FM" && $data{'0  sortseq'} eq "C" ) {

            #$oumfh = 'm4';
            #$memcnt4 += 1;
            #$chnum = $memcnt4;
            $oubfh = 'bu';
            $memcntbu += 1;
            $bchnum = $memcntbu;
        }
        elsif ( $data{'mode'} eq "FM" && $data{'0  sortseq'} eq "D" ) {

            #$oumfh = 'm4';
            #$memcnt4 += 1;
            #$chnum = $memcnt4;
            $oubfh = 'bw';
            $memcntbw += 1;
            $bchnum = $memcntbw;
        }
        elsif ( $data{'mode'} eq "FM" && $data{'0  sortseq'} eq "E" ) {

            #$oumfh = 'm4';
            #$memcnt4 += 1;
            #$chnum = $memcnt4;
            $oubfh = 'bz';
            $memcntbz += 1;
            $bchnum = $memcntbz;
        }

        elsif ( $data{'mode'} eq "FM" ) {

            #$oumfh = 'm4';
            #$memcnt4 += 1;
            #$chnum = $memcnt4;
            $oubfh = 'bf';
            $memcntbf += 1;
            $bchnum = $memcntbf;
        }

        $utcoffset = '+10:00';
        if ( grep { $prefix eq $_ } @utco10 ) {
            $utcoffset = '+10:00';
        }
        elsif ( grep { $prefix eq $_ } @utco95 ) {
            $utcoffset = '+09:30';
        }
        elsif ( grep { $prefix eq $_ } @utco08 ) {
            $utcoffset = '+08:00';
        }

        # Position,Latitude,Longitude,UTC Offset
        #
        my $newloc = sprintf( "Approximate,%s,%s,",
            $data{'latitude'}, $data{'longditude'} );
        #
        my $newline = sprintf(
            "%s%s%s%s%s%s%s%s",
            $grpnum,  $grpnam,  $newdat1, $newdat2,
            $newdat3, $newdat4, $newloc,  $utcoffset
        );
        #
        if ( $csv->parse($newline) ) {
            print { $handles{$ougfh} } $csv->string, "\n";
        }
        else {
            print STDERR "parse () failed on argument: ", $csv->error_input,
              "\n";
            $csv->error_diag();
        }

        # output to *mem.csv
        if ( $chnum ne 'UNDEF' ) {
            if ( $chnum >= '99' ) {
                print STDERR "chnum already 99 $CallUufld\n ";
            }
            my $newlinb =
              sprintf( "%s,%s%s%s", $chnum, $newdab1, $newdab2, $newdab3 );
            if ( $csv->parse($newlinb) ) {
                print { $handles{$oumfh} } $csv->string, "\n";
            }
            else {
                print STDERR "parse () failed on argument: ",
                  $csv->error_input, "\n";
                $csv->error_diag();
            }
        }
        if ( $bchnum ne 'UNDEF' ) {
            if ( $bchnum >= '99' ) {
                print STDERR "bchnum in $oubfh already 99 $CallUufld\n ";
            }
            my $newlinb =
              sprintf( "%s,%s%s%s", $bchnum, $newdab1, $newdab2, $newdab3 );
            if ( $csv->parse($newlinb) ) {
                print { $handles{$oubfh} } $csv->string, "\n";
            }
            else {
                print STDERR "parse () failed on argument: ",
                  $csv->error_input, "\n";
                $csv->error_diag();
            }
            if (   ( ( $oumfh eq 'm0' ) || ( $oubfh eq 'ba' ) )
                && ( grep { $prefix6 eq $_ } @FavdstrR1 ) )
            {
                my $dstarinfo = '';
                foreach $dstarinfo (@FavdstrUR) {
                    $memcntba += 1;
                    $bchnum = $memcntba;
                    $memcnt0 += 1;
                    $chnum = $memcnt0;

                    #    $cnt += 1;
                    #print $dmrlabtg , "\n" ;
                    my @dstinfo = split( '-', $dstarinfo );
                    my $dstlab  = $dstinfo[0];
                    my $dstUR   = $dstinfo[1];
                    $ldispname = sprintf( "%s %s", $dispname, $dstlab );
                    $Urcall = sprintf( "%8s", $dstUR );

      # 'Name,SKIP,TONE,Repeater Tone,TSQL Frequency,DTCS Code,DTCS Polarity,' ;
      # $tonemode == TONE,Repeater Tone
                    my $newdab2 = sprintf( "%s,%s,%s%s,,,",
                        $ldispname, $Rptskip, $tonemode, $tonesql );

            #$newdab2
            #'DV SQL,DV SQL Code,Your Call Sign,RPT1 Call Sign,RPT2 Call Sign' ;
                    my $newdab3 =
                      sprintf( ",,%s,%s,%s", $Urcall, $CallUufld, $CallG );
                    my $newlinb = sprintf( "%s,%s%s%s",
                        $bchnum, $newdab1, $newdab2, $newdab3 );
                    my $newlinm = sprintf( "%s,%s%s%s",
                        $chnum, $newdab1, $newdab2, $newdab3 );

                    #                      print "debug: $newlinb\n";
                    if ( $csv->parse($newlinb) ) {
                        print { $handles{$oubfh} } $csv->string, "\n";
                    }
                    else {
                        print STDERR "parse () failed on argument: ",
                          $csv->error_input, "\n";
                        $csv->error_diag();
                    }
                    if ( $csv->parse($newlinm) ) {
                        print { $handles{$oumfh} } $csv->string, "\n";
                    }
                    else {
                        print STDERR "parse () failed on argument: ",
                          $csv->error_input, "\n";
                        $csv->error_diag();
                    }
                }
            }
        }
    }
}

# Close the file handles.
close $vkrdfh;
foreach ( values %handles ) {
    close $_;
}

#close $icgfh1;
sub get_write_handles {
    my $folder = $file2pre;
    my @file_names = @_;
    my %file_handles;
    foreach (@file_names) {
        open my $fh, '>', sprintf( '%s%s.csv', $folder, $_ )
          or die "cant open $_: $!";
        $file_handles{$_} = $fh;
    }
    return %file_handles;
}
exit
