#!/opt/local/bin/perl
#
# merges wia and local data
#

use strict;
use warnings;
use feature 'say';
no warnings 'experimental::smartmatch';

use File::Slurp;
use Text::CSV_XS;
use List::MoreUtils qw(first_index);

our @Favourft;
require My::Favourites;

#use List::Util qw(first);
#use Scalar::Util qw(looks_like_number);

my $csv = Text::CSV_XS->new({sep_char => ';', binary => 1, eol => $/ });

#open vkrepdir.csv
my $filei1 = $ARGV[0] or die "Need uhf scan file on the command line\n";

#open vkrepstd.csv
my $filei2 = $ARGV[1]
  or die "Need vhf scan file on the command line\n";

# open vkrepout.csv
my $file2pre = $ARGV[2]
  or die "HALTED: Need directory for output e.g.(output/dmr) on the command line\n";

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
open(my $uhfsfh, '<', $filei1) or die "Could not open '$filei1' $!\n";

#Open Simplex-std file
open(my $vhfsfh, '<', $filei2) or die "Could not open '$filei2' $!\n";

my $fileouhf = sprintf( "%snewsuhf.csv", $file2pre );
my $fileovhf = sprintf( "%snewsvhf.csv", $file2pre );

#open output files
open( my $uhfsnfh, '>', $fileouhf ) or die "HALTED: Could not open '$fileouhf' $!\n";
open( my $vhfsnfh, '>', $fileovhf ) or die "HALTED: Could not open '$fileovhf' $!\n";


#read the header line of the main input
my @fieldsrdu = @{$csv->getline($uhfsfh)};
# output this header
print $uhfsnfh join(';', @fieldsrdu), "\n";
#read the header line of the local input
#my @fieldsrdv = @{$csv->getline($vhfsfh)};
#my @fieldsrd = @{$csv->getline($vhfsfh)};
print $vhfsnfh join(';', @fieldsrdu), "\n";


# Read each line from the CSV file, and store it in @rows
my @allscan;
#my @alluscan;
#my @allvscan;
# repeater list
#say "Starting uhf";
while (my $rowrd = $csv->getline($uhfsfh)) {
  my %datard;
  @datard{@fieldsrdu} = @$rowrd;
#  say "added $datard{'ScanList'}";
  push @allscan, $datard{'ScanList'};

}
#say "Finished uhf";

#say "Starting vhf";
while (my $rowrd = $csv->getline($vhfsfh)) {
  my %datard;
  @datard{@fieldsrdu} = @$rowrd;
  if ( grep { $datard{'ScanList'} eq $_ } @allscan ) {
  }
  else {
#    say "added $datard{'ScanList'}";
    push @allscan, $datard{'ScanList'};
  }
}
#say "Finished vhf";
close $uhfsfh;
close $vhfsfh;

#Open input file
open($uhfsfh, '<', $filei1) or die "Could not open '$filei1' $!\n";

#Open Simplex-std file
open($vhfsfh, '<', $filei2) or die "Could not open '$filei2' $!\n";


my @alluscan = read_file ($uhfsfh);
my @allvscan = read_file ($vhfsfh);

#my $debugvhf;
#foreach $debugvhf (@allvscan) {
#  say $debugvhf;
#}

my $scanline;
foreach $scanline (@allscan) {

#say  $scanline;
if ( $scanline =~ "ScanList" ) {
  next;
}

  my $uidx = first_index { $_ =~ /^$scanline/ } @alluscan;
  if ( $uidx gt 0  ) {
#    say "found u ";
    print $uhfsnfh @alluscan[$uidx] ;
  } else {
    say $uhfsnfh "$scanline;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;" ;
  }

  my $vidx = first_index { $_ =~ /^$scanline/ } @allvscan;
  if ( $vidx gt 0  ) {
#    say "found v ";
    print $vhfsnfh @allvscan[$vidx] ;
  } else {
    say $vhfsnfh "$scanline;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;" ;
  }
}



# Close the file handle.
close $uhfsfh;
close $vhfsfh;
close $uhfsnfh;
close $vhfsnfh;
