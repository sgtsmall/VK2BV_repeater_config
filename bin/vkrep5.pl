#!/usr/bin/env perl
# Reads in the monthly wia data and the converted kml data
# Creates a vkrepdir.csv
#

use strict;
use warnings;

use Text::CSV_XS;
use Text::CSV::Hashify;
#use List::Util qw(first);
use Scalar::Util qw(looks_like_number);

my $csv = Text::CSV_XS->new({sep_char => ','});

#work/wiarepdir.csv
my $file1 = $ARGV[0] or die "Need wia modified CSV file on the command line\n";
# new output/shortsite.csv
#old output/vkrep.csv
my $ssitinf = $ARGV[1] or die "need shortsite CSV file on the command line\n";

my $call    = '';
my $head    = '';
my $sort    = '0Sort';
my $mode    = 'mode';
my $type    = 'U';
my $band    = 'band';
my $offdata = '';
my @kmllist;
my $cntfld = '';

# Load arrays with file contents
#new spectra
#my $newhea1 = 'CALL_SIGN,LATITUDE,LONGITUDE,NAME,STATE,POSTCODE,SITE_PRECISION,';
#my $newhea2 = 'ELEVATION,maidenhead,distsyd,dirsyd,dirkat,distmel,disttmb,txpower,bank';


#Load the hash with all repeater calls from ACMA
my $ssitex = Text::CSV::Hashify->new ( {
    file => $ssitinf,
    format => 'hoh',
    key => 'CALL_SIGN',
}
);

#open(my $kmlfh, '<', $file2) or die "Could not open '$file2' $!\n";
#while (my $kmldata = $csv->getline($kmlfh)) {
#    push @kmllist, $kmldata;
#}
#close($kmlfh);


open(my $data, '<', $file1) or die "Could not open '$file1' $!\n";
while (my $line = <$data>) {
    chomp $line;

    if ($csv->parse($line)) {
        my @fields = $csv->fields();
        $cntfld = scalar(grep $_, @fields);
        if ($fields[0] eq 'HEAD') {
            $sort = $fields[1];
            $mode = $fields[3];
            $type = $fields[4];
            $band = $fields[4];
            if ($type eq 'DST') { $type = ''; }
            if ($type eq 'C4FM') {$type = '4'; }
        } 
        else {
# Not a HEAD
            $call = sprintf("%s %s,%s,%s", $fields[2], $type, $mode, $band);

# Note 2
#
# Sometimes there is a comma in the note field
# need longer term fix
#
# fielddata also contains the existing headings from the vkrep.csv
#
            my $fielddata = join ",", @fields;

            if ($cntfld < 14) {
                $fielddata = sprintf("%s,", $fielddata);

#            print "$cntfld $fielddata\n";
                if ($fields[0] eq 'Output') {
                    $fielddata = sprintf("%sNote2", $fielddata);
                }
            }

# offset +,-
#
# need to look at simplex here
# calculate offset etc for repeater
            if (   (looks_like_number($fields[0]))
                && (looks_like_number($fields[1])))
            {
                my $offset = $fields[1] - $fields[0];
                my $offabs = abs $offset;

# if the offset >0 then receive was higher so offset to Tx is '-'.
                my $offtxt =
                  ($offset < 0)
                  ? '"-",MINUS,DUP-,"-RPT"'
                  : '"+",PLUS,DUP+,"+RPT"';
                $offdata = sprintf("%.3f,%.3f,%s", $offset, $offabs, $offtxt);
            }
            elsif ($fields[0] eq 'Output') {
                $offdata = sprintf("Offset,absoff,sign,tsign,tdup,trpt");
            }
            else {
                $offdata = sprintf(",,,,,");
            }

# DEBUG print "$offdata\n";
#
#
# look for the location data
# could hash this but the whole job runs under a second
# and I also want to leave the vkrep.csv file alone
            my $result = ',,,,,,,,5,,';
            
#'CALL_SIGN,LATITUDE,LONGITUDE,NAME,STATE,POSTCODE,SITE_PRECISION,';
#ELEVATION,maidenhead,distsyd,dirsyd,dirkat,distmel,disttmb,txpower,bank'
            if ($fields[0] ne 'Output')  {
                my $shcall = substr $fields[2], 0,6;        
#                print STDERR $shcall,"\n";
                if ( $ssitex->datum($shcall,'txpower'))  {
                    $result = sprintf(
                    "%s,%s,%s,%s,%s,%s,%s,%s,%s,,",
                    $ssitex->datum($shcall,'LONGITUDE'),
                    $ssitex->datum($shcall,'LATITUDE'),
                    $ssitex->datum($shcall,'maidenhead'),
                    $ssitex->datum($shcall,'distsyd'),
                    $ssitex->datum($shcall,'dirsyd'),
                    $ssitex->datum($shcall,'dirkat'),
                    $ssitex->datum($shcall,'distmel'),
                    $ssitex->datum($shcall,'disttmb'),
                    $ssitex->datum($shcall,'txpower'),
                    );
                } else {
                    print STDERR 'No ACMA Location ',$shcall,"\n";
               # last;
                }
            } else {
            $result = 'longditude,latitude,maidenhead,distsyd,dirsyd,dirkat,distmel,disttmb,txpower,bank,TS'
            }
            
            print "$sort,$call,$fielddata,$offdata,$result\n";
        }
    }
    else {
        warn "Line could not be parsed: $line\n";
    }
}

# DEBUG print "Finished\n";


