#!/usr/bin/env perl
#
# Creates a data file(s) for the MD-380
#
# This radio uses Zones, Channels and scan lists.
#
# The data is organised into Zones and Scanlists
#
use strict;
use warnings;
no warnings 'experimental::smartmatch';


use Text::CSV_XS;
use List::Util qw(first);

my @ScanlistUniq;
my @ScanlistDUniq;

my @dmrscanlist;
my @dmrscancnt;
my @LocalmarcTG;
my @dmrtginfo;
our @Favourdm;
our @FavmarcTG;
our @FavsimpTG;
require My::Favourites;
my @fmscanlist = ( 'FAVFM','SYDFM','VK2NFM','VK2SFM','VK2WFM','OTHERFM','MELFM','VK3FM','TMBFM','VK4FM','VK5FM','VK6FM','VK7FM','VK8FM' ) ;
my @fmscancnt = ( 0,0,0,0,0,0,0,0,0,0,0,0,0,0 );
my $dmscantmp = '';
my $index = '';
my $csv = Text::CSV_XS->new({sep_char => ','});

my @CallUuniq;
my $cnt        = 0;
my $call       = '';
my $cntfld     = '';
my $txcontact;


#open vkrepdir.csv
my $file1 = $ARGV[0] or die "Need main CSV file on the command line\n";

# open vkrepdmrxx.csv
my $file2pre = $ARGV[1] or die "Need directory for output e.g.(output/dmr) on the command line\n";

#Open input file
open(my $vkrdfh, '<', $file1) or die "Could not open '$file1' $!\n";

#open output file
my $file2chan = sprintf("%s/chan.csv", $file2pre);
my $file2scan = sprintf("%s/scan.csv", $file2pre);
my $file2zone = sprintf("%s/zone.csv", $file2pre);
open(my $chanfh, '>', $file2chan) or die "Could not open '$file2chan' $!\n";
open(my $scanfh, '>', $file2scan) or die "Could not open '$file2scan' $!\n";
open(my $zonefh, '>', $file2zone) or die "Could not open '$file2zone' $!\n";


#
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

#  build a table of the talkgroups
my @bothTGlist = ( '1-LOCAL-TG9-9',@FavmarcTG,@FavsimpTG);
my @tgnumuniq;
my @tgnamuniq;
foreach my $tmpTG (@bothTGlist) {
    my @tmpTGinfo = split('-',$tmpTG);
    my $dmrlab = $tmpTGinfo[1];
    my $dmrtg = $tmpTGinfo[2];
    my $dmrtgnum = $tmpTGinfo[3];
	my $dmrtgtext = sprintf('%s %s',$dmrlab,$dmrtg);
    if (grep { $dmrtgnum eq $_ } @tgnumuniq ) {
        print "\nTG contact exists :",$dmrtgnum,":",$dmrtgtext,": not adding\n\n";
    } else {
        push @tgnumuniq, $dmrtgnum ;
        push @tgnamuniq, $dmrtgtext;
    }
}
#
#
#read the header line of the main input
my @fields = @{$csv->getline($vkrdfh)};



my @rows;
while (my $row = $csv->getline($vkrdfh)) {
    my %data;
    @data{@fields} = @$row;    # This is a hash slice

    push @rows, \%data;

# This radio can handle DV-C4FM and FM on 2 and 70
    if (   ($data{'mode'} ~~ ["DV", "FM"])
        && ($data{'band'} ~~ ["7", "DMR"]))
    {
        $cnt += 1;
 #       if ($cnt > 30) { exit };
#DEBUG      print "Station: $data{'Call U'}, Output: $data{Output}\n";
#
#2;num;type;callsign;dmrid;qrg;shift;

# type is a or d
# dmrid is 000
#Channel Number,Receive Frequency,Transmit Frequency
        my $prefix6  = sprintf("%.6s", $data{'Call U'});
        my $prefix3  = sprintf("%.3s", $data{'Call U'});
        my $suffix4  = substr $prefix6, -4 ;
        my $dmtype =  'a' ;
        my $dmccode = '' ;
        my $dmmix   = '' ;
        my $dmrlabtg;
        my $dmrtgnum;
        my $tonefld = '';
        my $dmrlab = '';
        my $dmrtg = '';
        my $pcallext = '';
        my $lenlongcall = '';
        my $lenpcallext = '';
        my $templen = '';
        
        my $CallUufld = sprintf("%s", $data{'Call U'});
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


#        my $prefix6  = sprintf("%.6s", $data{'Call U'});
#        my $suffix4  = substr $prefix6, 2, 4 ;
#longcall;callext1;callext2;txcontact1;rxgroup1;txcontact2;rxgroup2;pwr;

#
# for FM longcall for DMR 2 fields
#
#        my $newdat3 = sprintf(",,%s,,,,,,", $data{'txpower'});
        my $longcall = sprintf("%s %s %s", $CallUufld, $data{'mNemonic'},$data{'Location'});
        my $callext1 = '' ;
        my $callext2 = '' ;
        my $txcontact1 = '';
        my $rxgroup1 = 'None';
        my $txcontact2 = '';
        my $rxgroup2 = 'None';
        my $pwr = 'H';
        my $callext = sprintf('%s;%s;',$callext1,$callext2);
        my $txrx = sprintf('%s;%s;%s;%s;',$txcontact1,$rxgroup1,$txcontact2,$rxgroup2);
#print "DEBUG mode ", $data{'mode'}, "tone ", $data{'Tone'},"\n";
        if ( $data{'mode'} eq "FM" ) {         
            $tonefld = ( $data{'Tone'} eq '-') ? '' : $data{'Tone'};
            $dmccode = ( $tonefld eq '') ? '' : 'c' ;
        }
        if ( $data{'mode'} eq "DV" ) {
            $dmtype =  'd';
            $dmrlabtg = ( $data{'Tone'} eq '-' ) ? '1-LOCAL-TG9-9' : $data{'Tone'};
#            print "DEBUG dmrlabtg :", $dmrlabtg, " ",$dmtype, "\n";
            $tonefld = '';
            @dmrtginfo = split('-',$dmrlabtg);
            $dmccode = '1' ;
            $dmmix = sprintf('s%s',$dmrtginfo[0]);
            $dmrlab = $dmrtginfo[1];
            $dmrtg = $dmrtginfo[2];
            $dmrtgnum = $dmrtginfo[3];
            $CallUufld = $dmrlab;
            $pcallext = sprintf('%s %s',$dmrtg,$suffix4);
#            print "DEBUG before test :", $pcallext,":\n";
            my $indextest = index $dmrtg,$dmrtgnum ;
            if ( $indextest > 0 ) {
                $longcall = sprintf('%s %s',$dmrlab, $pcallext);
#                print "DEBUG:",$dmrtgnum,";",$dmrtg,":",$longcall,":\n";
            } else {            
                $pcallext = sprintf('%s',$dmrtg);
                $longcall = sprintf('%s %s',$dmrlab, $pcallext);
#                print "DEBUGX:",$dmrtgnum,";",$dmrtg,":",$longcall,":\n";
            }
#            print "DEBUG after test :",$longcall,":", $pcallext,":\n";
            $lenlongcall = length($longcall);
#   this should always be 4 .... but just in case!
            $lenpcallext = length($pcallext);
            if ( $lenlongcall > 16 ) { 
#                print "DEBUG too long :",$longcall,":", $psuffix4,":\n";
                $templen = $lenlongcall - 15 ;
                $pcallext = substr $pcallext,0, ($lenpcallext - $templen);
#                print "DEBUG now :", $psuffix4,":\n";
            }
            $callext1 = $pcallext;
            my ( $index )= grep { $tgnumuniq[$_] =~ /^$dmrtgnum/ } 0..$#tgnumuniq;
            $txcontact = sprintf('%s',$tgnamuniq[$index]);
#            print "DEBUG index :",$index,":numuniq:",$tgnumuniq[$index],":nam:",$tgnamuniq[$index],":\n";
            $txcontact1 = $txcontact;
            
            
            if ($dmmix eq 's2' ) {
                $callext1 = '';
                $callext2 = $pcallext;
                $txcontact1 = '';
                $txcontact2 = $txcontact;
            }
    
            $callext = sprintf('%s;%s;',$callext1,$callext2);
            $txrx = sprintf('%s;%s;%s;%s;',$txcontact1,$rxgroup1,$txcontact2,$rxgroup2);
        }
    

        my $newdat1 = sprintf("%s;%s;%s;", $dmccode, $dmmix, $tonefld);
#2ROTFM   ;         ;        ;          ;        ;          ;        ;High;;;VK2RCG
#2RCG Tech TG100;Tech TG100; ;None      ;None    ;          ;        ;High;#
        my $newdata =
          sprintf("%s;%s;000;%s;%s;", $dmtype,$CallUufld,$data{'Output'},$data{'Offset'});

#        print "DEBUG ", $newdat1, " ", $newdata, "\n";

        my $dirn   = sprintf("%s", $data{'dirkat'});
        my $dirs = '';
        my $distcsyd = sprintf("%s", $data{'distsyd'});
#
        my $scanlistfm = '';
####
  if ($data{'mode'} eq "FM" && ($data{'distsyd'} ne '')) {
            if (($prefix3 eq 'VK1') || ($prefix3 eq 'VK2')) {
                
                if ($data{'distsyd'} <= '55000') {
                    $scanlistfm = 'SYDFM';
                }
                else { # improve later
                    $dirs = $dirn + 157.5;
                    if (($dirs lt 180) || ($dirs gt 360)) { #west
                        $scanlistfm = 'VK2WFM';
                    }
                    elsif ($dirs lt 270) {    #North
                        $scanlistfm = 'VK2NFM';
                    }
                    elsif ($dirs le 360) {    #South
                        $scanlistfm = 'VK2SFM';
                    }
                }
            }
            elsif ($prefix3 eq 'VK3') {
                if ($data{'distmel'} <= '80000') {
                    $scanlistfm = 'MELFM';
                }
                else { # improve later
                    $scanlistfm = 'VK3FM';
                }
            }
            elsif ($prefix3 eq 'VK4')  {
                if ($data{'disttmb'} <= '80000') {
                    $scanlistfm = 'TMBFM';
                }
                else { # improve later
                    $scanlistfm = 'VK4FM';
                }
            }
            elsif ($prefix3 eq 'VK5') {
                $scanlistfm = 'VK5FM';
            } 
            elsif ($prefix3 eq 'VK6') {
                $scanlistfm = 'VK6FM' ;
            }
            elsif ($prefix3 eq 'VK7') {
                $scanlistfm = 'VK7FM';
            } 
            elsif ($prefix3 eq 'VK8') {
                $scanlistfm = 'VK8FM';
            }

        }
        elsif ($data{'mode'} eq "FM" && $prefix3 eq 'APR') {
            $scanlistfm = 'APRSFM';
        }
        elsif ($data{'mode'} eq "FM" ) {
            $scanlistfm = 'OTHERFM';
        }
        if ($data{'mode'} eq "FM" ) {
                    my ( $index )= grep { $fmscanlist[$_] =~ /^$scanlistfm/ } 0..$#fmscanlist;
                    my $newfmscan = sprintf('%s;%s',$fmscanlist[$index],$CallUufld);
                    my $newfmscancnt = $fmscancnt[$index] +1 ;
                    if ($newfmscancnt > 31) {
                    print "too many entries for $scanlistfm \n";        
                    } else {
                    
                    splice(@fmscancnt,$index,1,$newfmscancnt);
                    splice(@fmscanlist,$index,1,$newfmscan);
                    }
        }


        my $newloc = sprintf("%s;%s;", $data{'latitude'},
            $data{'longditude'});

#net;city;cnty;country;ctry;lat;lon;';
# add fandling of lat lon later
        my $newdat2 =  sprintf(";;;;;%s",$newloc);

#longcall;callext1;callext2;txcontact1;rxgroup1;txcontact2;rxgroup2;pwr;
        my $newdat3 = sprintf("%.16s;%s%s%s;", $longcall, $callext, $txrx, $pwr);

        if (($data{'mode'} eq "FM" ) && (grep { $data{'Call'} eq $_ } @Favourdm)) {
            $scanlistfm = 'FAVFM';
            my ( $index )= grep { $fmscanlist[$_] =~ /^$scanlistfm/ } 0..$#fmscanlist;
            my $newfmscan = sprintf('%s;%s',$fmscanlist[$index],$CallUufld);
            my $newfmscancnt = $fmscancnt[$index] +1 ;
            if ($newfmscancnt > 31) {
                print "too many entries for $scanlistfm \n";        
            } else {    
                splice(@fmscancnt,$index,1,$newfmscancnt);
                splice(@fmscanlist,$index,1,$newfmscan);
            }
        } 
        if (! grep { $scanlistfm eq $_ } @ScanlistUniq) {
            push @ScanlistUniq, $scanlistfm;
        }

#scanlist1;scanlist2;scanlistfm
        my $scanlist1 = '';
        my $scanlist2 = '';
        my $scanlistdm = '';
        my $dmscanlist = sprintf(';;%s',$scanlistfm);
        if ($data{'mode'} eq "DV" ) { 
#        print "DEBUG Call ", $CallUufld," ", $prefix6,"\n";
            $scanlistdm = sprintf('%sDSL',$prefix6); 
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
                    print "too many entries for $scanlistdm \n";        
                    } else {
                    
                    splice(@dmrscancnt,$index,1,$newdmrscancnt);
                    splice(@dmrscanlist,$index,1,$newdmrscan);
                    }


# print "DEBUG Call ", $CallUufld," ", $prefix6," ",$scanlistdm," ",@ScanlistDUniq,"\n";

            $scanlist1 = $scanlistdm;
            $scanlist2 = '';
            if ($dmmix eq 's2' ) {
                    $scanlist1 = '';
                    $scanlist2 = $scanlistdm;
                }
            $dmscanlist = sprintf('%s;%s;',$scanlist1,$scanlist2) ;
        }
        my $newdat4 = sprintf("%s", $dmscanlist);
#
        my $newline = sprintf("2;%s;%s%s%s%s%s",
            $cnt, $newdata, $newdat1, $newdat2, $newdat3, $newdat4);
#
#
        if ($csv->parse($newline)) {
            print $chanfh $csv->string, "\n";
        }
        else {
            print STDERR "parse () failed on argument: ", $csv->error_input,
              "\n";
            $csv->error_diag();
        }
        if ($data{'mode'} eq "DV") {
            if ($data{'tsign'} ne "SIMPLEX") {
        # insert multiple if it is a repeater
            foreach $dmrlabtg (@FavmarcTG) {
                $cnt += 1;
           #print $dmrlabtg , "\n" ;
                $dmtype = 'd';
                @dmrtginfo = split('-',$dmrlabtg);
                $dmmix = sprintf('s%s',$dmrtginfo[0]);
                $dmrlab = $dmrtginfo[1];
                $dmrtg = $dmrtginfo[2];
                $dmrtgnum = $dmrtginfo[3];
                $pcallext = sprintf('%s %s',$dmrtg,$suffix4);
                $longcall = sprintf('%s %s',$dmrlab, $pcallext);
                $lenlongcall = length($longcall);
                $lenpcallext = length($pcallext);
                if ( $lenlongcall > 16 ) { 
#                print "DEBUG too long :",$longcall,":", $psuffix4,":\n";
                    $templen = $lenlongcall - 16 ;
                    $pcallext = substr $pcallext,0, ($lenpcallext - $templen);
#                print "DEBUG now :", $psuffix4,":\n";
                }
                $callext1 = $pcallext;

                
                $CallUufld = $dmrlab ;
                $scanlistdm = sprintf('%sDSL',$prefix6);
                my $newdat1 = sprintf("%s;%s;%s;",$dmccode, $dmmix, $tonefld);
                $scanlist1 = $scanlistdm;
                $scanlist2 = '';
                $callext1 = $pcallext;
                $callext2 = '';

                my ( $tgindex ) = grep { $tgnumuniq[$_] =~ /^$dmrtgnum/ } 0..$#tgnumuniq;
                $txcontact = sprintf('%s',$tgnamuniq[$tgindex]);
#            print "DEBUG: index :",$index,":numuniq:",$tgnumuniq[$index],":nam:",$tgnamuniq[$index],":\n";

                $txcontact1 = $txcontact;
                $txcontact2 = '';
                if ($dmmix eq 's2' ) {
                    $callext1 = '';
                    $callext2 = $pcallext;
                    $txcontact1 = '';
                    $txcontact2 = $txcontact;
                    $scanlist1 = '';
                    $scanlist2 = $scanlistdm;
                }
                    my ( $index )= grep { $dmrscanlist[$_] =~ /^$scanlistdm/ } 0..$#dmrscanlist;
                    my $newdmrscan = sprintf('%s;%s',$dmrscanlist[$index],$longcall);
                    my $newdmrscancnt = $dmrscancnt[$index] +1 ;
#       print "DEBUG newdmr ", $newdmrscan," :", $newdmrscancnt,"\n";
                    if ($newdmrscancnt > 31) {
                    print "too many entries for $scanlistdm \n";        
                    } else {
                    
                    splice(@dmrscancnt,$index,1,$newdmrscancnt);
                    splice(@dmrscanlist,$index,1,$newdmrscan);
                    }



$dmscanlist = sprintf('%s;%s;',$scanlist1,$scanlist2);
                $newdata =
          sprintf("%s;%s;000;%s;%s;", $dmtype,$CallUufld,$data{'Output'},$data{'Offset'});

#scanlist1;scanlist2;scanlistfm
                $newdat4 = sprintf("%s", $dmscanlist);
                $longcall = sprintf('%s %s',$dmrlab, $pcallext);
                $callext = sprintf('%s;%s;',$callext1,$callext2);
#                print "DEBUG b4p :",$lenlongcall,":",$longcall,":", $psuffix4,":",$callext,":\n"; 

                $txrx = sprintf('%s;%s;%s;%s;',$txcontact1,$rxgroup1,$txcontact2,$rxgroup2);
                $newdat3 = sprintf("%.16s;%s%s%s;", $longcall, $callext, $txrx, $pwr);
            
                $newline = sprintf("2;%s;%s%s%s%s%s",
                $cnt,$newdata, $newdat1, $newdat2, $newdat3, $newdat4);
                if ($csv->parse($newline)) {
                    print $chanfh $csv->string, "\n";
                }
                else {
                    print STDERR "parse () failed on argument: ", $csv->error_input,"\n";
                    $csv->error_diag();
                }
            
            }
            }
        }
    }
}
my $scanheader = 'ScanList;Ch1;Ch2;Ch3;Ch4;Ch5;Ch6;Ch7;Ch8;Ch9;Ch10;Ch11;Ch12;Ch13;Ch14;Ch15;Ch16;Ch17;Ch18;Ch19;Ch20;Ch21;Ch22;Ch23;Ch24;Ch25;Ch26;Ch27;Ch28;Ch29;Ch30;Ch31';
my $zoneheader = 'ZoneList;Ch1;Ch2;Ch3;Ch4;Ch5;Ch6;Ch7;Ch8;Ch9;Ch10;Ch11;Ch12;Ch13;Ch14;Ch15;Ch16';


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
my ( $dsindex )= grep { $dmrscanlist[$_] =~ 'VKSMPLDSL' } 0..$#dmrscanlist;
my $holddmrsmplind = $dsindex ;
my $holddmrsmplcnt = $dmrscancnt[$holddmrsmplind];
my @holddmrsmplscan = split(';',$dmrscanlist[$holddmrsmplind]);

# DMR Scanlist
my $newdmrscancnt;
$tmpindex = 0 ;
foreach $newdmrscancnt (@dmrscancnt) {
    my @tmpdmrsl = split(';',$dmrscanlist[$tmpindex]);
    if ($tmpdmrsl[0] ne 'VKSMPLDSL'){
    
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
                    $zonename = sprintf('%.7s',$tmpfmx) ;
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
    #append the vksmpl stuff to dmr entries about here
#    my $zonesuffix = substr $zonename, -1; 
#    if ( $zonesuffix eq 'D') {
#       my $extracnt = 17 - $holddmrsmplcnt + 1 ;
#        print "DEBUG: A zonesuffix ",$extracnt," zone0 ",$zoneline, "\n";
    
#       if (( $tmpcnt < $extracnt ) && ($zonename ne 'VKSMPLD')) {
#        print "DEBUG: inside vksmpl ";
#        my $vksimplind = 0;
#        while ($vksimplind < $holddmrsmplcnt){
#            $vksimplind += 1;
#            $zoneline = sprintf('%s;%s',$zoneline,$holddmrsmplscan[$vksimplind]);
#            $tmpcnt += 1;    
#        }
#    }
#    }
    while ($tmpcnt < 17) {
        $zoneline = sprintf('%s;',$zoneline);
        $tmpcnt += 1;
    } 
    $tmpcnt = 0;
    $tmpindex = 0;
    $tmpuniq = 0;
    push @zonelist,$zoneline;
}
    
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

exit
