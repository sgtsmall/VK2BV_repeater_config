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
  or die "Need userwork.dat file on the command line\n";

# open vkrepdmrxx.csv
my $file2pre = $ARGV[1]
  or die "Need directory for output e.g.(output/dmr) on the command line\n";

#Open Simplex-std file
open( my $dmrwfh, '<', $filei1 ) or die "Could not open '$filei1' $!\n";

#open output file
my $file2con1 = sprintf( "%s/contacts.csv",           $file2pre );
my $file2con2 = sprintf( "%s/cont-n0gsg.csv",         $file2pre );
my $file2con3 = sprintf( "%s/motocontacts.csv",       $file2pre );
my $file2con4 = sprintf( "%s/rt82contacts.csv",       $file2pre );
my $file2con5 = sprintf( "%s/rt82con10k.csv",         $file2pre );
my $file2rxgr = sprintf( "%s/rxgroup.csv",            $file2pre );
my $file2gd77 = sprintf( "%s/gd77cont.csv",            $file2pre );

open( my $con1fh, '>', $file2con1 ) or die "Could not open '$file2con1' $!\n";
open( my $con2fh, '>', $file2con2 ) or die "Could not open '$file2con2' $!\n";
open( my $con3fh, '>', $file2con3 ) or die "Could not open '$file2con3' $!\n";
open( my $con4fh, '>', $file2con4 ) or die "Could not open '$file2con4' $!\n";
open( my $con5fh, '>', $file2con5 ) or die "Could not open '$file2con5' $!\n";
open( my $con6fh, '>', $file2gd77 ) or die "Could not open '$file2gd77' $!\n";
open( my $rxgroupfh, '>', $file2rxgr )
  or die "Could not open '$file2rxgr' $!\n";

my $newhea1       = 'Name,radio_id';
my $newmd2017head = 'Contact Name,Call Type,Call ID,Call Receive Tone';
my $rt82head10k   =  'Radio ID,CallSign,Name,NickName,City,State,Country,';
my $gd77head = 'Number,Name,Call ID,Type,Ring Style,Call Receive Tone';
#0,Contact1,00000001,Group Call,On,None'
#
print $con3fh $newhea1,       "\n";
print $con4fh $newmd2017head, "\n";
print $con6fh $gd77head, "\n";

#process talk Groups
#
foreach my $tmpTG (@bothTGlist) {
    my @tmpTGinfo = split( '-', $tmpTG );
    my $dmrlab    = $tmpTGinfo[1];
    my $dmrtg     = $tmpTGinfo[2];
    my $dmrtgnum  = $tmpTGinfo[3];
    my $dmrtgtext = sprintf( '%s %s', $dmrlab, $dmrtg );
    if ( grep { $dmrtgnum.'G' eq $_ } @tgnumuniq ) {
        print "TG contact numb exists :", $dmrtgnum, ":", $dmrtgtext,
          ": not adding\n";
    } elsif ( grep { $dmrtgtext eq $_ } @tgnamuniq ) {
      print "TG contact name exists :", $dmrtgnum, ":", $dmrtgtext,
        ": not adding\n";
    } else {
    #    print "adding TG contact :", $dmrtgnum, ":", $dmrtgtext, ": added\n";
    $seq += 1;
        # Print the three items: ID, Callsign, Firstname
        print $con1fh join( ',', $dmrtgnum, $dmrtgtext, ' ' ), "\n";
        my $nogsgcon =
          sprintf( '"%s","%s","Group Call","No"', $dmrtgnum, $dmrtgtext );

        print $con2fh $nogsgcon, "\n";

        my $md2017con = sprintf( "%s,1,%s,0", $dmrtgtext, $dmrtgnum );
        print $con4fh $md2017con, "\n";

        my $gd77con = sprintf( "%s,%s,%s,Group Call,On,None",
            $seq, $dmrtgtext, $dmrtgnum );
        print $con6fh $gd77con, "\n";
    }
    push @tgnumuniq, $dmrtgnum.'G';
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
    if ( grep { $dmrtgnum.'P' eq $_ } @tgnumuniq ) {
        print "TG contact numb exists :", $dmrtgnum, ":", $dmrtgtext,
          ": not adding\n";
    } elsif ( grep { $dmrtgtext eq $_ } @tgnamuniq ) {
        print "TG contact name exists :", $dmrtgnum, ":", $dmrtgtext,
          ": not adding\n";
    }
    else {
    #    print "adding TG contact :", $dmrtgnum, ":", $dmrtgtext, ": added\n";
    $seq += 1;
        # Print the three items: ID, Callsign, Firstname
        print $con1fh join( ',', $dmrtgnum, $dmrtgtext, ' ' ), "\n";
        my $nogsgcon =
          sprintf( '"%s","%s","Private Call","No"', $dmrtgnum, $dmrtgtext );
        print $con2fh $nogsgcon, "\n";
        my $md2017con = sprintf( "%s,2,%s,0", $dmrtgtext, $dmrtgnum );
        print $con4fh $md2017con, "\n";
        my $gd77con = sprintf( "%s,%s,%s,Private Call,On,None",
            $seq, $dmrtgtext, $dmrtgnum );
        print $con6fh $gd77con, "\n";
    }
    push @tgnumuniq, $dmrtgnum.'P';
    push @tgnamuniq, $dmrtgtext;
}

# marc contact list private calls
my @fieldsrd = @{ $csv->getline($dmrwfh) };

while ( my $rowrd = $csv->getline($dmrwfh) ) {
    $seq += 1;
    my %datard;
    @datard{@fieldsrd} = @$rowrd;
#    my $fullname = $datard{'Name'};
#    my ( $firstname, $lastname ) = split( ' ', $fullname );
    my $remarks = sprintf( "%.1s", $datard{'Remarks'} );
  #  print "DEBUG: $fullname $datard{'Radio ID'} \n";
    # Print the three items: ID, Callsign, Firstname
    print $con1fh join( ',',
        $datard{'Radio ID'}, $datard{'Callsign'}, $datard{'FirstName'}, $remarks ),"\n";
    my $nogsgcon = sprintf( '"%s","%s %s","Private Call","No"',
        $datard{'Radio ID'}, $datard{'Callsign'}, $datard{'FirstName'} );
    print $con2fh $nogsgcon, "\n";
    my $motocon = sprintf( "%s %s %s,%s",
        $datard{'Callsign'}, $datard{'FirstName'}, $remarks, $datard{'Radio ID'} );
    print $con3fh $motocon, "\n";
    my $md2017con = sprintf( "%s %s %s,2,%s,0",
        $datard{'Callsign'}, $datard{'FirstName'}, $remarks, $datard{'Radio ID'} );
    print $con4fh $md2017con, "\n";
    my $gd77con = sprintf( "%s,%s,%s,Private Call,On,None",
        $seq, $datard{'Callsign'}, $datard{'Radio ID'} );
    print $con6fh $gd77con, "\n";

}
#0,Contact1,00000001,Group Call,On,None'

# Create Group lists
my $rxgrpname = '';
my $rxgrpline = '';
my $tmpindex  = 0;
my $tmpcnt    = $tmpindex;

my @rxgrplist;

foreach my $scanent (@Favrxgrplist) {
  my $rxgrpname = '';
  my $rxgrpline = '';

#DEBUG   print "scanent $scanent\n";
  my @tmprxgrent = split( ';', $scanent );
  foreach my $tmpgrx (@tmprxgrent) {
#DEBUG     print "tmpgrx $tmpgrx\n";
    #        print "tmpfmx $tmpfmx C $tmpcnt I $tmpindex \n" ;
    if ( $tmpcnt < 65 ) {
      if ( $tmpcnt == 0 ) {
        if ( $tmpindex == 0 ) {
          $rxgrpname = sprintf( '%.9s', $tmpgrx );
          $rxgrpline = sprintf( '%s',   $rxgrpname );
          $tmpcnt += 1;
        }
      }
      else {
        my ($tgindex) =
        grep { $tgnumuniq[$_] =~ /^$tmpgrx/ } 0 .. $#tgnumuniq;
        my $txcontact = sprintf( '%s', $tgnamuniq[$tgindex] );
        $rxgrpline = sprintf( '%s;%s', $rxgrpline, $txcontact );
        $tmpcnt += 1;
      }
    }
    $tmpindex += 1;
  }
  while ( $tmpcnt < 65 ) {
    $rxgrpline = sprintf( '%s;', $rxgrpline );
    $tmpcnt += 1;
  }
  push @rxgrplist, $rxgrpline;
#DEBUG   print "rxgrpline $rxgrpline\n";
  $tmpindex = 0;
  $tmpcnt = $tmpindex;
  $rxgrpline = '';
}

$tmpcnt = 1;
my $rxgheader = 'RxGroups';
while ( $tmpcnt < 65 ) {
    $rxgheader = sprintf( '%s;tg%i', $rxgheader, $tmpcnt );
    $tmpcnt += 1;
}
print $rxgroupfh $rxgheader, "\n";
foreach $rxgrpline (@rxgrplist) {
    print $rxgroupfh $rxgrpline, "\n";
}
close $con1fh;
close $con2fh;
close $con3fh;
close $con4fh;
close $con5fh;
close $con6fh;
close $rxgroupfh;


sub by_tg {

  my ( $anum ) = $a =~ /(\d+)$/;
  my ( $bnum ) = $b =~ /(\d+)$/;
  ( $anum || 0 ) <=> ( $bnum || 0 );
}
