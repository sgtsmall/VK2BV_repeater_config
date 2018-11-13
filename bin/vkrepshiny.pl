#!/opt/local/bin/perl
#
# Creates a data file for the Chirp
#
#
#Mode,Frequency,Name,Comment,Latitude,Longitude
#,0.060,WWVB,,40.677722,-105.038819
#AM,0.530,Traveler's Information
#AM,0.530-1.705,AM broadcast
#AM,1.610,Traveler's Information
#AM,2.5,WWV 2.5,,40.682,-105.041944
#AM,5.0,WWV 5,,40.678361,-105.04025
#AM,10.0,WWV 10,,40.679944,-105.040306


use strict;
use warnings;
no warnings 'experimental::smartmatch';


use Text::CSV_XS;
our @Favourds;
our @FavdstrUR;
our @FavdstrR1;
require My::Favourites;

my $csv = Text::CSV_XS->new({sep_char => ','});

#open shinytemp.csv
my $file1 = $ARGV[0] or die "Need to main CSV file on the command line\n";

# open output/s   then apend shiny later
my $file2pre = $ARGV[1] or die "Need to merge CSV file on the command line\n";


my @CallUuniq;

my $cnt = 0;
my $call       = '';
my $cntfld     = '';
my $utcoffset  = '';
my @grpnum     = qw{3 22 23 24};
my @grpnam     = qw{AusDV FMAus FMAusNW Local};
my @utco10     = qw{VK1 VK2 Vk3 VK4 VK7};
my @utco95     = qw{VK5 VK8};
my @utco08     = qw{VK6};

# Load arrays with file contents
#Open input file
open(my $vkrdfh, '<', $file1) or die "Could not open '$file1' $!\n";

#open output file

open(my $outfh, '>', sprintf("%sshiny.csv", $file2pre)) or die "Could not open '$file2pre' $!\n";
#
my $newhea1 = 'Mode,Frequency,Name,Comment,Latitude,Longitude,';
my $newhead = sprintf("%s", $newhea1);
#
if ($csv->parse($newhead)) {
    print $outfh $csv->string, "\n";
}
else {
    print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
    $csv->error_diag();
}
#

#read the header line of the main input
my @fields = @{$csv->getline($vkrdfh)};

# Read each line from the CSV file, and store it in @rows
my @rows;
while (my $row = $csv->getline($vkrdfh)) {
    my %data;
    @data{@fields} = @$row;    # This is a hash slice

    push @rows, \%data;

# This radio can handle DStar and FM on 2 and 70
    if (   ($data{'mode'} ~~ ["DV", "FM"])
        && ($data{'band'} ~~ ["7", "2", "DST"])
        && ($data{'Output'} < '450.0'))
    {
#        $cnt +=1;
        my $CallUufld = sprintf("%s", $data{'Call U'});
        if (grep { $CallUufld eq $_ } @CallUuniq) {

            #   print "$CallUufld not unique\n";
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

# Name,Sub Name,
        my $ldispname = sprintf("%s %s", $CallUufld, $data{'Location'});

#Name,Frequency,Duplex,Offset,Tone,rToneFreq,cToneFreq,DtcsCode,DtcsPolarity,Mode,
        
        my $newdab1 = sprintf("%s,%s,%s,%s,%s,%s,",
            $data{'mode'}, $data{'Output'}, $CallUufld,$ldispname,$data{'latitude'},$data{'longditude'});

        my $newlinb = sprintf("%s", $newdab1);
        if ($csv->parse($newlinb)) {
            print $outfh $csv->string, "\n";
        }
        else {
            print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
            $csv->error_diag();
        }
        $cnt += 1;
    }
}

# Close the file handles.
close $vkrdfh;
close $outfh;

exit
