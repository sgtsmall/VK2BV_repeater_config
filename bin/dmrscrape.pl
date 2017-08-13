#!/usr/bin/perl
# Simple DMR Contacts extraction.

# You might have to get this package from CPAN or PPM:
use strict;
use warnings;

use Text::CSV_XS;

our @FavmarcTG;
our @FavdmrpTG;
our @FavsimpTG;
our @FavwicenTG;
require My::Favourites;
my @bothTGlist = ( '1-LOCAL-TG9-9',@FavmarcTG,@FavdmrpTG,@FavwicenTG,@FavsimpTG);
my @tgnumuniq ;
my $csv = Text::CSV_XS->new({sep_char => ','});

#open userwork.dat
my $filei1 = $ARGV[0]
  or die "Need userwork.dat file on the command line\n";

# open vkrepdmrxx.csv
my $file2pre = $ARGV[1] or die "Need directory for output e.g.(output/dmr) on the command line\n";

#Open Simplex-std file
open(my $dmrwfh, '<', $filei1) or die "Could not open '$filei1' $!\n";

#open output file
my $file2con1 = sprintf("%s/contacts.csv", $file2pre);
my $file2con2 = sprintf("%s/cont-n0gsg.csv", $file2pre);
my $file2con3 = sprintf("%s/motocontacts.csv", $file2pre);
my $file2con4 = sprintf("%s/md2017chancontacts.csv", $file2pre);

open(my $con1fh, '>', $file2con1) or die "Could not open '$file2con1' $!\n";
open(my $con2fh, '>', $file2con2) or die "Could not open '$file2con2' $!\n";
open(my $con3fh, '>', $file2con3) or die "Could not open '$file2con3' $!\n";
open(my $con4fh, '>', $file2con4) or die "Could not open '$file2con4' $!\n";

my $newhea1 = 'Name,radio_id';
#
    print $con3fh $newhea1, "\n";
#process talk Groups
#
foreach my $tmpTG (@bothTGlist) {
    my @tmpTGinfo = split('-',$tmpTG);
    my $dmrlab = $tmpTGinfo[1];
    my $dmrtg = $tmpTGinfo[2];
    my $dmrtgnum = $tmpTGinfo[3];
	my $dmrtgtext = sprintf('%s %s',$dmrlab,$dmrtg);
    if (grep { $dmrtgnum eq $_ } @tgnumuniq ) {
        print "\nTG contact exists :",$dmrtgnum,":",$dmrtgtext,": not adding\n\n";
    } else {
      print "adding TG contact :",$dmrtgnum,":",$dmrtgtext,": added\n";
    # Print the three items: ID, Callsign, Firstname
        print $con1fh join (',', $dmrtgnum, $dmrtgtext,' '), "\n";
        my $nogsgcon = sprintf('"%s","%s","Group Call","No"', $dmrtgnum, $dmrtgtext);
        print $con2fh $nogsgcon,"\n";
        my $md2017con = sprintf("%s,1,%s,0", $dmrtgtext, $dmrtgnum);
        print $con4fh $md2017con,"\n";}
        push @tgnumuniq, $dmrtgnum ;
}


# marc contact list
my @fieldsrd = @{$csv->getline($dmrwfh)};

while (my $rowrd = $csv->getline($dmrwfh)) {
    my %datard;
    @datard{@fieldsrd} = @$rowrd;
    my $fullname = $datard{'Name'};
	my ($firstname, $lastname) = split (' ', $fullname);
    my $remarks = sprintf("%.1s", $datard{'Remarks'});

    # Print the three items: ID, Callsign, Firstname
	print $con1fh join (',', $datard{'Radio ID'}, $datard{'Callsign'}, $firstname, $remarks), "\n";
    my $nogsgcon = sprintf('"%s","%s %s %s","Private Call","No"', $datard{'Radio ID'}, $datard{'Callsign'}, $firstname, $remarks);
    print $con2fh $nogsgcon,"\n";
    my $motocon = sprintf("%s %s %s,%s", $datard{'Callsign'}, $firstname, $remarks, $datard{'Radio ID'});
    print $con3fh $motocon,"\n";
    my $md2017con = sprintf("%s %s %s,2,%s,0", $datard{'Callsign'}, $firstname, $remarks, $datard{'Radio ID'});
    print $con4fh $md2017con,"\n";
    }
close $con1fh;
close $con2fh;
