#!/usr/bin/perl
# Simple DMR Contacts extraction.

# You might have to get this package from CPAN or PPM:
use strict;
use warnings;

use Text::CSV_XS;

our @FavmarcTG;
our @FavmarcWTG;
our @FavdmrpTG;
our @FavdmrefTG;
our @FavsimpTG;
our @FavwicenTG;
our @FavdmrpTGcontact;
our @Favwicencontact;
our @Favrxgrplist;
our @FavdmbmAPRS;
require My::Favourites;
my @bothTGlistb4 = (
    '1-9-LOCAL-9', @FavmarcTG, @FavdmrpTG, @FavmarcWTG, @FavdmrefTG, @FavdmrpTGcontact, @FavwicenTG,
    @FavsimpTG, @FavdmbmAPRS, @Favwicencontact
);
my @bothTGlist = sort by_tg @bothTGlistb4;
my @tgnumuniq;
my @tgnamuniq;
my $csv = Text::CSV_XS->new( { sep_char => ',' } );
my $zonename;
my $zoneline;

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
my $file2con4 = sprintf( "%s/rt82contacts.csv", $file2pre );
my $file2rxgr = sprintf( "%s/rxgroup.csv",            $file2pre );

open( my $con1fh, '>', $file2con1 ) or die "Could not open '$file2con1' $!\n";
open( my $con2fh, '>', $file2con2 ) or die "Could not open '$file2con2' $!\n";
open( my $con3fh, '>', $file2con3 ) or die "Could not open '$file2con3' $!\n";
open( my $con4fh, '>', $file2con4 ) or die "Could not open '$file2con4' $!\n";
open( my $rxgroupfh, '>', $file2rxgr )
  or die "Could not open '$file2rxgr' $!\n";

my $newhea1       = 'Name,radio_id';
my $newmd2017head = 'Contact Name,Call Type,Call ID,Call Receive Tone';
#
print $con3fh $newhea1,       "\n";
print $con4fh $newmd2017head, "\n";

#process talk Groups
#
foreach my $tmpTG (@bothTGlist) {
    my @tmpTGinfo = split( '-', $tmpTG );
    my $dmrlab    = $tmpTGinfo[1];
    my $dmrtg     = $tmpTGinfo[2];
    my $dmrtgnum  = $tmpTGinfo[3];
    my $dmrtgtext = sprintf( '%s %s', $dmrlab, $dmrtg );
    if ( grep { $dmrtgnum eq $_ } @tgnumuniq ) {
        print "\nTG contact exists :", $dmrtgnum, ":", $dmrtgtext,
          ": not adding\n\n";
    }
    else {
        print "adding TG contact :", $dmrtgnum, ":", $dmrtgtext, ": added\n";

        # Print the three items: ID, Callsign, Firstname
        print $con1fh join( ',', $dmrtgnum, $dmrtgtext, ' ' ), "\n";
        my $nogsgcon =
          sprintf( '"%s","%s","Group Call","No"', $dmrtgnum, $dmrtgtext );
        print $con2fh $nogsgcon, "\n";
        my $md2017con = sprintf( "%s,1,%s,0", $dmrtgtext, $dmrtgnum );
        print $con4fh $md2017con, "\n";
    }
    push @tgnumuniq, $dmrtgnum;
    push @tgnamuniq, $dmrtgtext;
}


# marc contact list private calls
my @fieldsrd = @{ $csv->getline($dmrwfh) };

while ( my $rowrd = $csv->getline($dmrwfh) ) {
    my %datard;
    @datard{@fieldsrd} = @$rowrd;
    my $fullname = $datard{'Name'};
    my ( $firstname, $lastname ) = split( ' ', $fullname );
    my $remarks = sprintf( "%.1s", $datard{'Remarks'} );

    # Print the three items: ID, Callsign, Firstname
    print $con1fh join( ',',
        $datard{'Radio ID'}, $datard{'Callsign'}, $firstname, $remarks ),
      "\n";
    my $nogsgcon = sprintf( '"%s","%s %s %s","Private Call","No"',
        $datard{'Radio ID'}, $datard{'Callsign'}, $firstname, $remarks );
    print $con2fh $nogsgcon, "\n";
    my $motocon = sprintf( "%s %s %s,%s",
        $datard{'Callsign'}, $firstname, $remarks, $datard{'Radio ID'} );
    print $con3fh $motocon, "\n";
    my $md2017con = sprintf( "%s %s %s,2,%s,0",
        $datard{'Callsign'}, $firstname, $remarks, $datard{'Radio ID'} );
    print $con4fh $md2017con, "\n";
}

# Create Group lists

my $rxgrpname = '';
my $rxgrpline = '';
my $tmpindex  = 0;
my $tmpcnt    = $tmpindex;
my @rxgrplist;

foreach my $scanent (@Favrxgrplist) {
    print "scanent $scanent\n";
    my @tmpgrent = split( ';', $scanent );
    foreach my $tmpgrx (@tmpgrent) {

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
close $rxgroupfh;


sub by_tg {

  my ( $anum ) = $a =~ /(\d+)$/;
  my ( $bnum ) = $b =~ /(\d+)$/;
  ( $anum || 0 ) <=> ( $bnum || 0 );
}
