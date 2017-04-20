#!/usr/bin/env perl
#
# Extract repeater info from spectra device_details.csv
#
#SDD_ID,LICENCE_NO,DEVICE_REGISTRATION_IDENTIFIER,FORMER_DEVICE_IDENTIFIER,AUTHORISATION_DATE,CERTIFICATION_METHOD,GROUP_FLAG,SITE_RADIUS,FREQUENCY,BANDWIDTH,
#CARRIER_FREQ,EMISSION,DEVICE_TYPE,TRANSMITTER_POWER,TRANSMITTER_POWER_UNIT,SITE_ID,ANTENNA_ID,POLARISATION,AZIMUTH,HEIGHT,
#TILT,FEEDER_LOSS,LEVEL_OF_PROTECTION,EIRP,EIRP_UNIT,SV_ID,SS_ID,EFL_ID,EFL_FREQ_IDENT,EFL_SYSTEM,
#LEQD_MODE,RECEIVER_THRESHOLD,AREA_AREA_ID,CALL_SIGN,AREA_DESCRIPTION,AP_ID,CLASS_OF_STATION_CODE,SUPPLIMENTAL_FLAG,EQ_FREQ_RANGE_MIN,EQ_FREQ_RANGE_MAX,
#NATURE_OF_SERVICE_ID,HOURS_OF_OPERATION,SA_ID,RELATED_EFL_ID,EQP_ID,ANTENNA_MULTI_MODE,POWER_IND,LPON_CENTER_LONGITUDE,LPON_CENTER_LATITUDE,TCS_ID,
#TECH_SPEC_ID,DROPTHROUGH_ID


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
my $devdet = 'work/device_details.csv';
my $sitinf = 'work/site.csv';
#open shinytemp.csv
#SITE_ID,LATITUDE,LONGITUDE,NAME,STATE,LICENSING_AREA_ID,POSTCODE,SITE_PRECISION,ELEVATION
my $sitex = Text::CSV::Hashify->new ( {
    file => $sitinf,
    format => 'hoh',
    key => 'SITE_ID',
}
);
my $lltomh = Ham::Locator->new();

# open output/s   then apend shiny later
my $file2pre = $ARGV[0] or die "Need to merge CSV file on the command line\n";


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
open(my $devdetfh, '<', $devdet) or die "Could not open '$devdet' $!\n";


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
my $fields = $csv->getline($devdetfh);

my @fields = @{$fields};
# Read each line from the CSV file, and store it in @rows
my @rows;
while (my $row = $csv->getline($devdetfh)) {
    my %data;
    @data{@fields} = @$row;    # This is a hash slice
    if ($data{'CALL_SIGN'} =~ /(^VK[123456789]R)(.{2,})/ ){
      if (! grep { $data{'CALL_SIGN'} eq $_ } @CallUniq) {
        push @CallUniq, $data{'CALL_SIGN'};
        if ($data{'SITE_ID'} ne '' ) {
          my $xname = $sitex->datum($data{'SITE_ID'},'NAME'); 
          $xname =~ s/,/ /g;
          my $xprec = $sitex->datum($data{'SITE_ID'},'SITE_PRECISION');
          $xprec =~ s/Within //g;
          $xprec =~ s/ meters//g;
          $xprec =~ s/Unknown/0/g;      
          $siteline = sprintf(
          "%s,%s,%s,%s,%s,%s,%s,%s",
          $data{'CALL_SIGN'},
          $sitex->datum($data{'SITE_ID'},'LATITUDE'),
          $sitex->datum($data{'SITE_ID'},'LONGITUDE'),
          $xname,
          $sitex->datum($data{'SITE_ID'},'STATE'),
          $sitex->datum($data{'SITE_ID'},'POSTCODE'),
          $xprec,
          $sitex->datum($data{'SITE_ID'},'ELEVATION'),
          );
          $lltomh->set_latlng($sitex->datum($data{'SITE_ID'},'LATITUDE'),
            $sitex->datum($data{'SITE_ID'},'LONGITUDE'));
          my @tolatlng = (
            $sitex->datum($data{'SITE_ID'},'LATITUDE'),
            $sitex->datum($data{'SITE_ID'},'LONGITUDE'),
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
}
