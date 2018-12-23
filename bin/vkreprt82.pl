#!/opt/local/bin/perl
#
# Creates a data file(s) for the MD-380
#
#UHF 400-480MHz
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
use List::MoreUtils;
use Findbin::Libs;
require My::Favourites;

my @longcalluniq;
my @ScanlistUniq;
my @ScanlistDUniq;
my @ZonelistDUniq;

my @dmrscanlist;
my @dmrscancnt;
my @LocalmarcTG;
my @dmrtginfo;
our @Favourdm;
our @FavmarcTG;
our @FavmarcWTG;
our @FavdmrpTG;
our @FavdmrefTG;
our @FavdmrpTGcontact;
our @FavsimpTG;
our @FavwicenTG;
our @FavwicenchTGK;
our @FavsimpWTG;
our @FavDMRP;
our @FavdmrOspotTG;
our @FavsharkDMRGTB;
our @FavsharkDMRGTPB;
our @FavsharkDMRGTD;
our @FavsharkDMRGTPD;
our @FavsharkDMRGTX;
our @FavsharkDMRGTPX;
our @FavsharkDMRGTI;
our @FavsharkDMRGTPI;
our @FavmmdvmDMRGTB;
our @FavmmdvmDMRGTPB;
our @FavmmdvmDMRGTD;
our @FavmmdvmDMRGTPD;
our @FavmmdvmDMRGTX;
our @FavmmdvmDMRGTPX;
our @Favopenspotrx;
our @FavDMRno1_9;
our @Favtsqlr;

my $dmscantmp = '';
my $index     = '';
my $csv       = Text::CSV_XS->new({sep_char => ','});

my @CallUuniq;
my $cnt    = 0;
my $call   = '';
my $cntfld = '';
my $txcontact;
my $dmrtg;
my $calltxrxscan;

my @fmscanlist;
my @fmscancnt;
my @zonelist;
my @zonecnt;
my $bandsufx;
my $outputok;


#open vkrepdir.csv
my $file1 = $ARGV[0] or die "HALTED: Need main CSV file on the command line\n";

# open vkrepdmrxx.csv
my $file2pre = $ARGV[1]
  or die
  "HALTED: Need directory for output e.g.(output/dmr) on the command line\n";

#Open input file
open(my $vkrdfh, '<', $file1) or die "HALTED: Could not open '$file1' $!\n";

my $model = $ARGV[2]
  or die
  "HALTED: Need model for output e.g.(rt3, rt8, rt82) on the command line\n";

my $band = $ARGV[3]
  or die "HALTED: Need band for output e.g.(u, v) on the command line\n";

#open output file
my $file2chan = sprintf("%s%s%schan.csv",      $file2pre, $model, $band);
my $file2scan = sprintf("%s%s%sscan.csv",      $file2pre, $model, $band);
my $file2zone = sprintf("%s%s%szone.csv",      $file2pre, $model, $band);
my $file2chn0 = sprintf("%s%s%schann0gsg.csv", $file2pre, $model, $band);

open(my $chanfh, '>', $file2chan)
  or die "HALTED: Could not open '$file2chan' $!\n";
open(my $scanfh, '>', $file2scan)
  or die "HALTED: Could not open '$file2scan' $!\n";
open(my $zonefh, '>', $file2zone)
  or die "HALTED: Could not open '$file2zone' $!\n";
open(my $chn0fh, '>', $file2chn0)
  or die "HALTED: Could not open '$file2chn0' $!\n";

my $newhea1 =
  '0;num;type;callsign;dmrid;qrg;shift;cc;mix;ctcss;net;city;cnty;country;ctry;lat;lon;';
my $newhea2 =
  'longcall;callext1;callext2;txcontact1;rxgroup1;txcontact2;rxgroup2;pwr;';
my $newhea3 = 'scanlist1;scanlist2;scanlistfm';

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

#Channel Name,Mode,BW,TxFreq,RxFreq,ScaList,Squelch,Admit,RxRef,TxRef,TOT,TOTDelay,Power,AutoScan,Rx Only,Lone,VOX,AllowTA,CTCSSDec,CTCSSEnc,QTReverse,TxSig,RxSig,RevBurstTone,De 1,De 2,De 3,De 4,De 5,De 6,De 7,De 8,PrivCall,EmergAck,DataCall,Emerg,Contact,RXGrp,CC,Privacy,PrivacyNum,TS
#"VK2RBV 7","FM","25","432.712500","438.112500","FAVFM7","NORMAL","Always","Low","Low","300","0","HIGH","No","No","No","No","Yes","NONE","091.5","120","Off","Off","YES","NO","NO","NO","NO","NO","NO","NO","NO","NO","NO","NO","NONE","NONE","NONE","1","NONE","1","1"
#"9 1CGVK2", "DMR", "12.5", "434.500000", "439.500000", "VK2ROAM", "NORMAL", "Color Code Free", "Low", "Low", "90", "0", "HIGH", "No", "No", "No", "No", "Yes", "NONE", "NONE", "180", "Off", "Off", "YES", "NO", "NO", "NO", "NO", "NO", "NO", "NO", "NO", "YES", "NO", "NO", "NONE", "9 LOCAL", "RXGR1", "1", "NONE", "1", "1"
my $scanmax = ($model eq 'rt82') ? '32'    : '32';
my $zonemax = ($model eq 'rt82') ? '64'    : '16';
my $bandmin = ($band eq 'u')     ? '400.0' : '120.0';
my $bandmax = ($band eq 'u')     ? '480.0' : '170.0';

if ($band eq 'u') {
    @fmscanlist = (
        'FAVFM7',  'SYDFM7',   'VK2NFM7',  'VK2SFM7',
        'VK2WFM7', 'OTHERFM7', 'WICENFM7', 'MELFM7',
        'VK3FM7',  'TMBFM7',   'VK4FM7',   'VK5FM7',
        'VK6FM7',  'VK7FM7',   'VK8FM7',   'ESOFM',
        'UHFFM0',  'UHFFM1'
    );
    @fmscancnt = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    $bandsufx = '7';
}
else {
    @fmscanlist = (
        'FAVFM2',  'SYDFM2',   'VK2NFM2',  'VK2SFM2',
        'VK2WFM2', 'OTHERFM2', 'WICENFM2', 'WICENF21',
        'MELFM2',
        'VK3FM2',  'TMBFM2',   'VK4FM2',   'VK5FM2',
        'VK6FM2',  'VK7FM2',   'VK8FM2',   'RFSFM2',
        'MVHFM0',   'MVHFM1',    'APRSFM'
    );
    @fmscancnt = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    $bandsufx = '2';
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
    my @tmpDVinfo = split('-', $tmpDV);
    my $dmrDVnumb = $tmpDVinfo[0];
    my $dmrDVcall = $tmpDVinfo[1];
    my $dmrDVnet  = $tmpDVinfo[2];
    my $dmrDVregn = $tmpDVinfo[3];

#    print STDERR "DEBUG: DVnet ",$dmrDVnumb, "-", $dmrDVcall, "-", $dmrDVnet, "\n";
    push @dvlistdpnumb, $dmrDVnumb;
    push @dvlistdpcall, $dmrDVcall;
    push @dvlistdpnet,  $dmrDVnet;
    push @dvlistdpregn, $dmrDVregn;
}

#foreach my $prnDV (@dvlistdpcall) {
#   print STDERR "DEBUG: print Calls ", $prnDV, "\n";
#}

# Build talkgroup tables so that we can split names and numbers for later use

my @Favamateur;

my @bothTGlistb4 = (
    '1-9-LOCAL-9',  @FavwicenTG, @FavmarcTG,        @FavmarcWTG,
    @FavdmrefTG,    @FavdmrpTG,  @FavdmrpTGcontact, @FavsimpTG,
    @FavdmrOspotTG,
    @FavsharkDMRGTB, @FavsharkDMRGTPB, @FavsharkDMRGTD, @FavsharkDMRGTPD,
    @FavsharkDMRGTX, @FavsharkDMRGTPX,
    @FavmmdvmDMRGTB, @FavmmdvmDMRGTPB, @FavmmdvmDMRGTD, @FavmmdvmDMRGTPD,
    @FavmmdvmDMRGTX, @FavmmdvmDMRGTPX
);
my @bothTGlist = sort by_tg @bothTGlistb4;

#print "@bothTGlistb4\n";
print "@bothTGlist\n";
my @tgnumuniq;
my @tgnamuniq;
foreach my $tmpTG (@bothTGlist) {
    my @tmpTGinfo = split('-', $tmpTG);
    my $dmrlab = $tmpTGinfo[1];
    $dmrtg = $tmpTGinfo[2];
    my $dmrtgnum = $tmpTGinfo[3];
    my $dmrtgtext = sprintf('%s %s', $dmrlab, $dmrtg);
    if (grep { $dmrtgnum.'G' eq $_ } @tgnumuniq) {
#        print STDERR "\n DEBUG: TG contact exists :", $dmrtgnum, ":", $dmrtgtext,": not adding\n\n";
    }
    else {
        push @tgnumuniq, $dmrtgnum.'G';
        push @tgnamuniq, $dmrtgtext;
    }
}
my @bothTPlistb4 = (@FavmmdvmDMRGTPB, @FavmmdvmDMRGTPD, @FavmmdvmDMRGTPX);
my @bothTPlist = sort by_tg @bothTPlistb4;
print "@bothTPlist\n";
foreach my $tmpTP (@bothTPlist) {
    my @tmpTPinfo = split('-', $tmpTP);
    my $dmrlab    = $tmpTPinfo[1];
    my $dmrtg     = $tmpTPinfo[2];
    my $dmrtgnum  = $tmpTPinfo[3];
    my $dmrtgtext = sprintf('%s %s', $dmrlab, $dmrtg);
    if (grep { $dmrtgnum.'P' eq $_ } @tgnumuniq) {
#        print STDERR "\nDEBUG: TG contact exists :", $dmrtgnum, ":", $dmrtgtext,": not adding\n\n";
    }
    else {
        push @tgnumuniq, $dmrtgnum.'P';
        push @tgnamuniq, $dmrtgtext;
    }
}


#foreach my $prnTG (@tgnumuniq) {
#   print STDERR "DEBUG: print Talk Groups ", $prnTG, "\n";
#}
#read the header line of the main input
my @fields = @{$csv->getline($vkrdfh)};

my @rows;
while (my $row = $csv->getline($vkrdfh)) {
    my %datard;
    @datard{@fields} = @$row;    # This is a hash slice
    push @rows, \%datard;
    $outputok = 0;
    # This radio can handle DV-DMR and FM on 70
    if (($datard{'mode'} ~~ ["DV", "FM"])

        #   if (   ($datard{'mode'} ~~ ["DV"])
        && ($datard{'band'} ~~ [$bandsufx, "DMR"])
        && (($datard{'Input'} < $bandmax) && ($datard{'Input'} > $bandmin))
        && (   ($datard{'Output'} < $bandmax)
            && ($datard{'Output'} > $bandmin))
      )
    {
        $cnt += 1;

     #DEBUG      print "Station: $datard{'Call U'}, Output: $datard{Output}\n";
     #
     #2;num;type;callsign;dmrid;qrg;shift;

        # type is a or d
        # dmrid is 000
        #Channel Number,Receive Frequency,Transmit Frequency
        my $prefix6 = sprintf("%.6s", $datard{'Call U'});
        my $prefix3 = sprintf("%.3s", $datard{'Call U'});
        my $suffix4 = substr $prefix6, -4;
        my $suffix2 = substr $prefix6, -2;
        my $dmtype  = 'a';
        my $dmccode = '';
        my $dmmix   = '';
        my $dmrlabtg;
        my $dmrtgnum;
        my $tonefld    = '';
        my $CTCSSDec   = '';
        my $CTCSSEnc   = '';
        my $powerlevel = '';
        my $dmrlab     = '';
        my $dmrtg = '';
        my $pcallext    = '';
        my $lenlongcall = '';
        my $lenpcallext = '';
        my $templen     = '';
        my $newdata     = '';
        my $newdat1     = '';
        my $newdat2     = '';
        my $newdat3     = '';
        my $newdat4     = '';
        my $newn0gsg    = '';
        my $newn0gsg0   = '';
        my $newn0gsg1   = '';
        my $newn0gsg2   = '';
        my $newn0gsg3   = '';
        my $newn0gsg4   = '';

        my $CallUufld = sprintf("%s", $datard{'Call U'});
	  my $CallUdfld = $CallUufld;
	  if (length $CallUufld > 6 ) {
	  	my $CallUxfld = substr($CallUdfld, 6, 1, '-');
	}
#	  print STDERR "DEBUG: Call: ", $datard{'Call'}," CallUufld: ", $CallUufld, " CallUdfld: ", $CallUdfld, "\n";
        unless ($datard{'Call'} eq "WICENS") {
            if (grep { $CallUufld eq $_ } @CallUuniq) {

 #                       print " DEBUG $CallUufld not unique\n";
                my $cuniq = '64';
                while (grep { $CallUufld eq $_ } @CallUuniq) {
                    $cuniq += 1;
                    my $ccuniq = chr($cuniq);
                    my $tCallUufld = substr $CallUufld, 6, 1, $ccuniq;
                }
 #                           print "DEBUG Inserting $CallUufld\n";
                push @CallUuniq, $CallUufld;
            }
            else {
                push @CallUuniq, $CallUufld;
            }
        }

       #longcall;callext1;callext2;txcontact1;rxgroup1;txcontact2;rxgroup2;pwr;

        #
        # for FM longcall for DMR 2 fields
        #
        #        my $newdat3 = sprintf(",,%s,,,,,,", $datard{'txpower'});
        my $dmrDVnet  = '';
        my $dmrDVregn = '';
        my $dvreptg   = '';
        my $longcall  = sprintf("%s %s %s",
            $CallUufld, $datard{'mNemonic'}, $datard{'Location'});
        my $rxgroup = '';
        my $pwr     = 'H';
        $calltxrxscan = sprintf(';;;;;;%s;;;', $pwr);

   #print STDERR "DEBUG mode ", $datard{'mode'}, "tone ", $datard{'Tone'},"\n";
        my $bwidth = ($datard{'mode'} eq 'FM') ? '25' : '12.5';
        if ($datard{'mode'} eq "FM") {
            $tonefld = ($datard{'Tone'} eq '-') ? '' : $datard{'Tone'};

           #23oct17 set ccode to '' for FM to switch off automatic receive tone
            $dmccode = ($tonefld eq '') ? '' : '';

            # need to find a way to deal with CTCSSDec from data
		if ( grep { $CallUdfld eq $_ } @Favtsqlr) {
			#23dec18 set ccode to 'c' for FM to switch on automatic receive tone
	     	 $CTCSSDec = ($tonefld eq '') ? 'None' : sprintf("%05.1f", $tonefld);
		 $dmccode = ($tonefld eq '') ? '' : 'c';
	 } else {
		 $CTCSSDec = 'None';
	 }

#            print $tonefld," ";
            $CTCSSEnc =
              ($tonefld eq '') ? 'None' : sprintf("%05.1f", $tonefld);

#            print $CTCSSEnc,"\n";
        }
        if ($datard{'mode'} eq "DV") {

#print STDERR "DEBUG: $datard{'Call'}\n";
   # check if we have identified if the net is dmrplus or brandmeister or WICEN
            my ($dvindex) =
              grep { $dvlistdpcall[$_] eq $datard{'Call'} }
              0 .. $#dvlistdpcall;
            if ($dvindex) {
                $dmrDVnet  = sprintf('%s', $dvlistdpnet[$dvindex]);
                $dmrDVregn = sprintf('%s', $dvlistdpregn[$dvindex]);

#print STDERR "DEBUG: found repeater list Call:", $datard{'Call'}, " Mast: ", $dmrDVnet, " Reg: ", $dmrDVregn, "\n";
            }
#            print STDERR "DEBUG: found repeater list Call:", $datard{'Call'}, " Mast: ", $dmrDVnet, " Reg: ", $dmrDVregn, "\n";

            $dmtype   = 'd';
            $dmrlabtg = $datard{'Tone'};
            #            unless ($datard{'Call'} eq "WICENS"||"MMDVMB"||"MMDVMD"||"MMDVMX") {

            unless (grep { $datard{'Call'} eq $_ } @FavDMRno1_9) {
                $dmrlabtg =
                  ($datard{'Tone'} eq '-' | '91.5')
                  ? '1-9-LOCAL-9'
                  : $datard{'Tone'};
#print STDERR "DEBUG: unless Wicen/Hotspot Call:", $datard{'Call'}, " dmrlabtg: ", $dmrlabtg, "\n";
            }

#print STDERR "DEBUG dmrlabtg :", $dmrlabtg, " ",$dmtype, " ",$CallUufld," ", $datard{'Call'},"\n";
            $tonefld = '';
            #      @dmrtginfo = split('-',$dmrlabtg);
            #$dmccode = '1';
            my ($dmccode,   $dmmix,        $longcall, $calltxrxscan,
                $CallUufld, $newn0gsgscan, $newn0gsgx
              )
              = dvtxrx($dmrlabtg, $CallUufld, $datard{'Call'});
            if ($dmccode eq 'exists') {
               $outputok = 1;
              # print STDERR "DEBUG: $dmccode exists\n";
             } else {

# Drop the dmrDVnet code for now as special character is not helping
                $newdat1 = sprintf("%s;%s;%s;;", $dmccode, $dmmix, $tonefld);

#2ROTFM   ;         ;        ;          ;        ;          ;        ;High;;;VK2RCG
#2RCG Tech TG100;Tech TG100; ;None      ;None    ;          ;        ;High;#
                $newdata = sprintf("%s;%s;000;%s;%s;",
                    $dmtype, $CallUufld, $datard{'Output'}, $datard{'Offset'});
                $newdat3 = sprintf("%.16s;%s", $longcall, $calltxrxscan);

                #Channel Name,Mode,BW,TxFreq,RxFreq,
                $newn0gsg0 = sprintf("%s,%s,%s,%3.6f,%3.6f",
                    $longcall, $datard{'band'}, $bwidth, $datard{'Input'},
                    $datard{'Output'},);

#Squelch,Admit,RxRef,TxRef,TOT,TOTDelay,Power,AutoScan,Rx Only,Lone,VOX,AllowTA,CTCSSDec,CTCSSEnc,
                $powerlevel = ($datard{'txpower'} eq '5') ? 'HIGH' : 'LOW';
                $CTCSSDec   = '0.000';
                $CTCSSEnc   = '0.000';
                $newn0gsg1  = $newn0gsgscan;
                $newn0gsg2  = sprintf(
                    "NORMAL,Always,Low,Low,300,0,%s,No,No,No,No,Yes,%s,%s",
                    $powerlevel, $CTCSSDec, $CTCSSEnc);

#QTReverse,TxSig,RxSig,RevBurstTone,De 1,De 2,De 3,De 4,De 5,De 6,De 7,De 8,PrivCall,EmergAck,DataCall,Emerg,
                $newn0gsg3 =
                  "120,Off,Off,YES,NO,NO,NO,NO,NO,NO,NO,NO,NO,NO,NO,NONE";

                #Contact,RXGp,CC,Privacy,PrivacyNum,TS
                $newn0gsg4 = $newn0gsgx;
            }
        }    #End first DV
        else {
# Drop the dmrDVnet code for now as special character is not helping
            $newdat1 = sprintf("%s;%s;%s;;", $dmccode, $dmmix, $tonefld);
            $newdata = sprintf("%s;%s;000;%s;%s;",
                $dmtype, $CallUufld, $datard{'Output'}, $datard{'Offset'});
            $newdat3 = sprintf("%.16s;%s", $longcall, $calltxrxscan);

#Channel Name,Mode,BW,TxFreq,RxFreq,ScaList,Squelch,Admit,RxRef,TxRef,TOT,TOTDelay,Power,AutoScan,Rx Only,Lone,VOX,AllowTA,CTCSSDec,CTCSSEnc,QTReverse,TxSig,RxSig,RevBurstTone,De 1,De 2,De 3,De 4,De 5,De 6,De 7,De 8,PrivCall,EmergAck,DataCall,Emerg,Contact,RXGrp,CC,Privacy,PrivacyNum,TS
#"VK2RBV 7","FM","25","432.712500","438.112500","FAVFM7","NORMAL","Always","Low","Low","300","0","HIGH","No","No","No","No","Yes","NONE","091.5","120","Off","Off","YES","NO","NO","NO","NO","NO","NO","NO","NO","NO","NO","NO","NONE","NONE","NONE","1","NONE","1","1"
#"9 1CGVK2", "DMR", "12.5", "434.500000", "439.500000", "VK2ROAM", "NORMAL", "Color Code Free", "Low", "Low", "90", "0", "HIGH", "No", "No", "No", "No", "Yes", "NONE", "NONE", "180", "Off", "Off", "YES", "NO", "NO", "NO", "NO", "NO", "NO", "NO", "NO", "YES", "NO", "NO", "NONE", "9 LOCAL", "RXGR1", "1", "NONE", "1", "1"
#Channel Name,Mode,BW,TxFreq,RxFreq,
            $newn0gsg0 = sprintf("%s,%s,%s,%3.6f,%3.6f",
                $CallUufld, $datard{'mode'}, $bwidth, $datard{'Input'},
                $datard{'Output'},);

#Squelch,Admit,RxRef,TxRef,TOT,TOTDelay,Power,AutoScan,Rx Only,Lone,VOX,AllowTA,CTCSSDec,CTCSSEnc,
            $powerlevel = ($datard{'txpower'} eq '5') ? 'HIGH' : 'LOW';

#            $newn0gsg1 = $scanlistfm;
            $newn0gsg2 =
              sprintf("NORMAL,Always,Low,Low,300,0,%s,No,No,No,No,Yes,%s,%s",
                $powerlevel, $CTCSSDec, $CTCSSEnc);

#QTReverse,TxSig,RxSig,RevBurstTone,De 1,De 2,De 3,De 4,De 5,De 6,De 7,De 8,PrivCall,EmergAck,DataCall,Emerg,
            $newn0gsg3 =
              "120,Off,Off,YES,NO,NO,NO,NO,NO,NO,NO,NO,NO,NO,NO,NONE";

#Contact,RXGp,CC,Privacy,PrivacyNum,TS
            $newn0gsg4 = "NONE,NONE,1,None,1,1";
#
        }    #end first FM except scanlist


        my $dirn     = sprintf("%s", $datard{'dirkat'});
        my $dirs     = '';
        my $distcsyd = sprintf("%s", $datard{'distsyd'});
        #
        my $scanlistfm = '';
        my $zonelistfm = '';

        if ($datard{'mode'} eq "FM" && ($datard{'distsyd'} ne '')) {
            if (($prefix3 eq 'VK1') || ($prefix3 eq 'VK2')) {
                if ($datard{'distsyd'} <= '55000') { $scanlistfm = 'SYDFM'.$bandsufx; }
                else {    # improve later
                    $dirs = $dirn + 157.5;
                    if (($dirs lt 180) || ($dirs gt 360)) { $scanlistfm = 'VK2WFM'.$bandsufx; }
                    elsif ($dirs lt 270) { $scanlistfm = 'VK2NFM'.$bandsufx; }
                    elsif ($dirs le 360) { $scanlistfm = 'VK2SFM'.$bandsufx; }
                }
            }
            elsif ($prefix3 eq 'VK3') {
                if ($datard{'distmel'} <= '80000') { $scanlistfm = 'MELFM'.$bandsufx; }
                else { $scanlistfm = 'VK3FM'.$bandsufx; }
            }
            elsif ($prefix3 eq 'VK4') {
                if ($datard{'disttmb'} <= '80000') { $scanlistfm = 'TMBFM'.$bandsufx; }
                else { $scanlistfm = 'VK4FM'.$bandsufx; }
            }
            elsif ($prefix3 eq 'VK5') { $scanlistfm = 'VK5FM'.$bandsufx; }
            elsif ($prefix3 eq 'VK6') { $scanlistfm = 'VK6FM'.$bandsufx; }
            elsif ($prefix3 eq 'VK7') { $scanlistfm = 'VK7FM'.$bandsufx; }
            elsif ($prefix3 eq 'VK8') { $scanlistfm = 'VK8FM'.$bandsufx; }
        }
        elsif (($datard{'mode'} eq "FM")
            && (($prefix3 eq 'WIC') || ($prefix3 eq 'VRA')))
        {
            $scanlistfm = 'WICENFM'.$bandsufx;
        }
        elsif (($datard{'mode'} eq "FM") && ($prefix3 eq 'ESO')) { $scanlistfm = 'ESOFM'; }
        elsif ( ( $datard{'mode'} eq "FM" ) && ( $prefix3 eq 'RFS' ) ) { $scanlistfm = 'RFSFM'; }
        elsif ( ( $datard{'mode'} eq "FM" ) && ( $prefix3 eq 'MVH' ) ) { $scanlistfm = 'MVHFM0'; }
        elsif ( ( $datard{'mode'} eq "FM" ) && ( $prefix3 eq 'APR' ) ) { $scanlistfm = 'APRSFM'; }
        elsif (($datard{'mode'} eq "FM") && ($prefix3 eq 'UHF')) { $scanlistfm = 'UHFFM0'; }
        elsif ($datard{'mode'} eq "FM" && $prefix3 eq 'APR') { $scanlistfm = 'APRSFM'; }
        elsif ($datard{'mode'} eq "FM") { $scanlistfm = 'OTHERFM'.$bandsufx; }
    # Start build scan and zones
        if ($datard{'mode'} eq "FM") {

            if (fmscanbuild($scanlistfm, $CallUufld)) {
            }
            else {
                if ( $scanlistfm eq 'MVHFM0' ) {
                  $scanlistfm = 'MVHFM1';
                  if ( fmscanbuild( $scanlistfm, $CallUufld ) ) {
                  }
                  else { print "still not loaded MVHFM1\n" }
              }
                elsif ($scanlistfm eq 'UHFFM0') {
                    $scanlistfm = 'UHFFM1';
                    if (fmscanbuild($scanlistfm, $CallUufld)) {
                    }
                    else { print "still not loaded UHFFM1\n" }
                }
                elsif ($scanlistfm eq 'WICENFM'.$bandsufx) {
                    $scanlistfm = 'WICENF'.$bandsufx.'1';
                    if (fmscanbuild($scanlistfm, $CallUufld)) {
                    }
                    else { print "still not loaded WICENF".$bandsufx."1\n" }
                }
                else { print "not loaded  $scanlistfm $CallUufld \n" }
            }
          #  Build Zones independent of scanlists
            my $pat = 'FM'.$bandsufx ;
            my $zone = $scanlistfm ;
            if ( $zonemax > $scanmax ) { $zone =~ s/FM[0-1]/FM/ ;}
            $zone =~ s/$pat$/FM/;
            if (zonebuild($zone, $CallUufld)) {
            } else { print STDERR "DEBUG: $CallUufld didnt fit zone $zone\n" ;
            }
        }
        my $newloc =
          sprintf("%s;%s;", $datard{'latitude'}, $datard{'longditude'});
        #net;city;cnty;country;ctry;lat;lon;';
        # add fandling of lat lon later
        $newdat2 = sprintf(";;;;%s", $newloc);

#longcall;callext1;callext2;txcontact1;rxgroup1;txcontact2;rxgroup2;pwr;scanlist1;scanlist2;

        if (   ($datard{'mode'} eq "FM")
            && (grep { $datard{'Call'} eq $_ } @Favourdm))
        {
            $scanlistfm = 'FAVFM'.$bandsufx;
            if (fmscanbuild($scanlistfm, $CallUufld)) {

            }
            else {
                print "not loaded FAVFM\n";
            }
        }
        if (!grep { $scanlistfm eq $_ } @ScanlistUniq) {
            push @ScanlistUniq, $scanlistfm;
        }
        $newdat4 = $scanlistfm;
        $newn0gsg1 = ($newn0gsg1 eq '') ? $scanlistfm : $newn0gsg1;
        #
        # write channel output
        my $newline = sprintf("2;%s;%s%s%s%s%s",
            $cnt, $newdata, $newdat1, $newdat2, $newdat3, $newdat4);
        #
        if ($outputok) {
        #  print STDERR "DEBUG write chan1 exists\n";
        } else {
            if ($csv->parse($newline)) {
                print $chanfh $csv->string, "\n";
            }
            else {
                print STDERR "parse () failed on argument: ",
                  $csv->error_input,
                  "\n";
                $csv->error_diag();
            }
            $newn0gsg = sprintf("%s,%s,%s,%s,%s",
                $newn0gsg0, $newn0gsg1, $newn0gsg2, $newn0gsg3, $newn0gsg4);
            #
            if ($csv->parse($newn0gsg)) {
                print $chn0fh $csv->string, "\n";
            }
            else {
                print STDERR "parse () failed on argument: ",
                  $csv->error_input,
                  "\n";
                $csv->error_diag();
            }
            # First record should now be written
            #
            #This section creates additional DMR channels
            if ($datard{'mode'} eq "DV") {
                if (    # ( $datard{'tsign'} ne "SIMPLEX" ) &&
                    ($datard{'Call'} ne "WICENS")
                  )
                {

#print STDERR "DEBUG: searching repeater list ",$datard{'Call'}, " DVnet  ", $dmrDVnet, " \n";

                    # insert multiple if it is a repeater
                    if ($dmrDVnet eq 'IPSC2') {
                        @Favamateur = (@FavdmrpTG, @FavmarcTG, @FavmarcWTG);
                        if ($CallUufld eq 'SHARKI') {
                          @Favamateur = (@FavdmrOspotTG, @FavsharkDMRGTI, @FavsharkDMRGTPI, @Favamateur);
                        }
                    }
                    elsif ($dmrDVnet eq 'BM') {
                        @Favamateur = (@FavmmdvmDMRGTB);
                    }
                    elsif ($dmrDVnet eq 'REF') {
                        @Favamateur = (@FavdmrefTG);
                    }
                    elsif ($dmrDVnet eq 'SHARKB') {
                        @Favamateur = (@FavdmrOspotTG, @FavsharkDMRGTB, @FavsharkDMRGTPB);
                    }
                    elsif ($dmrDVnet eq 'SHARKD') {
                        @Favamateur = (@FavdmrOspotTG, @FavsharkDMRGTD, @FavsharkDMRGTPD);
                    }
                    elsif ($dmrDVnet eq 'SHARKX') {
                        @Favamateur = (@FavdmrOspotTG, @FavsharkDMRGTX, @FavsharkDMRGTPX);
                    }
                    elsif ($dmrDVnet eq 'MMDVMB') {
                        @Favamateur = (@FavmmdvmDMRGTB, @FavmmdvmDMRGTPB);
                    }
                    elsif ($dmrDVnet eq 'MMDVMX') {
                        @Favamateur = (@FavmmdvmDMRGTX, @FavmmdvmDMRGTPX);
                    }
                    elsif ($dmrDVnet eq 'MMDVMD') {
                        @Favamateur = (@FavmmdvmDMRGTD, @FavmmdvmDMRGTPD);
                    }
                    elsif ($dmrDVnet eq 'WICA') {
                        @Favamateur = (@FavwicenchTGK);
                    }
                    else {
                        @Favamateur = @FavmarcTG;
                    }
                    foreach $dmrlabtg (@Favamateur) {
                        $cnt += 1;
                        $dmtype = 'd';
                        my ($dmccode,      $dmmix,     $longcall,
                            $calltxrxscan, $CallUufld, $newn0gsgscan,
                            $newn0gsgx
                        ) = dvtxrx($dmrlabtg, $CallUufld, $datard{'Call'});

#            my $newdat1 = sprintf("%s;%s;%s;%s;",$dmccode, $dmmix, $tonefld, $dmrDVnet);
# Drop the dmrDVnet code for now as special character is not helping
                        my $newdat1 =
                          sprintf("%s;%s;%s;;", $dmccode, $dmmix, $tonefld);
                        $newdata = sprintf("%s;%s;000;%s;%s;",
                            $dmtype, $CallUufld, $datard{'Output'},
                            $datard{'Offset'});
                        $newdat3 =
                          sprintf("%.16s;%s", $longcall, $calltxrxscan);
                        $newdat4 = $scanlistfm;
                        $newline = sprintf(
                            "2;%s;%s%s%s%s%s",
                            $cnt,     $newdata, $newdat1,
                            $newdat2, $newdat3, $newdat4
                        );
                        #Channel Name,Mode,BW,TxFreq,RxFreq,
                        $newn0gsg0 = sprintf("%s,%s,%s,%3.6f,%3.6f",
                            $longcall, $datard{'band'}, $bwidth,
                            $datard{'Input'}, $datard{'Output'},);

#Squelch,Admit,RxRef,TxRef,TOT,TOTDelay,Power,AutoScan,Rx Only,Lone,VOX,AllowTA,CTCSSDec,CTCSSEnc,
                        $powerlevel =
                          ($datard{'txpower'} eq '5') ? 'HIGH' : 'LOW';
                        $CTCSSDec  = '0.000';
                        $CTCSSEnc  = '0.000';
                        $newn0gsg1 = $newn0gsgscan;
                        $newn0gsg2 = sprintf(
                            "NORMAL,Always,Low,Low,300,0,%s,No,No,No,No,Yes,%s,%s",
                            $powerlevel, $CTCSSDec, $CTCSSEnc);
#QTReverse,TxSig,RxSig,RevBurstTone,De 1,De 2,De 3,De 4,De 5,De 6,De 7,De 8,PrivCall,EmergAck,DataCall,Emerg,
                        $newn0gsg3 =
                          "120,Off,Off,YES,NO,NO,NO,NO,NO,NO,NO,NO,NO,NO,NO,NONE";

                        #Contact,RXGp,CC,Privacy,PrivacyNum,TS
                        $newn0gsg4 = $newn0gsgx;
                        if ($csv->parse($newline)) {
                            print $chanfh $csv->string, "\n";
                        }
                        else {
                            print STDERR "parse () failed on argument: ",
                              $csv->error_input, "\n";
                            $csv->error_diag();
                        }
                        $newn0gsg = sprintf("%s,%s,%s,%s,%s",
                            $newn0gsg0, $newn0gsg1, $newn0gsg2,
                            $newn0gsg3, $newn0gsg4);
                        #
                        if ($csv->parse($newn0gsg)) {
                            print $chn0fh $csv->string, "\n";
                        }
                        else {
                            print STDERR "parse () failed on argument: ",
                              $csv->error_input,
                              "\n";
                            $csv->error_diag();
                        }

                    }    #End tglist
                }
            }    # end DV
        }    #exists
    }    #end freq range
}    #get line

# FM Scanlist fill
my $newfmscancnt;
my $tmpindex = 0;
foreach $newfmscancnt (@fmscancnt) {
    while ($newfmscancnt < $scanmax - 1) {
        my $addsemicolon = sprintf('%s;', $fmscanlist[$tmpindex]);
        splice(@fmscanlist, $tmpindex, 1, $addsemicolon);
        $newfmscancnt += 1;
    }
    $tmpindex += 1;
}
#

# DMR Scanlist fill
my $newdmrscancnt;
$tmpindex = 0;
foreach $newdmrscancnt (@dmrscancnt) {
    my @tmpdmrsl = split(';', $dmrscanlist[$tmpindex]);
    my $extracnt = $scanmax;
    while ($newdmrscancnt < $scanmax - 1 ) {
        my $addsemicolon = sprintf('%s;', $dmrscanlist[$tmpindex]);
        splice(@dmrscanlist, $tmpindex, 1, $addsemicolon);
        $newdmrscancnt += 1;
    }
    $tmpindex += 1;
}


#Fill empty zones

my $newzonecnt;
$tmpindex = 0;
foreach $newzonecnt (@zonecnt) {
    while ($newzonecnt < $zonemax ) {
        my $addsemicolon = sprintf('%s;', $zonelist[$tmpindex]);
        splice(@zonelist, $tmpindex, 1, $addsemicolon);
        $newzonecnt += 1;
    }
    $tmpindex += 1;
}

#output the files
#Generate the headers
#my $scanheader = 'ScanList;Ch1;Ch2;Ch3;Ch4;Ch5;Ch6;Ch7;Ch8;Ch9;Ch10;Ch11;Ch12;Ch13;Ch14;Ch15;Ch16;Ch17;Ch18;Ch19;Ch20;Ch21;Ch22;Ch23;Ch24;Ch25;Ch26;Ch27;Ch28;Ch29;Ch30;Ch31';
#my $zoneheader = 'ZoneList;Ch1;Ch2;Ch3;Ch4;Ch5;Ch6;Ch7;Ch8;Ch9;Ch10;Ch11;Ch12;Ch13;Ch14;Ch15;Ch16';

my $scanheader = 'ScanList';
my $zoneheader = 'ZoneList';
for ( my $i = 1; $i < $scanmax ; $i++ ) { $scanheader = sprintf('%s;Ch%i', $scanheader, $i) };
for ( my $i = 1; $i <= $zonemax ; $i++ ) { $zoneheader = sprintf('%s;Ch%i', $zoneheader, $i) };

#print "DEBUG: scanheader ", $scanheader, "\n";
#print "DEBUG: zoneheader ", $zoneheader, "\n";

print $zonefh $zoneheader, "\n";
foreach my $zoneline (@zonelist) {
    print $zonefh $zoneline, "\n";
}

my @bothlist = (@dmrscanlist, @fmscanlist);
print $scanfh $scanheader, "\n";
foreach my $scanent (@bothlist) {
    print $scanfh $scanent, "\n";
}

# Close the file handles.
close $zonefh;
close $scanfh;
close $chanfh;
close $vkrdfh;

sub fmscanbuild {
    my $scanlistfm = shift;
    my $CallUufld  = shift;
    my ($index) = grep { $fmscanlist[$_] =~ /^$scanlistfm/ } 0 .. $#fmscanlist;
    my $newfmscan = sprintf('%s;%s', $fmscanlist[$index], $CallUufld);
    my $newfmscancnt = $fmscancnt[$index] + 1;
    if ($newfmscancnt >= $scanmax) {

        return 0;
    }
    else {
        splice(@fmscancnt,  $index, 1, $newfmscancnt);
        splice(@fmscanlist, $index, 1, $newfmscan);
        return 1;
    }
}

sub zonebuild {
    my $zone = shift;
    my $CallUufld  = shift;
    my $newzone = '';
    my $newzonecnt = '';
    if ( my ($index) = grep { $zonelist[$_] =~ /^$zone/ } 0 .. $#zonelist ) {
      $newzone = sprintf('%s;%s', $zonelist[$index], $CallUufld);
      $newzonecnt = $zonecnt[$index] + 1;
      if ($newzonecnt > $zonemax) {
        return 0;
      }
      else {
        splice(@zonecnt,  $index, 1, $newzonecnt);
        splice(@zonelist, $index, 1, $newzone);
        return 1;
      }
    } else {
      $newzone = sprintf('%s;%s', $zone, $CallUufld );
      push ( @zonelist , $newzone );
      push ( @zonecnt , 1 );
      return 1;
    }
}

sub by_tg {

    my ($anum) = $a =~ /(\d+)$/;
    my ($bnum) = $b =~ /(\d+)$/;
    ($anum || 0) <=> ($bnum || 0);
}

sub dvtxrx {    # Restructure for 8 digit view Most significant at front
    my $dmrlabtg  = shift;
    my $CallUufld = shift;
    my $callfld   = shift;
#    print STDERR "DEBUG CallUufld :", $CallUufld,":callfld:",$callfld,":dmrlabtg:",$dmrlabtg,":\n";

    my $callext1;
    my $callext2;
    my $txcontact1;
    my $txcontact2;
    my $rxgroup1;
    my $rxgroup2;
    my $scanlist1;
    my $scanlist2;

    my $prefix6 = sprintf("%.6s", $CallUufld);
    my $prefix3 = sprintf("%.3s", $prefix6);
    my $suffix4 = substr $prefix6, -4;
    my $suffix2 = substr $prefix6, -2;
    my $pwr     = 'H';
    my $txcontact = '';
    my $dmccode   = '1';

#print STDERR "DEBUG :p6 :", $prefix6,":p3:",$prefix3,":s4:",$suffix4,":s2:",$suffix2,":\n";

    my @dmrtginfo = split('-', $dmrlabtg);
    my $dmmix =
      ($dmrtginfo[0] eq 'm') ? 'm' : sprintf('s%s', $dmrtginfo[0]);
    my $dmrlab   = $dmrtginfo[1];
    my $dmrtg    = $dmrtginfo[2];
    my $dmrtgnum = $dmrtginfo[3];
    my $rxgroup = '';
#    print STDERR "DEBUG dmrlabtg:", $dmrlabtg, ":mix:", $dmmix, ":lab:",$dmrlab,":dmrtg:",$dmrtg,":\n";
if (grep { $callfld eq $_ } @Favopenspotrx) {
  $rxgroup = 'Openspot';
} else {
  $rxgroup = 'RXGR1'
}
    # rewrite CallUufld
    $CallUufld = $dmrtgnum;

    # rewrite pcallext here then fix longcall code later
    my $pcallext = sprintf('%s%s%s%s', (substr $dmmix, -1), $suffix2, $bandsufx, $prefix3);
    my $scanlistdm = sprintf('%sDMRS%s', $prefix6, $bandsufx);

    if ($callfld eq "WICENS") {
        $CallUufld = $prefix3;
        $pcallext  = $dmrlab;
        $dmccode   = '2';
        if ($prefix3 eq "KUR") { $dmccode = '1'; }
    }

    my ($tgindex) =
      grep { $tgnumuniq[$_] =~ /^$dmrtgnum/ } 0 .. $#tgnumuniq
      or die "HALTED:  TG $dmrtgnum not in tgnumuniq\n";

    #print "$txcontact\n";
    $txcontact = sprintf('%s', $tgnamuniq[$tgindex]);

#    print "DEBUG index DM :", $tgindex, ":numuniq:", $tgnumuniq[$tgindex],
#      ":nam:", $tgnamuniq[$tgindex], ":\n";
    my $longcall = sprintf('%s %s', $CallUufld, $pcallext);

    #        print "DEBUG before test :", $longcall,":\n";
    my $lenlongcall = length($longcall);
    my $lenpcallext = length($pcallext);
    if ($lenlongcall > 16) {
        print "\nDEBUG too long :", $longcall, ":", $pcallext, ":\n";
        my $templen = $lenlongcall - 15;
        $pcallext = substr $pcallext, 0, ($lenpcallext - $templen);
        print "DEBUG now :", $suffix4, ":\n";
    }

    # longcall must be unique
    if (grep { $longcall eq $_ } @longcalluniq) {
        print "\nChannel Name Exists :", $longcall, ": not adding\n\n";
        return ('exists', 0, $longcall, 0, 0, 0, 0);
    }
    else {
        #                  print "adding Channel :",$longcall,": added\n";
        push @longcalluniq, $longcall;

        #}

        if (!grep { $scanlistdm eq $_ } @ScanlistDUniq) {
            push @ScanlistDUniq, $scanlistdm;
            push @dmrscanlist,   $scanlistdm;
            push @dmrscancnt,    '0';
        }
        my $zonelistdm = sprintf('%sDMR', $prefix6 );

        if (!grep { $zonelistdm eq $_ } @ZonelistDUniq) {
            push @ZonelistDUniq, $zonelistdm;
            push @zonelist,   $zonelistdm;
            push @zonecnt,    '0';
        }

        my ($index) =
          grep { $dmrscanlist[$_] =~ /^$scanlistdm/ } 0 .. $#dmrscanlist;
        my $newdmrscan = sprintf('%s;%s', $dmrscanlist[$index], $longcall);
        my $newdmrscancnt = $dmrscancnt[$index] + 1;

        #       print "DEBUG newdmr ", $newdmrscan," :", $newdmrscancnt,"\n";
        if ($newdmrscancnt >= $scanmax) {
            print "too many entries for C $scanlistdm \n";
        }
        else {
            splice(@dmrscancnt,  $index, 1, $newdmrscancnt);
            splice(@dmrscanlist, $index, 1, $newdmrscan);
        }

        my ($zindex) =
          grep { $zonelist[$_] =~ /^$zonelistdm/ } 0 .. $#zonelist;
        my $newdmrzone = sprintf('%s;%s', $zonelist[$zindex], $longcall);
        my $newdmrzonecnt = $zonecnt[$zindex] + 1;

        #       print "DEBUG newdmr ", $newdmrscan," :", $newdmrscancnt,"\n";
        if ($newdmrzonecnt > $zonemax) {
            print "too many entries for zone $zonelistdm \n";
        }
        else {
            splice(@zonecnt,  $zindex, 1, $newdmrzonecnt);
            splice(@zonelist, $zindex, 1, $newdmrzone);
        }

        if ($dmmix eq 's1') {
            $callext1   = $pcallext;
            $callext2   = '';
            $txcontact1 = $txcontact;
            $txcontact2 = '';
            $rxgroup1   = $rxgroup;
            $rxgroup2   = '';
            $scanlist1 =
              $scanlistdm;    # DMR Channel name comes from callsign + callextn
            #
            $scanlist2 = '';
        }
        elsif ($dmmix eq 's2') {
            $callext1   = '';
            $callext2   = $pcallext;
            $txcontact1 = '';
            $txcontact2 = $txcontact;
            $rxgroup1   = '';
            $rxgroup2   = $rxgroup;
            $scanlist1  = '';
            $scanlist2  = $scanlistdm;
        }
        elsif ($dmmix eq '') {
            $callext1   = $pcallext;
            $callext2   = $pcallext;
            $txcontact1 = $txcontact;
            $txcontact2 = $txcontact;
            $rxgroup1   = $rxgroup;
            $rxgroup2   = $rxgroup;
            $scanlist1  = $scanlistdm;
            $scanlist2  = $scanlistdm;
        }
        elsif ($dmmix eq 'm') {
            $callext1   = $pcallext;
            $callext2   = $pcallext;
            $txcontact1 = $txcontact;
            $txcontact2 = $txcontact;
            $rxgroup1   = $rxgroup;
            $rxgroup2   = $rxgroup;
            $scanlist1  = $scanlistdm;
            $scanlist2  = $scanlistdm;
        }
        else {
            die "HALTED: $dmmix undefined for :$dmrlabtg \n";
        }

        #        my $callext = sprintf('%s;%s;',$callext1,$callext2);
        my $calltxrxscan = sprintf(
            '%s;%s;%s;%s;%s;%s;%s;%s;%s;',
            $callext1, $callext2, $txcontact1, $rxgroup1, $txcontact2,
            $rxgroup2, $pwr,      $scanlist1,  $scanlist2
        );

        #Contact,RXGp,CC,Privacy,PrivacyNum,TS
        my $newn0gsgscan = $scanlistdm;
        my $newn0gsgx    = sprintf("%s,%s,%s,None,1,%s",
            $txcontact, $rxgroup, $dmccode, $dmrtginfo[0]);

        return (
            $dmccode,   $dmmix,        $longcall, $calltxrxscan,
            $CallUufld, $newn0gsgscan, $newn0gsgx
        );
    }
}
exit
