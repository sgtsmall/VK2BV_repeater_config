#!/opt/local/bin/perl
#
# Generate a local_shortdev from lat, long
#
#CALL_SIGN,LATITUDE,LONGITUDE,NAME,STATE,POSTCODE,SITE_PRECISION,ELEVATION


use strict;
use warnings;
no warnings 'experimental::smartmatch';


use Text::CSV_XS;
use Text::CSV::Hashify;
use Parse::CSV;
use Ham::Locator;
use Geo::Direction::Distance;


require My::Favourites;

my $csv = Text::CSV_XS->new({sep_char => ',',eol => "\n"});

#my $devdet = 'work/device_details.csv';
#my $sitinf = 'work/site.csv';
#open shinytemp.csv
#SITE_ID,LATITUDE,LONGITUDE,NAME,STATE,LICENSING_AREA_ID,POSTCODE,SITE_PRECISION,ELEVATION,HCIS_L2
#my $sitex = Text::CSV::Hashify->new ( {
#    file => $sitinf,
#    format => 'hoh',
#    key => 'SITE_ID',
#}
#);
my $lltomh = Ham::Locator->new();

# open output/s   then apend shiny later
my $file1pre = $ARGV[0] or die "Need to merge CSV file on the command line\n";
my $file2pre = $ARGV[1] or die "Need to merge CSV file on the command line\n";


my @CallUuniq;

my $cnt = 0;
my $call       = '';
my $cntfld     = '';
my $utcoffset  = '';
my @grpnum     = qw{3 22 23 24};

# define points for distance direction
#VK3RCG
my @fromsydlatlng = (-33.8677935,151.2077336);

#VK3RCC
my @frommellatlng = (-37.81382239, 144.9694815);

# Tamborine in SE Queensland
my @fromtmblatlng = (-27.8702329, 153.0609623);

# calculate location for west point (katoomba)
my ($dir, $dist) = (281.000, 85000.00);
my @frommtnlatlng = dirdist2latlng(@fromsydlatlng, $dir, $dist);

# set txpower to 5 as default;
my $txpower = '5';

# bearing North-North-East (Coastal North) 22.5
# bearing South-South-West (Coastal South) 202.5
# Load arrays with file contents
#Open input file
open(my $localfh, '<', sprintf("%s", $file1pre)) or die "Could not open '$file1pre' $!\n";

#open output file
open(my $outfh, '>', sprintf("%s", $file2pre)) or die "Could not open '$file2pre' $!\n";
#

my @CallUniq;
my $siteline;
my $distline;
my $newhea1 = 'CALL_SIGN,LATITUDE,LONGITUDE,NAME,STATE,POSTCODE,SITE_PRECISION,';
my $newhea2 = 'ELEVATION,maidenhead,distsyd,dirsyd,dirkat,distmel,disttmb,txpower,bank';
my $newhead = sprintf("%s%s",$newhea1,$newhea2);

if ($csv->parse($newhead)) {
    print $outfh $csv->string, "\n";
} else {
    print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
    $csv->error_diag();
}


#read the header line of the main input
my $fields = $csv->getline($localfh);

my @fields = @{$fields};
# Read each line from the CSV file, and store it in @rows
my @rows;

while (my $row = $csv->getline($localfh)) {
    my %data;
    @data{@fields} = @$row;    # This is a hash slice
    if ($data{'CALL_SIGN'} =~ /(^VK[123456789]R)(.{2,})/ ){
      if (! grep { $data{'CALL_SIGN'} eq $_ } @CallUniq) {
        push @CallUniq, $data{'CALL_SIGN'};
          my $xname = $data{'NAME'};
          $xname =~ s/,/ /g;
          my $xprec = $data{'SITE_PRECISION'};
          $xprec =~ s/Within //g;
          $xprec =~ s/ meters//g;
          $xprec =~ s/Unknown/0/g;
          $siteline = sprintf(
          "%s,%s,%s,%s,%s,%s,%s,%s",
          $data{'CALL_SIGN'},
          $data{'LATITUDE'},
          $data{'LONGITUDE'},
          $xname,
          $data{'STATE'},
          $data{'POSTCODE'},
          $xprec,
          $data{'ELEVATION'},
          );
          $lltomh->set_latlng($data{'LATITUDE'},
            $data{'LONGITUDE'});
          my @tolatlng = (
            $data{'LATITUDE'},
            $data{'LONGITUDE'},
            );
          my ($dirsyd, $distsyd) = latlng2dirdist(@fromsydlatlng, @tolatlng);
          my ($dirmel, $distmel) = latlng2dirdist(@frommellatlng, @tolatlng);
          my ($dirtmb, $disttmb) = latlng2dirdist(@fromtmblatlng, @tolatlng);
          my ($dirmtn, $distmtn) = latlng2dirdist(@frommtnlatlng, @tolatlng);
          $distline = sprintf(
          "%s,%s,%d,%.1f,%.1f,%.1f,%.1f,%s,",
          $siteline,$lltomh->latlng2loc,$distsyd,
          $dirsyd,$dirmtn,$distmel,$disttmb,$txpower);
#          print 'found ',$distline,"\n";
          if ($csv->parse($distline)) {
            print $outfh $csv->string, "\n";
          }
          else {
            print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
            $csv->error_diag();
          }
      }
    }
}
