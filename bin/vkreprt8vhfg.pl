#!/usr/bin/env perl
#
# Creates a data file(s) for the RT8G
#
#VHF 130-150MHz
#
# This radio uses Zones, Channels and scan lists.
#
# The data is organised into Zones and Scanlists
#
# DMR Channel name comes from callsign + callextn
#
use strict;
use warnings;
no warnings 'experimental::smartmatch';


use Text::CSV_XS;
use List::Util qw(first);
my @longcalluniq;
my @ScanlistUniq;
my @ScanlistDUniq;

my @dmrscanlist;
my @dmrscancnt;
my @LocalmarcTG;
my @dmrtginfo;
our @Favourdm;
our @FavmarcTG;
our @FavdmrpTG;
our @FavdmrpTGcontact;
our @FavsimpTG;
our @FavwicenTG;
our @FavsimpWTG;
our @FavDMRP;
require My::Favourites;
my @fmscanlist = ( 'FAVF2','SYDF2','VK2NF2','VK2SF2','VK2WF2','OTHERF2','WICENF0','WICENF1','MELF2','VK3F2','TMBF2','VK4F2','VK5F2','VK6F2','VK7F2','VK8F2','RFSF2','MVHF0','MVHF1','APRSFM' ) ;
my @fmscancnt = ( 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 );
my $dmscantmp = '';
my $index = '';
my $csv = Text::CSV_XS->new({sep_char => ','});

my @CallUuniq;
my $cnt        = 0;
my $call       = '';
my $cntfld     = '';
my $txcontact;
my $dmrtg;
my $calltxrxscan;


#open vkrepdir.csv
my $file1 = $ARGV[0] or die "Need main CSV file on the command line\n";

# open vkrepdmrxx.csv
my $file2pre = $ARGV[1] or die "Need directory for output e.g.(output/dmr) on the command line\n";

#Open input file
open(my $vkrdfh, '<', $file1) or die "Could not open '$file1' $!\n";

#open output file
my $file2chan = sprintf("%s/rt8vgchan.csv", $file2pre);
my $file2scan = sprintf("%s/rt8vgscan.csv", $file2pre);
my $file2zone = sprintf("%s/rt8vgzone.csv", $file2pre);

open(my $chanfh, '>', $file2chan) or die "Could not open '$file2chan' $!\n";
open(my $scanfh, '>', $file2scan) or die "Could not open '$file2scan' $!\n";
open(my $zonefh, '>', $file2zone) or die "Could not open '$file2zone' $!\n";


my $newhea1 = '0;num;type;callsign;dmrid;qrg;shift;cc;mix;ctcss;net;city;cnty;country;ctry;lat;lon;';
my $newhea2 = 'longcall;callext1;callext2;txcontact1;rxgroup1;txcontact2;rxgroup2;pwr;';
my $newhea3 = 'scanlist1;scanlist2;scanlistfm';;

# print "$newhead,$newhea2,$newhea3\n";
my $newhead = sprintf("%s%s%s", $newhea1, $newhea2, $newhea3);
#
if ($csv->parse($newhead)) {
    print $chanfh $csv->string, "\n";
}
else {
    print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
    $csv->error_diag();
}

#BM (Brandmeister)	&
#DMR-DL	(none)
#DMR-plus	#
#Hytera	H
#IPSC2	*
#Marc	M
#Mixed-Mode FM*)	%FM
# Build DV Tables (DMRplus brandmeister)
my @dvlistdpcall;
my @dvlistdpnumb;
my @dvlistdpnet;
my @dvlistdpregn;

foreach my $tmpDV (@FavDMRP) {
    my @tmpDVinfo = split('-',$tmpDV);
    my $dmrDVnumb = $tmpDVinfo[0];
    my $dmrDVcall = $tmpDVinfo[1];
    my $dmrDVnet  = $tmpDVinfo[2];
    my $dmrDVregn = $tmpDVinfo[3];
      push @dvlistdpnumb, $dmrDVnumb ;
      push @dvlistdpcall, $dmrDVcall ;
      push @dvlistdpnet, $dmrDVnet ;
      push @dvlistdpregn, $dmrDVregn ;
}

#foreach my $prnDV (@dvlistdpcall) {
#   print STDERR "DEBUG: print Calls ", $prnDV, "\n";
# }

# Build talkgroup tables so that we can split names and numbers for later use

my @Favamateur ;

#my @bothTGlist = ( '1-9-LOCAL-9',@FavdmrpTG, @FavmarcTG,@FavsimpTG);
my @bothTGlist = ( '1-9-LOCAL-9',@FavmarcTG,@FavdmrpTG,@FavdmrpTGcontact,@FavsimpTG);

my @tgnumuniq;
my @tgnamuniq;
foreach my $tmpTG (@bothTGlist) {
  my @tmpTGinfo = split('-',$tmpTG);
  my $dmrlab = $tmpTGinfo[1];
  $dmrtg = $tmpTGinfo[2];
  my $dmrtgnum = $tmpTGinfo[3];
	my $dmrtgtext = sprintf('%s %s',$dmrlab,$dmrtg);
  if (grep { $dmrtgnum eq $_ } @tgnumuniq ) {
    print "\nTG contact exists :",$dmrtgnum,":",$dmrtgtext,": not adding\n\n";
  } else {
    push @tgnumuniq, $dmrtgnum ;
    push @tgnamuniq, $dmrtgtext;
  }
}
#foreach my $prnTG (@tgnumuniq) {
#   print STDERR "DEBUG: print Talk Groups ", $prnTG, "\n";
#}
#  build a table of the talkgroups WICEN
my @wtgnumuniq;
my @wtgnamuniq;
foreach my $wtmpTG (@FavwicenTG) {
  my @wtmpTGinfo = split('-',$wtmpTG);
  my $wdmrlab = $wtmpTGinfo[1];
  my $wdmrtg = $wtmpTGinfo[2];
  my $wdmrtgnum = $wtmpTGinfo[3];
  my $wdmrtgtext = sprintf('%s %s',$wdmrlab,$wdmrtg);
  if (grep { $wdmrtgnum eq $_ } @wtgnumuniq ) {
    print "\nWTG contact exists :",$wdmrtgnum,":",$wdmrtgtext,": not adding\n\n";
  } else {
    push @wtgnumuniq, $wdmrtgnum ;
    push @wtgnamuniq, $wdmrtgtext;
  }
}
#
#
#read the header line of the main input
my @fields = @{$csv->getline($vkrdfh)};

my @rows;
while (my $row = $csv->getline($vkrdfh)) {
  my %datard;
  @datard{@fields} = @$row;    # This is a hash slice
  push @rows, \%datard;

# This radio can handle DV-DMR and FM on 2m
  if (   ($datard{'mode'} ~~ ["DV", "FM"])
#   if (   ($datard{'mode'} ~~ ["DV"])
    && ($datard{'band'} ~~ ["2", "DMR"])
    && (($datard{'Input'} < '170.0') && ($datard{'Input'} > '120.0'))
    && (($datard{'Output'} < '170.0') && ($datard{'Output'} > '120.0')))
    {
      $cnt += 1;
#DEBUG      print "Station: $datard{'Call U'}, Output: $datard{Output}\n";
#
#2;num;type;callsign;dmrid;qrg;shift;

# type is a or d
# dmrid is 000
#Channel Number,Receive Frequency,Transmit Frequency
      my $prefix6  = sprintf("%.6s", $datard{'Call U'});
      my $prefix3  = sprintf("%.3s", $datard{'Call U'});
      my $suffix4  = substr $prefix6, -4 ;
      my $suffix2  = substr $prefix6, -2 ;
      my $dmtype =  'a' ;
      my $dmccode = '' ;
      my $dmmix   = '' ;
      my $dmrlabtg;
      my $dmrtgnum;
      my $tonefld = '';
      my $dmrlab = '';
      $dmrtg = '';
      my $pcallext = '';
      my $lenlongcall = '';
      my $lenpcallext = '';
      my $templen = '';
      my $newdata = '';
      my $newdat1 = '';
      my $newdat2 = '';
      my $newdat3 = '';
      my $newdat4 = '';

      my $CallUufld = sprintf("%s", $datard{'Call U'});
      if (grep { $CallUufld eq $_ } @CallUuniq) {

#        print " DEBUG $CallUufld not unique\n";
        my $cuniq = '64';
        while (grep { $CallUufld eq $_ } @CallUuniq) {
          $cuniq += 1;
          my $ccuniq = chr($cuniq);
          my $tCallUufld = substr $CallUufld, 6, 1, $ccuniq;
        }
#            print "DEBUG Inserting $CallUufld\n";
        push @CallUuniq, $CallUufld;
      }
      else {
        push @CallUuniq, $CallUufld;
      }


#longcall; callext1;callext2;txcontact1;rxgroup1;txcontact2;rxgroup2;pwr;


#        my $prefix6  = sprintf("%.6s", $datard{'Call U'});
#        my $suffix4  = substr $prefix6, 2, 4 ;
#longcall;callext1;callext2;txcontact1;rxgroup1;txcontact2;rxgroup2;pwr;

#
# for FM longcall for DMR 2 fields
#
#        my $newdat3 = sprintf(",,%s,,,,,,", $datard{'txpower'});
      my $dmrDVnet = '';
      my $dmrDVregn = '';
      my $dvreptg = '';
      my $longcall = sprintf("%s %s %s", $CallUufld, $datard{'mNemonic'},$datard{'Location'});
      my $rxgroup = '';
      my $pwr = 'H';
      $calltxrxscan = sprintf(';;;;;;%s;;;',$pwr);
#print STDERR "DEBUG mode ", $datard{'mode'}, "tone ", $datard{'Tone'},"\n";
      if ( $datard{'mode'} eq "FM" ) {
        $tonefld = ( $datard{'Tone'} eq '-') ? '' : $datard{'Tone'};
        $dmccode = ( $tonefld eq '') ? '' : 'c' ;
      }
      if ( $datard{'mode'} eq "DV" ) {
          # check if we have identified if the net is dmrplus or brandmeister
        my ( $dvindex ) = grep { $dvlistdpcall[$_] eq $datard{'Call'}  } 0..$#dvlistdpcall ;
        if ($dvindex) {
          $dmrDVnet = sprintf('%s',$dvlistdpnet[$dvindex]);
          $dmrDVregn = sprintf('%s',$dvlistdpregn[$dvindex]);
#print STDERR "DEBUG: found repeater list Call:", $datard{'Call'}, " Mast: ", $dmrDVnet, " Reg: ", $dmrDVregn, "\n";
        }

        $dmtype =  'd';
        $dmrlabtg = ( $datard{'Tone'} eq '-' ) ? '1-9-LOCAL-9' : $datard{'Tone'};
#print "DEBUG dmrlabtg :", $dmrlabtg, " ",$dmtype, " ",$CallUufld," ", $datard{'Call'},"\n";
        $tonefld = '';
  #      @dmrtginfo = split('-',$dmrlabtg);
        $dmccode = '1' ;

        my ($dmmix, $longcall, $calltxrxscan, $CallUufld) = dvtxrx($dmrlabtg,$CallUufld);
#print "DEBUG returned dmmix:",$dmmix,":tx:",$calltxrxscan,":Call:",$CallUufld,":\n";
 $newdat1 = sprintf("%s;%s;%s;%s;", $dmccode, $dmmix, $tonefld, $dmrDVnet);
#2ROTFM   ;         ;        ;          ;        ;          ;        ;High;;;VK2RCG
#2RCG Tech TG100;Tech TG100; ;None      ;None    ;          ;        ;High;#
 $newdata =
    sprintf("%s;%s;000;%s;%s;", $dmtype,$CallUufld,$datard{'Output'},$datard{'Offset'});

#print "DEBUG newdat1:", $newdat1, " ", $newdata, "\n";
 $newdat3 = sprintf("%.16s;%s", $longcall, $calltxrxscan);
#print "DEBUG newdat3:",$newdat3,"\n";

      } else {
         $newdat1 = sprintf("%s;%s;%s;%s;", $dmccode, $dmmix, $tonefld, $dmrDVnet);
  #2ROTFM   ;         ;        ;          ;        ;          ;        ;High;;;VK2RCG
  #2RCG Tech TG100;Tech TG100; ;None      ;None    ;          ;        ;High;#
         $newdata =
            sprintf("%s;%s;000;%s;%s;", $dmtype,$CallUufld,$datard{'Output'},$datard{'Offset'});

#        print "DEBUG newdat1:", $newdat1, " ", $newdata, "\n";
         $newdat3 = sprintf("%.16s;%s", $longcall, $calltxrxscan);
#        print "DEBUG newdat3:",$newdat3,"\n";

      }#end first DV


      my $dirn   = sprintf("%s", $datard{'dirkat'});
      my $dirs = '';
      my $distcsyd = sprintf("%s", $datard{'distsyd'});
#
      my $scanlistfm = '';
####
      if ($datard{'mode'} eq "FM" && ($datard{'distsyd'} ne '')) {
        if (($prefix3 eq 'VK1') || ($prefix3 eq 'VK2')) {
          if ($datard{'distsyd'} <= '55000') {
            $scanlistfm = 'SYDF2';
          } else { # improve later
            $dirs = $dirn + 157.5;
            if (($dirs lt 180) || ($dirs gt 360)) { #west
              $scanlistfm = 'VK2WF2';
            } elsif ($dirs lt 270) {    #North
              $scanlistfm = 'VK2NF2';
            } elsif ($dirs le 360) {    #South
              $scanlistfm = 'VK2SF2';
            }
          }
        } elsif ($prefix3 eq 'VK3') {
          if ($datard{'distmel'} <= '80000') {
            $scanlistfm = 'MELF2';
          } else { # improve later
            $scanlistfm = 'VK3F2';
          }
        } elsif ($prefix3 eq 'VK4')  {
          if ($datard{'disttmb'} <= '80000') {
            $scanlistfm = 'TMBF2';
          } else { # improve later
            $scanlistfm = 'VK4F2';
          }
        } elsif ($prefix3 eq 'VK5') {
          $scanlistfm = 'VK5F2';
        } elsif ($prefix3 eq 'VK6') {
          $scanlistfm = 'VK6F2' ;
        } elsif ($prefix3 eq 'VK7') {
          $scanlistfm = 'VK7F2';
        } elsif ($prefix3 eq 'VK8') {
          $scanlistfm = 'VK8F2';
        }
      } elsif (($datard{'mode'} eq "FM") && (($prefix3 eq 'WIC') || ($prefix3 eq 'VRA'))) {
        $scanlistfm = 'WICENF0';
      } elsif (($datard{'mode'} eq "FM") && ($prefix3 eq 'ESO')) {
        $scanlistfm = 'ESOF2';
      } elsif (($datard{'mode'} eq "FM") && ($prefix3 eq 'RFS')) {
        $scanlistfm = 'RFSF2';
      } elsif (($datard{'mode'} eq "FM") && ($prefix3 eq 'MVH')) {
        $scanlistfm = 'MVHF0';
      } elsif (($datard{'mode'} eq "FM") && ($prefix3 eq 'APR')) {
        $scanlistfm = 'APRSFM';
      } elsif ($datard{'mode'} eq "FM" ) {
        $scanlistfm = 'OTHERF2';
      }
      my $newfmscan;
      my $newfmscancnt;
      if ($datard{'mode'} eq "FM" ) {

        if (fmscanbuild($scanlistfm, $CallUufld) ) {
        #  print "loaded\n";
        } else {
          if ($scanlistfm eq 'MVHF0'){
            $scanlistfm = 'MVHF1';
            if (fmscanbuild($scanlistfm, $CallUufld) ) {
#              print "loaded MVHF1\n"
            } else { print "still not loaded MVHF1\n"}
          } elsif ($scanlistfm eq 'WICENF0'){
            $scanlistfm = 'WICENF1';
            if (fmscanbuild($scanlistfm, $CallUufld) ) {
#              print "loaded WICENF1\n"
            } else { print "still not loaded WICENF1\n"}
          }
          else { print "not loaded  $scanlistfm $CallUufld \n"}
        }
      }
      my $newloc = sprintf("%s;%s;", $datard{'latitude'},$datard{'longditude'});

#net;city;cnty;country;ctry;lat;lon;';
# add fandling of lat lon later
      $newdat2 =  sprintf(";;;;%s",$newloc);

#longcall;callext1;callext2;txcontact1;rxgroup1;txcontact2;rxgroup2;pwr;

      if (($datard{'mode'} eq "FM" ) && (grep { $datard{'Call'} eq $_ } @Favourdm)) {
        $scanlistfm = 'FAVF2';
        if (fmscanbuild($scanlistfm, $CallUufld) ) {
#          print "loaded\n";
        } else {
          print "not loaded FAVF2\n";
        }
      }
      if (! grep { $scanlistfm eq $_ } @ScanlistUniq) {
        push @ScanlistUniq, $scanlistfm;
      }

        $newdat4 = $scanlistfm;

#
        my $newline = sprintf("2;%s;%s%s%s%s%s",
            $cnt, $newdata, $newdat1, $newdat2, $newdat3, $newdat4);
#
#
        if ($csv->parse($newline)) {
          print $chanfh $csv->string, "\n";
        } else {
          print STDERR "parse () failed on argument: ", $csv->error_input,
              "\n";
          $csv->error_diag();
        }
# First record should now be written
#
#This section creates additional DMR channels
        if ($datard{'mode'} eq "DV") {
          if (($datard{'tsign'} ne "SIMPLEX")
            &&  ($datard{'Call'}  ne "WICENS" )) {

#print STDERR "DEBUG: searching repeater list ", $datard{'Call'}, " \n";

        # insert multiple if it is a repeater
            if ( $dmrDVnet eq 'IPSC2' ) {
              my $dvreptg = sprintf('2-380%s-%s-380%s', $dmrDVregn,$dmrDVregn,$dmrDVregn);
#print STDERR "DEBUG: creating TG dvreptg ", $dvreptg, " \n";

              @Favamateur = (@FavdmrpTG, $dvreptg, @FavmarcTG );
            } elsif ( $dmrDVnet eq 'BM' ) {
              @Favamateur = @FavmarcTG;
            } else {
              @Favamateur = @FavmarcTG;
            }
            foreach $dmrlabtg (@Favamateur) {
            $cnt += 1;
           #print $dmrlabtg , "\n" ;
            $dmtype = 'd';
            my ($dmmix,$longcall,$calltxrxscan, $CallUufld) = dvtxrx($dmrlabtg,$CallUufld);

            my $newdat1 = sprintf("%s;%s;%s;%s;",$dmccode, $dmmix, $tonefld, $dmrDVnet);

            $newdata =
          sprintf("%s;%s;000;%s;%s;", $dmtype,$CallUufld,$datard{'Output'},$datard{'Offset'});

            $newdat3 = sprintf("%.16s;%s", $longcall, $calltxrxscan);
#print STDERR "newdat3-end:",$newdat3,":\n";
#;scanlistfm
            $newdat4 = $scanlistfm;

            $newline = sprintf("2;%s;%s%s%s%s%s",
            $cnt,$newdata, $newdat1, $newdat2, $newdat3, $newdat4);
            if ($csv->parse($newline)) {
              print $chanfh $csv->string, "\n";
            } else {
              print STDERR "parse () failed on argument: ", $csv->error_input,"\n";
              $csv->error_diag();
            }
          } #End tglist
        } # End not simplex or wicen
      } # end DV
    } #end freq range
  } #get line


# FM Scanlist
my $newfmscancnt;
my $tmpindex = 0 ;
foreach $newfmscancnt (@fmscancnt) {

    while ($newfmscancnt < 31) {
        my $addsemicolon = sprintf('%s;',$fmscanlist[$tmpindex]);
 #       print "adding $addsemicolon \n to $newfmscancnt\n";
        splice(@fmscanlist,$tmpindex,1,$addsemicolon);
        $newfmscancnt +=1;
    }
    $tmpindex += 1;
}
#
# find and hold the DMR simplex for the DMR zones.
my ( $dsindex )= grep { $dmrscanlist[$_] =~ 'VKSMPLDM2SL' } 0..$#dmrscanlist;
my $holddmrsmplind = $dsindex ;
my $holddmrsmplcnt = $dmrscancnt[$holddmrsmplind];
my @holddmrsmplscan = split(';',$dmrscanlist[$holddmrsmplind]);

# DMR Scanlist
my $newdmrscancnt;
$tmpindex = 0 ;
foreach $newdmrscancnt (@dmrscancnt) {
    my @tmpdmrsl = split(';',$dmrscanlist[$tmpindex]);
    if ($tmpdmrsl[0] ne 'VKSMPLDM2SL'){

       my $extracnt = 31 - $holddmrsmplcnt + 1 ;
#        print "DEBUG: A zonesuffix ",$extracnt," zone0 ",$zoneline, "\n";

       if ( $newdmrscancnt < $extracnt )  {
#        print "DEBUG: inside vksmpl ";
        my $vksimplind = 0;
        while ($vksimplind < $holddmrsmplcnt){
            my $getscanlist = $dmrscanlist[$tmpindex] ;
            $vksimplind += 1;
            my $newscanlistx = sprintf('%s;%s',$getscanlist,$holddmrsmplscan[$vksimplind]);
            splice (@dmrscanlist, $tmpindex,1,$newscanlistx);
            $newdmrscancnt += 1;
        }
      }
    }


    while ($newdmrscancnt < 31) {
        my $addsemicolon = sprintf('%s;',$dmrscanlist[$tmpindex]);
 #       print "adding $addsemicolon \n to $newfmscancnt\n";
        splice(@dmrscanlist,$tmpindex,1,$addsemicolon);
        $newdmrscancnt +=1;
    }
    $tmpindex += 1;
}

#Now we have written channels and scanlist - construct zones

$tmpindex = 0;
my $tmpcnt = $tmpindex ;
my $tmpuniq = 0 ;
my $scanent;
my $tmpfmx;
my $zonename;
my $zoneline;
my @zonelist ;

my @bothlist = (@dmrscanlist,@fmscanlist) ;
foreach $scanent (@bothlist){
#    print "scanent $scanent\n" ;
    my @tmpfment = split(';',$scanent);
    foreach $tmpfmx (@tmpfment) {
#        print "tmpfmx $tmpfmx C $tmpcnt I $tmpindex \n" ;
        if ($tmpcnt < 17 ) {
            if ( $tmpcnt == 0 ) {
                if ( $tmpindex == 0 ) {
                    $zonename = sprintf('%.9s',$tmpfmx) ;
                    $zoneline = sprintf('%s',$zonename);
                    $tmpcnt += 1;
                }
            } else {
                $zoneline = sprintf('%s;%s',$zoneline,$tmpfmx);
                $tmpcnt += 1 ;
            }
        } else {
            push @zonelist,$zoneline;
            $zoneline = sprintf('%s%s',$zonename,$tmpuniq);
            $zoneline = sprintf('%s;%s',$zoneline,$tmpfmx);
            $tmpcnt = 2;
            $tmpuniq += 1;
        }
        $tmpindex += 1;
    }

    while ($tmpcnt < 17) {
        $zoneline = sprintf('%s;',$zoneline);
        $tmpcnt += 1;
    }
    $tmpcnt = 0;
    $tmpindex = 0;
    $tmpuniq = 0;
    push @zonelist,$zoneline;
}


#output the files
#Generate the headers
#my $scanheader = 'ScanList;Ch1;Ch2;Ch3;Ch4;Ch5;Ch6;Ch7;Ch8;Ch9;Ch10;Ch11;Ch12;Ch13;Ch14;Ch15;Ch16;Ch17;Ch18;Ch19;Ch20;Ch21;Ch22;Ch23;Ch24;Ch25;Ch26;Ch27;Ch28;Ch29;Ch30;Ch31';
#my $zoneheader = 'ZoneList;Ch1;Ch2;Ch3;Ch4;Ch5;Ch6;Ch7;Ch8;Ch9;Ch10;Ch11;Ch12;Ch13;Ch14;Ch15;Ch16';



$tmpcnt = 1;
my $scanheader = 'ScanList';
my $zoneheader = 'ZoneList';
while ($tmpcnt < 32 ){
  $scanheader = sprintf('%s;Ch%i',$scanheader,$tmpcnt);
  if ($tmpcnt < 17) {
    $zoneheader = sprintf('%s;Ch%i',$zoneheader,$tmpcnt);
  }
  $tmpcnt += 1;
}
       print "DEBUG: scanheader ",$scanheader, "\n";
       print "DEBUG: zoneheader ",$zoneheader, "\n";

print $zonefh $zoneheader,"\n";

foreach $zoneline (@zonelist) {
    print $zonefh $zoneline,"\n";
}


print $scanfh $scanheader,"\n";
foreach $scanent (@bothlist) {
    print $scanfh $scanent,"\n";
}

# Close the file handles.
close $zonefh;
close $scanfh;
close $chanfh;
close $vkrdfh;

sub fmscanbuild {
        my $scanlistfm = shift;
        my $CallUufld = shift;
        my ( $index )= grep { $fmscanlist[$_] =~ /^$scanlistfm/ } 0..$#fmscanlist;
        my $newfmscan = sprintf('%s;%s',$fmscanlist[$index],$CallUufld);
        my $newfmscancnt = $fmscancnt[$index] +1 ;
        if ($newfmscancnt > 31) {
            # print "too many entries for A $scanlistfm $CallUufld\n";
            return 0;
          } else {
            splice(@fmscancnt,$index,1,$newfmscancnt);
            splice(@fmscanlist,$index,1,$newfmscan);
            return 1;
          }
        }

sub dvtxrx {        # Restructure for 8 digit view Most significant at front

                my $dmrlabtg = shift;
                my $CallUufld = shift;

                my $callext1;
                my $callext2;
                my $txcontact1;
                my $txcontact2;
                my $rxgroup1;
                my $rxgroup2;
                my $scanlist1;
                my $scanlist2;

                my $prefix6  = sprintf("%.6s", $CallUufld);
                my $prefix3  = sprintf("%.3s", $prefix6);
                my $suffix4  = substr $prefix6, -4 ;
                my $suffix2  = substr $prefix6, -2 ;
                my $pwr = 'H';
                my $txcontact = '';
#print "DEBUG before p6 :", $prefix6,":p3:",$prefix3,":s4:",$suffix4,":s2:",$suffix2,":\n";


                my @dmrtginfo = split('-',$dmrlabtg);
                my $dmmix = ( $dmrtginfo[0] eq 'm' ) ? 'm'  : sprintf('s%s',$dmrtginfo[0]);
                my $dmrlab = $dmrtginfo[1];
                my $dmrtg = $dmrtginfo[2];
                my $dmrtgnum = $dmrtginfo[3];

print "DEBUG dmrlabtg:", $dmrlabtg,":mix:",$dmmix,":\n";
                my $rxgroup = 'RXGR1';
# rewrite CallUufld
                $CallUufld = $dmrtgnum;


                # rewrite pcallext here then fix longcall code later
                my $pcallext = sprintf('%s%s%s',(substr $dmmix,-1),$suffix2,$prefix3);
                my $scanlistdm = sprintf('%sDMRSL',$prefix6);
                if ( $prefix3  ~~ ["DMU",  "WIC", "KUR"]) {
                  my ( $tgindex )= grep { $wtgnumuniq[$_] =~ /^$dmrtgnum/ } 0..$#wtgnumuniq;
                  $txcontact = sprintf('%s',$wtgnamuniq[$tgindex]);
#                  print "DEBUG index WI :",$index,":numuniq:",$wtgnumuniq[$tgindex],":nam:",$wtgnamuniq[$tgindex],":\n";
                } else {
                  my ( $tgindex ) = grep { $tgnumuniq[$_] =~ /^$dmrtgnum/ } 0..$#tgnumuniq;
                  $txcontact = sprintf('%s',$tgnamuniq[$tgindex]);
                  #print "DEBUG index DM :",$tgindex,":numuniq:",$tgnumuniq[$tgindex],":nam:",$tgnamuniq[$tgindex],":\n";
                }

                my $longcall = sprintf('%s %s',$CallUufld,$pcallext);


#        print "DEBUG before test :", $longcall,":\n";
                my $lenlongcall = length($longcall);
                my $lenpcallext = length($pcallext);
                if ( $lenlongcall > 16 ) {
        print "\nDEBUG too long :",$longcall,":", $pcallext,":\n";
                  my $templen = $lenlongcall - 15 ;
                  $pcallext = substr $pcallext,0, ($lenpcallext - $templen);
        print "DEBUG now :", $suffix4,":\n";
                }

        # longcall must be unique
                if (grep { $longcall eq $_ } @longcalluniq ) {
                  print "\nChannel Name Exists :",$longcall,": not adding\n\n";
                } else {
#                  print "adding Channel :",$longcall,": added\n";
                  push @longcalluniq, $longcall ;
                }

                if (! grep { $scanlistdm eq $_ } @ScanlistDUniq) {
                  push @ScanlistDUniq, $scanlistdm;
                  push @dmrscanlist, $scanlistdm;
                  push @dmrscancnt, '0';
                }
                my ( $index )= grep { $dmrscanlist[$_] =~ /^$scanlistdm/ } 0..$#dmrscanlist;
                my $newdmrscan = sprintf('%s;%s',$dmrscanlist[$index],$longcall);
                my $newdmrscancnt = $dmrscancnt[$index] +1 ;
          #       print "DEBUG newdmr ", $newdmrscan," :", $newdmrscancnt,"\n";
                if ($newdmrscancnt > 31) {
                  print "too many entries for C $scanlistdm \n";
                } else {
                  splice(@dmrscancnt,$index,1,$newdmrscancnt);
                  splice(@dmrscanlist,$index,1,$newdmrscan);
                }


        if ($dmmix eq 's1') {
          $callext1 = $pcallext;
          $callext2 = '';
          $txcontact1 = $txcontact;
          $txcontact2 = '';
          $rxgroup1 = $rxgroup;
          $rxgroup2 = '';
          $scanlist1 = $scanlistdm;# DMR Channel name comes from callsign + callextn
          #
          $scanlist2 = '';
        } elsif ($dmmix eq 's2') {
          $callext1 = '';
          $callext2 = $pcallext;
          $txcontact1 = '';
          $txcontact2 = $txcontact;
          $rxgroup1 = '';
          $rxgroup2 = $rxgroup;
          $scanlist1 = '';
          $scanlist2 = $scanlistdm;
        } elsif ($dmmix eq '') {
          $callext1 = $pcallext;
          $callext2 = $pcallext;
          $txcontact1 = $txcontact;
          $txcontact2 = $txcontact;
          $rxgroup1 = $rxgroup;
          $rxgroup2 = $rxgroup;
          $scanlist1 = $scanlistdm;
          $scanlist2 = $scanlistdm;
        }elsif ($dmmix eq 'm') {
          $callext1 = $pcallext;
          $callext2 = $pcallext;
          $txcontact1 = $txcontact;
          $txcontact2 = $txcontact;
          $rxgroup1 = $rxgroup;
          $rxgroup2 = $rxgroup;
          $scanlist1 = $scanlistdm;
          $scanlist2 = $scanlistdm;
        }
#        my $callext = sprintf('%s;%s;',$callext1,$callext2);
        my $calltxrxscan = sprintf('%s;%s;%s;%s;%s;%s;%s;%s;%s;',
           $callext1,$callext2,$txcontact1,$rxgroup1,$txcontact2,$rxgroup2,$pwr,$scanlist1,$scanlist2);
return ($dmmix,$longcall,$calltxrxscan,$CallUufld);
}
exit
