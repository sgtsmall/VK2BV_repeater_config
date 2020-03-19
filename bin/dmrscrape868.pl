#!/usr/bin/perl
# Simple DMR Contacts extraction.

# You might have to get this package from CPAN or PPM:
use strict;
use warnings;

use Text::CSV_XS;

require lib::Favourites;

our @FavmarcTG;
our @FavmarcWTG;
our @FavdmrpTG;
our @FavdmrefTG;
our @FavdmrOspotTG;
our @FavsimpTG;
our @FavwicenTG;
our @FavdmrpTGcontact;
our @FavmmdvmDMRGTB;
our @FavmmdvmDMRGTPB;
our @FavmmdvmDMRGTD;
our @FavmmdvmDMRGTPD;
our @FavmmdvmDMRGTX;
our @FavmmdvmDMRGTPX;
our @FavsharkDMRGTB;
our @FavsharkDMRGTPB;
our @FavsharkDMRGTD;
our @FavsharkDMRGTPD;
our @FavsharkDMRGTX;
our @FavsharkDMRGTPX;
our @Favwicencontact;
our @Favrxgrplist;
our @FavdmbmAPRS;
my @bothTGlistb4 = (
    '1-9-LOCAL-9', @FavmarcTG, @FavdmrpTG, @FavmarcWTG, @FavdmrefTG, @FavdmrpTGcontact, @FavwicenTG, @FavsimpTG,
    @FavdmbmAPRS, @FavdmrOspotTG,
    @FavmmdvmDMRGTB, @FavmmdvmDMRGTD, @FavmmdvmDMRGTX,
    @FavsharkDMRGTB, @FavsharkDMRGTD, @FavsharkDMRGTX
);
my @bothTGlist = sort by_tg @bothTGlistb4;
my @bothTPlistb4 = ( @Favwicencontact,
  @FavmmdvmDMRGTPB, @FavmmdvmDMRGTPD, @FavmmdvmDMRGTPX,
  @FavsharkDMRGTPB, @FavsharkDMRGTPD, @FavsharkDMRGTPX);
my @bothTPlist = sort by_tg @bothTPlistb4;
my @tgnumuniq;
my @tgnamuniq;
my $csv = Text::CSV_XS->new( { sep_char => ',' } );
my $zonename;
my $zoneline;
my $seq = -1;

#open userwork.dat
my $filei1 = $ARGV[0]
  or die "Need userworka.dat file on the command line\n";

# open vkrepdmrxx.csv
my $file2pre = $ARGV[1]
  or die "Need directory for output e.g.(output/dmr) on the command line\n";

#Open Simplex-std file
open( my $dmrwfh, '<', $filei1 ) or die "Could not open '$filei1' $!\n";

#open output file
my $file2con1 = sprintf( "%s/868contacts.csv",           $file2pre );
my $file2rxgr = sprintf( "%s/868rxgroup.csv",            $file2pre );
my $file2tgr = sprintf( "%s/868tgroup.csv",            $file2pre );

open( my $con1fh, '>', $file2con1 ) or die "Could not open '$file2con1' $!\n";
open( my $rxgroupfh, '>', $file2rxgr )
  or die "Could not open '$file2rxgr' $!\n";
open( my $tgroupfh, '>', $file2tgr )
  or die "Could not open '$file2tgr' $!\n";

my $a868head100k   =  '"Radio ID","Callsign","Name","City","State","Country","Remarks","Call Type","Call Alert"';
#
print $con1fh $a868head100k, "\n";

my $a868headTG   =  '"No.","Radio ID","Name","Call Type","Call Alert"';
#
print $tgroupfh $a868headTG, "\n";

#process talk Groups
#
my $tgseq = 1;
foreach my $tmpTG (@bothTGlist) {
    my @tmpTGinfo = split( '-', $tmpTG );
    my $dmrlab    = $tmpTGinfo[1];
    my $dmrtg     = $tmpTGinfo[2];
    my $dmrtgnum  = $tmpTGinfo[3];
    my $dmrtgtext = sprintf( '%s %s', $dmrlab, $dmrtg );
    if ( grep { $dmrtgnum eq $_ } @tgnumuniq ) {
        print "TG contact numb exists :", $dmrtgnum, ":", $dmrtgtext,
          ": not adding\n";
    } elsif ( grep { $dmrtgtext eq $_ } @tgnamuniq ) {
      print "TG contact name exists :", $dmrtgnum, ":", $dmrtgtext,
        ": not adding\n";
    } else {
#      my $a868con =
#          sprintf( '"%s","%s","","","","","",""', $dmrtgnum, $dmrtgtext );
#      print $con1fh $a868con, "\n";
	my $a868TG =
          sprintf( '"%s","%s","%s","Group Call","None"', $tgseq, $dmrtgnum, $dmrtgtext );
      print $tgroupfh $a868TG, "\n";
	$tgseq += 1;
    }
    push @tgnumuniq, $dmrtgnum;
    push @tgnamuniq, $dmrtgtext;
}
#process private calls for Hotspot
#
foreach my $tmpTP (@bothTPlist) {
    my @tmpTPinfo = split( '-', $tmpTP );
    my $dmrlab    = $tmpTPinfo[1];
    my $dmrtg     = $tmpTPinfo[2];
    my $dmrtgnum  = $tmpTPinfo[3];
    my $dmrtgtext = sprintf( '%s %s', $dmrlab, $dmrtg );
    if ( grep { $dmrtgnum eq $_ } @tgnumuniq ) {
        print "TG contact numb exists :", $dmrtgnum, ":", $dmrtgtext,
          ": not adding\n";
    } elsif ( grep { $dmrtgtext eq $_ } @tgnamuniq ) {
        print "TG contact name exists :", $dmrtgnum, ":", $dmrtgtext,
          ": not adding\n";
    }
    else {
 #     my $a868con =
 #          sprintf( '"%s","%s","","","","","",""', $dmrtgnum, $dmrtgtext );
 #     print $con1fh $a868con, "\n";
	my $a868TG =
          sprintf( '"%s","%s","%s","Private Call","None"', $tgseq, $dmrtgnum, $dmrtgtext );
      print $tgroupfh $a868TG, "\n";
	$tgseq += 1;
    }
    push @tgnumuniq, $dmrtgnum;
    push @tgnamuniq, $dmrtgtext;
}

my @fieldsrd = @{ $csv->getline($dmrwfh) };

while ( my $rowrd = $csv->getline($dmrwfh) ) {
    $seq += 1;
    my %datard;
    @datard{@fieldsrd} = @$rowrd;
    my $a868con =    sprintf( '"%s","%s","%s %s","%s","%s","%s","%s","Private Call","None"',
        $datard{'Radio ID'}, $datard{'Callsign'}, $datard{'FirstName'}, $datard{'LastName'},
	  $datard{'City'},$datard{'State'},$datard{'Country'},$datard{'Remarks'} );
    print $con1fh $a868con, "\n";
}



# Create RxGroup lists
my $rxgrpname = '';
my $rxgrpline = '';
my $rxgrpnumb = '';
my $tmpindex  = 0;
my $tmpcnt    = $tmpindex;
my $a868headgrp   = '"No.","Group Name","Contact","Contact TG/DMR ID"';

print $rxgroupfh $a868headgrp , "\n";
my @rxgrplist;
my $rxcount = 0;
foreach my $scanent (@Favrxgrplist) {
  my $rxgrpname = '';
  my $rxgrpline = '';
  my $rxgrpnumb = '';
  $rxcount += 1;
#DEBUG   print "scanent $scanent\n";
  my @tmprxgrent = split( ';', $scanent );
  foreach my $tmpgrx (@tmprxgrent) {
#DEBUG     print "tmpgrx $tmpgrx\n";
    #        print "tmpfmx $tmpfmx C $tmpcnt I $tmpindex \n" ;
    if ( $tmpcnt < 65 ) {
      if ( $tmpcnt == 0 ) {
        if ( $tmpindex == 0 ) {
          $rxgrpname = sprintf( '%.16s', $tmpgrx );
        #  $rxgrpline = sprintf( '"%s",',   $rxgrpname );
          $tmpcnt += 1;
#print STDERR "DEBUG $rxgrpline \n"
        }
      }
      else {
        my ($tgindex) =
        grep { $tgnumuniq[$_] =~ /^$tmpgrx/ } 0 .. $#tgnumuniq;
        my $txcontact = sprintf( '%s', $tgnamuniq[$tgindex] );
	  my $txcontnum = sprintf( '%s', $tgnumuniq[$tgindex] );
        if ( $tmpcnt == 1) {
          $rxgrpline = sprintf( '%s',  $txcontact );
	    $rxgrpnumb = sprintf( '"%s"', $txcontnum );
        } else{
           $rxgrpline = sprintf( '%s|%s', $rxgrpline, $txcontact );
           $rxgrpnumb = sprintf( '%s|"%s"', $rxgrpnumb, $txcontnum );
        }
	  $tmpcnt += 1;
    #    print STDERR "DEBUG $rxgrpline \n"
      }
    }
    $tmpindex += 1;
  }
#  while ( $tmpcnt < 65 ) {
#    $rxgrpline = sprintf( '%s;', $rxgrpline );
#    $tmpcnt += 1;
#}
my  $formstring = sprintf( '"%s","%s","%s","%s"', $rxcount,$rxgrpname,$rxgrpline, $rxgrpnumb );
  print $rxgroupfh $formstring ,"\n";
#DEBUG   print "rxgrpline $rxgrpline\n";
  $tmpindex = 0;
  $tmpcnt = $tmpindex;
  $rxgrpline = '';
  $rxgrpnumb = '';
}

close $con1fh;
close $rxgroupfh;
close $tgroupfh;

sub by_tg {

  my ( $anum ) = $a =~ /(\d+)$/;
  my ( $bnum ) = $b =~ /(\d+)$/;
  ( $anum || 0 ) <=> ( $bnum || 0 );
}
