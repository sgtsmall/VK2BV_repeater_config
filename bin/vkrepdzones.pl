#!/usr/bin/perl

=pod
=head1 NAME
vkrepdzones.pl - merge uhf and vhf for rt82
=head1 USAGE
    vkrepdzones.pl uhffile vhffile outputfolder/prefile
=head1 DESCRIPTION
creates new zonefile newuhf newvhf that does something
=head1 TO DO
Improve the DESCRIPTION
=cut

use strict;
use warnings;
use feature 'say';
no warnings 'experimental::smartmatch';

use File::Slurp;
use Text::CSV_XS;
use Pod::Usage;
use List::MoreUtils qw(first_index);

our @Favourft;
require lib::Favourites;

#use List::Util qw(first);
#use Scalar::Util qw(looks_like_number);

my $csv = Text::CSV_XS->new({sep_char => ';', binary => 1, eol => $/ });

pod2usage(-verbose => 99, -sections => [
    qw(DESCRIPTION ) ] ) unless @ARGV;

my ($filei1, $filei2, $file2pre) = @ARGV;
pod2usage("1st CSV file '$filei1' not found.") unless -f $filei1;
pod2usage("2nd CSV file '$filei2' not found.") unless -f $filei2;


#open vkrepdir.csv
#my $filei1 = $ARGV[0] or die "Need uhf zone file on the command line\n";

#open vkrepstd.csv
#my $filei2 = $ARGV[1]
#  or die "Need vhf zone file on the command line\n";

# open vkrepout.csv
#my $file2pre = $ARGV[2]
#  or die "HALTED: Need directory for output e.g.(output/dmr) on the command line\n";

my $cnt  = 2;
my $call = '';

#my $head = '';
#my $sort = '0Sort';
#my $type = '';
#my $offdata = '';
#my @kmllist ;
my $cntfld     = '';

# Load arrays with file contents
#Open input file
open(my $uhfzfh, '<', $filei1) or die "Could not open '$filei1' $!\n";

#Open Simplex-std file
open(my $vhfzfh, '<', $filei2) or die "Could not open '$filei2' $!\n";

my $fileouhf = sprintf( "%snewuhf.csv", $file2pre );
my $fileovhf = sprintf( "%snewvhf.csv", $file2pre );

#open output files
open( my $uhfznfh, '>', $fileouhf ) or die "HALTED: Could not open '$fileouhf' $!\n";
open( my $vhfznfh, '>', $fileovhf ) or die "HALTED: Could not open '$fileovhf' $!\n";


#read the header line of the main input
my @fieldsrdu = @{$csv->getline($uhfzfh)};
# output this header
print $uhfznfh join(';', @fieldsrdu), "\n";
#read the header line of the local input
#my @fieldsrdv = @{$csv->getline($vhfzfh)};
#my @fieldsrd = @{$csv->getline($vhfzfh)};
print $vhfznfh join(';', @fieldsrdu), "\n";


# Read each line from the CSV file, and store it in @rows
my @allzone;
#my @alluzone;
#my @allvzone;
# repeater list
#say "Starting uhf";
while (my $rowrd = $csv->getline($uhfzfh)) {
  my %datard;
  @datard{@fieldsrdu} = @$rowrd;
#  say "added $datard{'ZoneList'}";
  push @allzone, $datard{'ZoneList'};

}
#say "Finished uhf";

#say "Starting vhf";
while (my $rowrd = $csv->getline($vhfzfh)) {
  my %datard;
  @datard{@fieldsrdu} = @$rowrd;
  if ( grep { $datard{'ZoneList'} eq $_ } @allzone ) {

  }
  else {
#    say "added $datard{'ZoneList'}";
    push @allzone, $datard{'ZoneList'};
  }
}
#say "Finished vhf";
close $uhfzfh;
close $vhfzfh;

#Open input file
open($uhfzfh, '<', $filei1) or die "Could not open '$filei1' $!\n";

#Open Simplex-std file
open($vhfzfh, '<', $filei2) or die "Could not open '$filei2' $!\n";


my @alluzone = read_file ($uhfzfh);
my @allvzone = read_file ($vhfzfh);

#my $debugvhf;
#foreach $debugvhf (@allvzone) {
#  say $debugvhf;
#}

my $zoneline;
foreach $zoneline (@allzone) {

#say  $zoneline;
if ( $zoneline =~ "ZoneList" ) {
  next;
}

  my $uidx = first_index { $_ =~ /^$zoneline/ } @alluzone;
  if ( $uidx gt 0  ) {
#    say "found u ";
    print $uhfznfh $alluzone[$uidx] ;
  } else {
    say $uhfznfh "$zoneline;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;" ;
  }

  my $vidx = first_index { $_ =~ /^$zoneline/ } @allvzone;
  if ( $vidx gt 0  ) {
#    say "found v ";
    print $vhfznfh $allvzone[$vidx] ;
  } else {
    say $vhfznfh "$zoneline;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;" ;
  }
}



# Close the file handle.
close $uhfzfh;
close $vhfzfh;
close $uhfznfh;
close $vhfznfh;
