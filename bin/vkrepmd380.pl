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
#0;num;type;callsign;dmrid;qrg;shift;cc;mix;ctcss;net;city;cnty;country;ctry;lat;lon;longcall;callext1;callext2;txcontact1;rxgroup1;txcontact2;rxgroup2;pwr;scanlist1;scanlist2;scanlistfm
#2;1;d;VK4DU;000;438.02500;-7.00000;1;s1;;;;;;;;;VK4DU WW CALL;WW CALL;;WW CALL TG1;None;;;Low;VK4DU;;
#2;3;d;VK4DU;000;438.02500;-7.00000;1;;;;;;;;;;VK4DU WW ENG;WW ENG;VK/ZL;WW EN TG13;None;VK/ZL TG5;None;High;VK4DU;VK4DU;
#2;4;d;VK4RTW;000;439.61250;-5.00000;1;s1;;;;;;;;;VK4RTW WW CALL;WW CALL;;WW CALL TG1;None;;;High;VK4RTW;;
#2;5;d;VK4RTW;000;439.61250;-5.00000;1;s1;;;;;;;;;VK4RTW WW ENG;WW ENG;;WW EN TG13;None;;;High;VK4RTW;;
#2;6;d;VK4RTW;000;439.61250;-5.00000;1;s1;;;;;;;;;VK4RTW UA E 1;UA E 1;;UA EN1 TG113;None;;;High;VK4RTW;;
#2;19;d;2;000;439.50000;-5.00000;1;s1;;;;;;;;;2 WW CALL TG1;WW CALL TG1;;WW CALL TG1;None;;;High;VK2RCG;;
#2;20;d;2WW;000;439.50000;-5.00000;1;s1;;;;;;;;;2WW ENG TG13;ENG TG13;;WW EN TG13;None;;;High;VK2RCG;;
#2;21;d;2;000;439.50000;-5.00000;1;s1;;;;;;;;;2 UA E 1 TG113;UA E 1 TG113;;UA EN1 TG113;None;;;High;VK2RCG;;
#2;23;d;2;000;439.50000;-5.00000;1;;;;;;;;;;2 UA E 2 TG123;UA E 2 TG123;VK/ZL TG5;UA EN2 TG123;None;VK/ZL TG5;None;High;VK2RCG;VK2RCG;
#2;24;d;VK3RZU;000;439.67500;-5.00000;1;s1;;;;;;;;;VK3RZU WW CALL;WW CALL;;WW CALL TG1;None;;;High;VK3RZU;;
#2;25;d;VK3RZU;000;439.67500;-5.00000;1;s1;;;;;;;;;VK3RZU WW ENG;WW ENG;;WW EN TG13;None;;;High;VK3RZU;;
#2;43;d;VK6RRR;000;438.20000;-5.40000;1;;;;;;;;;;VK6RRR UA E 2;UA E 2;VK/ZL;UA EN2 TG123;None;VK/ZL TG5;None;High;VK6RRR;VK6RRR;
#2;44;d;VK4DU;000;438.02500;-7.00000;1;s1;;;;;;;;;VK4DU UA ENG 1;UA ENG 1;;UA EN1 TG113;None;;;High;VK4DU;;
#2;46;d;VK4DU;000;438.02500;-5.17500;1;;;;;;;;;;VK4DU UA ENG 2;UA ENG 2;VK;UA EN2 TG123;None;VK TG505;None;High;VK4DU;VK4DU;
#2;47;d;VK4DU;000;438.02500;-5.17500;1;s1;;;;;;;;;VK4DU LOCAL;LOCAL;;LOCAL TG9;None;;;High;VK4DU;;
#2;49;d;VK4RTW;000;439.61250;-5.00000;1;;;;;;;;;;VK4RTW VK;LOCAL;VK;LOCAL TG9;None;VK TG505;None;High;VK4RTW;VK4RTW;
#2;63;d;VK6RRR;000;438.20000;-5.40000;1;;;;;;;;;;VK6RRR VK;LOCAL;VK;LOCAL TG9;None;VK TG505;None;High;VK6RRR;VK6RRR;
#2;64;d;DMR;000;438.92500;0.00000;1;s1;;;;;;;;;DMR S8.925 TG1;S8.925 TG1;;None;None;;;High;VK2RCG;;
#2;65;d;DMR;000;439.20000;0.00000;1;s1;;;;;;;;;DMR S 9.2 TG505;S 9.2 TG505;;VK TG505;None;;;High;VK2RCG;;
#2;66;a;Kurrajong 1;000;439.82500;-5.00000;;;91.5;;;;;;;;Kurrajong 1;1;;;;;;High;;;VK2RCG
#2;67;a;Kurrajong 2;000;439.87500;-5.00000;;;110.9;;;;;;;;Kurrajong 2;2;;;;;;High;;;VK2RCG
#2;68;a;2RCGFM;000;439.80000;-5.00000;;;91.5;;;;;;;;2RCGFM;;;;;;;High;;;VK2RCG
#2;69;a;2ROTFM;000;438.57500;-5.00000;;;91.5;;;;;;;;2ROTFM;;;;;;;High;;;VK2RCG
#2;70;d;2RCG;000;439.50000;-5.00000;1;s1;;;;;;;;;2RCG Tech TG100;Tech TG100;;None;None;;;High;VK2RCG;;
#2;71;a;2ROZFM;000;438.11250;-5.40000;;;91.5;;;;;;;;2ROZFM;;;;;;;High;;;VK2RCG

use Text::CSV_XS;
use List::Util qw(first);

my @ScanlistUniq;
my @dmscantmp;
my @dmscanlist;
our @Favourdm;
our @FavmarcTG;
require My::Favourites;
#use List::Util qw(first);
#use Scalar::Util qw(looks_like_number);
my @fmscanlist = ( 'FAVFM','MELFM','OTHERFM','SYDFM','TMBFM','VK2NFM','VK2SFM','VK2WFM','VK3FM','VK4FM','VK5FM','VK6FM','VK7FM','VK8FM' ) ;
my @fmscancnt = ( 0,0,0,0,0,0,0,0,0,0,0,0,0,0 );
my $dmscantmp = '';
my $index = '';
my $csv = Text::CSV_XS->new({sep_char => ','});

#open vkrepdir.csv
my $file1 = $ARGV[0] or die "Need main CSV file on the command line\n";

# open vkrepdmrxx.csv
my $file2pre = $ARGV[1] or die "Need directory for output e.g.(output/dmr) on the command line\n";
#my $file2 = $ARGV[1] or die "Need merge CSV file on the command line\n";
#my $file3 = $ARGV[2] or die "Need scanlist CSV file on the command line\n";
my @CallUuniq;
my $cnt        = 0;
my $call       = '';
my $cntfld     = '';
my $dmscancnt = 0;
# Load arrays with file contents
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

#read the header line of the main input
my @fields = @{$csv->getline($vkrdfh)};

# Read each line from the CSV file, and store it in @rows
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
        my $suffix4  = substr $prefix6, 2, 4 ;
        my $dmtype =  'a' ;
        my $dmccode = '' ;
        my $dmmix   = '' ;
        if ($data{'mode'} eq "DV" ) { 
            $dmtype= 'd' ;
            $dmccode = '1' ;
            $dmmix = 's1' ;
            };
        
        my $CallUufld = sprintf("%s", $data{'Call U'});
        if (grep { $CallUufld eq $_ } @CallUuniq) {

#        print "$CallUufld not unique\n";
            my $cuniq = '64';
            while (grep { $CallUufld eq $_ } @CallUuniq) {
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


#cc;mix;ctcss;

#my $tonefld = '';
        my $tonefld = ($data{'Tone'} eq '-') ? '' : $data{'Tone'};
        my $newdat1 = sprintf("%s;%s;%s;",$dmccode, $dmmix, $tonefld);



#longcall; callext1;callext2;txcontact1;rxgroup1;txcontact2;rxgroup2;pwr;
#2ROTFM   ;         ;        ;          ;        ;          ;        ;High;;;VK2RCG
#2RCG Tech TG100;Tech TG100; ;None      ;None    ;          ;        ;High;

#        my $prefix6  = sprintf("%.6s", $data{'Call U'});
#        my $suffix4  = substr $prefix6, 2, 4 ;
        my $dmrlabtg = '1-LOCAL-TG9';
        my @dmrtginfo = split('-',$dmrlabtg);
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
        if ($data{'mode'} eq "DV" ) { 
            my $dmrlab = $dmrtginfo[1];
            my $dmrtg = $dmrtginfo[2];
            $CallUufld = $dmrlab ;
            $callext1 = sprintf('%s %s',$dmrtg,$suffix4);
            $txcontact1 = sprintf('%s %s',$dmrlab,$dmrtg);
            $longcall = sprintf('%s %s %s',$dmrlab, $dmrtg,$suffix4);
            $callext = sprintf('%s;%s;',$callext1,$callext2);
            $txrx = sprintf('%s;%s;%s;%s;',$txcontact1,$rxgroup1,$txcontact2,$rxgroup2);
}
#
        my $newdata =
          sprintf("%s;%s;000;%s;%s;", $dmtype,$CallUufld,$data{'Output'},$data{'Offset'});

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
        my $newdat3 = sprintf("%s;%s%s%s;", $longcall, $callext, $txrx, $pwr);

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
        #my $scanlistfm = sprintf(';;%sFM',$prefix6);
        my $scanlist1 = '';
        my $scanlist2 = '';
        my $scanlistdm = '';
        my $dmscanlist = sprintf(';;%s',$scanlistfm);
        if ($data{'mode'} eq "DV" ) { 
            $scanlistdm = sprintf('%sDM',$prefix6); 
            if (! grep { $scanlistdm eq $_ } @ScanlistUniq) {
                push @ScanlistUniq, $scanlistdm;
            }
            $scanlist1 = $scanlistdm;
            $dmscanlist = sprintf('%s;%s;',$scanlist1,$scanlist2) ;
            @dmscantmp = $scanlistdm;
            $dmscancnt = 0;
            push @dmscantmp, sprintf('%.16s',$longcall);
            $dmscancnt += 1;
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
        # insert multiple
            foreach $dmrlabtg (@FavmarcTG) {
                $cnt += 1;
           #print $dmrlabtg , "\n" ;
                my @dmrtginfo = split('-',$dmrlabtg);
                my $dmmix = sprintf('s%s',$dmrtginfo[0]);
                my $dmrlab = $dmrtginfo[1];
                my $dmrtg = $dmrtginfo[2];
                $CallUufld = $dmrlab ;
                $scanlistdm = sprintf('%sDM',$prefix6);
                my $newdat1 = sprintf("%s;%s;%s;",$dmccode, $dmmix, $tonefld);
                $scanlist1 = $scanlistdm;
                $scanlist2 = '';
                $callext1 = sprintf('%s %s',$dmrtg,$suffix4);
                $callext2 = '';
                $txcontact1 = sprintf('%s %s',$dmrlab,$dmrtg);
                $txcontact2 = '';
                if ($dmmix eq 's2' ) {
                    $callext1 = '';
                    $callext2 = sprintf('%s %s',$dmrtg,$suffix4);
                    $txcontact1 = '';
                    $txcontact2 = sprintf('%s %s',$dmrlab,$dmrtg);
                    $scanlist1 = '';
                    $scanlist2 = $scanlistdm;
                }
                if (! grep { $scanlistdm eq $_ } @ScanlistUniq) {
                    push @ScanlistUniq, $scanlistdm;
                }
                $dmscanlist = sprintf('%s;%s;',$scanlist1,$scanlist2);
                my $newdata =
          sprintf("%s;%s;000;%s;%s;", $dmtype,$CallUufld,$data{'Output'},$data{'Offset'});

#scanlist1;scanlist2;scanlistfm
                $newdat4 = sprintf("%s", $dmscanlist);
                $longcall = sprintf('%s %s %s',$dmrlab, $dmrtg, $suffix4);
                $callext = sprintf('%s;%s;',$callext1,$callext2);
                $txrx = sprintf('%s;%s;%s;%s;',$txcontact1,$rxgroup1,$txcontact2,$rxgroup2);
                my $newdat3 = sprintf("%s;%s%s%s;", $longcall, $callext, $txrx, $pwr);
            
                my $newline = sprintf("2;%s;%s%s%s%s%s",
                $cnt,$newdata, $newdat1, $newdat2, $newdat3, $newdat4);
                if ($csv->parse($newline)) {
                    print $chanfh $csv->string, "\n";
                    push @dmscantmp, sprintf('%.16s',$longcall);
                    $dmscancnt += 1;
                }
                else {
                    print STDERR "parse () failed on argument: ", $csv->error_input,"\n";
                    $csv->error_diag();
                }
            
            }
            $dmscantmp = join(';',@dmscantmp);
            while ($dmscancnt < 31) {
                $dmscantmp = sprintf('%s;',$dmscantmp);
                $dmscancnt += 1;
            }
            push @dmscanlist,$dmscantmp;
#            print $dmscantmp,"\n";

        }
    }
}
#@ScanlistUniq = sort(@ScanlistUniq);
#print "@ScanlistUniq\n";
my $scanheader = 'ScanList;Ch1;Ch2;Ch3;Ch4;Ch5;Ch6;Ch7;Ch8;Ch9;Ch10;Ch11;Ch12;Ch13;Ch14;Ch15;Ch16;Ch17;Ch18;Ch19;Ch20;Ch21;Ch22;Ch23;Ch24;Ch25;Ch26;Ch27;Ch28;Ch29;Ch30;Ch31';
my $zoneheader = 'ZoneList;Ch1;Ch2;Ch3;Ch4;Ch5;Ch6;Ch7;Ch8;Ch9;Ch10;Ch11;Ch12;Ch13;Ch14;Ch15;Ch16';



#                    my ( $index )= grep { $fmscanlist[$_] =~ /^$scanlistfm/ } 0..$#fmscanlist;
#                    my $newfmscan = sprintf('%s;%s',$fmscanlist[$index],$CallUufld);
#                    my $newfmscancnt = $fmscancnt[$index] +1 ;
#                    if ($newfmscancnt > 31) {
#                    print "too many entries for $scanlistfm \n";        
#                    } else {
#                    
#                    splice(@fmscancnt,$index,1,$newfmscancnt);
#                    splice(@fmscanlist,$index,1,$newfmscan);
#
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

$tmpindex = 0;
my $tmpcnt = $tmpindex ;
my $tmpuniq = 0 ;
my $scanent;
my $tmpfmx;
my $zonename;
my $zoneline;
my @zonelist ;
my @bothlist = (@dmscanlist,@fmscanlist) ;
foreach $scanent (@bothlist){
#    print "scanent $scanent\n" ;
    my @tmpfment = split(';',$scanent);
    foreach $tmpfmx (@tmpfment) {
#        print "tmpfmx $tmpfmx C $tmpcnt I $tmpindex \n" ;
        if ($tmpcnt < 17 ) {
            if ( $tmpcnt == 0 ) {
                if ( $tmpindex == 0 ) {
                    $zonename = sprintf('%.6s',$tmpfmx) ;
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
    
print $zonefh $zoneheader,"\n";

foreach $zoneline (@zonelist) {
    print $zonefh $zoneline,"\n";
}
    

print $scanfh $scanheader,"\n";
foreach $scanent (@bothlist) {
    print $scanfh $scanent,"\n";
}
#my $newfmscan;
#foreach $newfmscan (@fmscanlist) {
#    print $scanfh $newfmscan,"\n";
#}
#}

# Close the file handles.
close $zonefh;
close $scanfh;
close $chanfh;
close $vkrdfh;

exit
