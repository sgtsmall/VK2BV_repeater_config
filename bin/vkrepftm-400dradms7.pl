#!/usr/bin/env perl
#
# Creates a data file for the Yaesu FTM-400DR ADMS 7
#
# The best way to manage this radio seems to be by Using Banks.
# The data is organised into several banks
#
use strict;
use warnings;
no warnings 'experimental::smartmatch';


use Text::CSV_XS;

our @Favourft;
require My::Favourites;

#use List::Util qw(first);
#use Scalar::Util qw(looks_like_number);

my $csv = Text::CSV_XS->new({sep_char => ','});

#open vkrepdir.csv
my $file1 = $ARGV[0] or die "Need to main CSV file on the command line\n";

# open vkrepftm-400dr.csv
my $file2pre = $ARGV[1] or die "Need to merge CSV file on the command line\n";
my @CallUuniq;
my $band       = '';
my $call       = '';
my $cntfld     = '';
my $outfh      = '';
my $chnum      = '';
my $memcnta    = 0;
my $memcntb    = 0;

# Load arrays with file contents
#Open input file
open(my $vkrdfh, '<', $file1) or die "Could not open '$file1' $!\n";

#The FTM-400 is limited to 500 Memories per band
#open output file
my $file2a = sprintf("%sa.csv", $file2pre);
my $file2b = sprintf("%sb.csv", $file2pre);

open(my $ftm400fha, '>', $file2a) or die "Could not open '$file2a' $!\n";
open(my $ftm400fhb, '>', $file2b) or die "Could not open '$file2b' $!\n";
#
# my $newhea1 = 'Channel Number,Receive Frequency,Transmit Frequency,Offset Frequency,Offset Direction,Operating Mode,Name,Tone Mode,CTCSS,DCS,DCS Polarity,Tx Power,Skip,Step,Attenuator,Clock Shift,Half Dev,Vibrator,';
#  my $newhea2 = 'Fav,SYDCBD,VK2Sth,VK2Nth,VK2West,WICEN,MELCBD,VK3,VK4SE,VK4,VK5-8,VK6,VK7,APRS,Test,BANK16,BANK17,BANK18,BANK19,BANK20,BANK21,BANK22,Marine Fav,Marine,';
#  my $newhea3 = 'Comment,User CTCSS,S-Meter Squelch,Bell,';
my $newhea1 =
  'Channel Number,Receive Frequency,Transmit Frequency,Offset Frequency,Offset Direction,Operating Mode,Name,Tone Mode,CTCSS,DCS,User CTCSS,Tx Power,Skip,Step,Clock Shift,Comment,';

# print "$newhead,$newhea2,$newhea3\n";
my $newhead = sprintf("%s", $newhea1);
#
#if ($csv->parse ($newhead)) {
#  print $ftm400fh $csv->string, "\n";
#} else {
#  print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
#  $csv->error_diag ();
#}
#Add aprs AU to begiing of 'B'
my $newline = sprintf("1,145.17500,145.17500,0.0000,OFF,FM,APRSAU A,OFF,100.0 Hz,023,1500 Hz,MID,OFF,5.0KHz,0,APRSAU APRSAU ,1");
$outfh = $ftm400fhb;
$memcntb += 1;
if ($csv->parse($newline)) {
    print $outfh $csv->string, "\n";
}
else {
    print STDERR "parse () failed on argument: ", $csv->error_input,"\n";
    $csv->error_diag();
}

#read the header line of the main input
my @fields = @{$csv->getline($vkrdfh)};

# Read each line from the CSV file, and store it in @rows
my @rows;
while ((my $row = $csv->getline($vkrdfh))
    && ($memcnta < '500')
    && ($memcntb < '500'))
{

    my %data;
    @data{@fields} = @$row;    # This is a hash slice

    push @rows, \%data;

# This radio can handle DV-C4FM and FM on 2 and 70
    if (   ($data{'mode'} ~~ ["DV", "FM"])
        && ($data{'band'} ~~ ["7", "2", "C4FM"])
#        && ($data{'absoff'} < '10.0')
        )
    {
#    $cnt +=1;

#DEBUG      print "Station: $data{'Call U'}, Output: $data{Output}\n";
#
#Channel Number,Receive Frequency,Transmit Frequency
#channel number is now at the write line
        my $newdata = sprintf("%3.5f,%3.5f,", $data{'Output'}, $data{'Input'});

#my $newdata = sprintf(",%s,%s,", $data{'Output'}, $data{'Input'});
#
#Offset Frequency,Offset Direction,Operating Mode
# 0.6,5.4       +RPT,-RPT,OFF     AM,FM,NFM
        my $newdat1 = sprintf("%.4f,%s,FM,", $data{'absoff'}, $data{'trpt'});

#    my $newdat1 = sprintf("%.4f,-RPT,NFM,", $data{'absoff'});

        my $CallUufld = sprintf("%s", $data{'Call U'});
#        print "Process $CallUufld\n";
        if (grep { $CallUufld eq $_ } @CallUuniq) {

#        print "$CallUufld not unique\n";
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

        my $name = sprintf("%s %s %s", $CallUufld, $data{'mNemonic'},
            $data{'Location'});

#my $tonemode = 'None';
#    my $tonemode = ( $data{'Tone'} eq '-') ? 'OFF' : 'TONE SQL';
#
#Name,Tone Mode,CTCSS,
# 8char
#
        my $tonemode  = '';
        my $printtone = '';

#TONE,Repeater Tone,RPT1USE,
        if ($data{'Tone'} eq '-') {
            $tonemode = 'OFF,100.0 Hz';
        }
        else {
            my $printtone = sprintf("%.1f", $data{'Tone'});
            $tonemode = sprintf("TONE SQL,%s Hz", $printtone);
        }
        my $newdat2 = sprintf("%.8s,%s,", $name, $tonemode);


#DCS,User CTCSS,Tx Power,
        my $newdat3 = sprintf("023,1500 Hz,MID,");

#
#  Favourite Logic here for Skip
#
#SKIP,
#
        my $SkipFav = 'OFF,';
        if (grep { $data{'Call'} eq $_ } @Favourft) {
            $SkipFav = 'SELECT,';
        }

#Step,Clock Shift,
        my $newdat4 = sprintf("5.0KHz,0,");

#comment
        my $newdat5 = sprintf("%s,", $name);
#
# BANK2,...,13
#
        my $BankLoc = '';
        my $both    = '0'; 
        my $dirn     = sprintf("%s", $data{'dirkat'});
        my $dirs     = '';
        my $distcsyd = sprintf("%s", $data{'distsyd'});
        my $distcmel = sprintf("%s", $data{'distmel'});
        my $distctmb = sprintf("%s", $data{'disttmb'});
        my $bankfld  = sprintf("%s", $data{'bank'});

#DEBUG print ("$data{'Call U'}-$dirn-$dirs-$distc\n");

        my $prefix   = sprintf("%.3s", $data{'Call U'});
        my $prefix6  = sprintf("%.6s", $data{'Call U'});

#DEBUG print "$cnt,$prefix ";
        if (grep { $prefix6 eq $_ } @Favourft ) {
            $band = '0';
            $outfh = $ftm400fha;
            $memcnta += 1;
            $chnum = $memcnta;
            if ($data{'mode'} eq 'FM' ) {
                $both = '-1';
                $memcntb += 1;
            }
        }
        elsif ($bankfld eq '') {
            if (($prefix eq 'VK1') || ($prefix eq 'VK2')) {
                $band  = '0';
                $outfh = $ftm400fha;
                $memcnta += 1;
                $chnum = $memcnta;
            }
            elsif ($prefix eq 'VK3') {
                $band  = '0';
                $outfh = $ftm400fha;
                $memcnta += 1;
                $chnum = $memcnta;
            }
            elsif ($prefix eq 'VK4') {
                $band  = '0';
                $outfh = $ftm400fha;
                $memcnta += 1;
                $chnum = $memcnta;
            }
            elsif ($prefix eq 'VK5') {
                $band  = '1';
                $outfh = $ftm400fhb;
                $memcntb += 1;
                $chnum = $memcntb;
            }
            elsif ($prefix eq 'VK6') {
                $band  = '1';
                $outfh = $ftm400fhb;
                $memcntb += 1;
                $chnum = $memcntb;
            }
            elsif ($prefix eq 'VK7') {
                $band  = '1';
                $outfh = $ftm400fhb;
                $memcntb += 1;
                $chnum = $memcntb;
            }
            elsif ($prefix eq 'VK8') {
                $band  = '1';
                $outfh = $ftm400fhb;
                $memcntb += 1;
                $chnum = $memcntb;
            }
            elsif ($prefix eq 'APR') {
                $band = '0';
                $outfh = $ftm400fha;
                $memcnta += 1;
                $chnum = $memcnta;
                if ($data{'mode'} eq 'FM' ) {
                    $both = '-1';
                    $memcntb += 1;
                }            
            }
            else {
                $band = '0';
                $outfh = $ftm400fha;
                $memcnta += 1;
                $chnum = $memcnta;
                if ($data{'mode'} eq 'FM' ) {
                    $both = '-1';
                    $memcntb += 1;
                }            
            }
#    }
        }
        else {
# if a field is specified put in Band B
            $band = '0';
            $outfh = $ftm400fha;
            $memcnta += 1;
            $chnum = $memcnta;
            if ($data{'mode'} eq 'FM' ) {
                $both = '-1';
                $memcntb += 1;
            }            
        }
        while ( $both < '1' ){
# create the line and write it        
            my $newline = sprintf(
                "%s,%s%s%s%s%s%s%s%s",
                $chnum,   $newdata, $newdat1, $newdat2, $newdat3,
                $SkipFav, $newdat4, $newdat5, $band
            );
            if ($csv->parse($newline)) {
                print $outfh $csv->string, "\n";
            }
            else {
                print STDERR "parse () failed on argument: ", $csv->error_input,
                "\n";
                $csv->error_diag();
            }
            $both += 1;
            $chnum = $memcntb;
            $outfh = $ftm400fhb;
            $band = 1;
        }
    }
}
my $blankline = sprintf(",,,,,,,,,,,,,0,,");

while ($memcnta < '500') {
    $memcnta += 1;
    $band = '0';
    my $fillline = sprintf("%s,%s%s", $memcnta, $blankline, $band);
    if ($csv->parse($fillline)) {
        print $ftm400fha $csv->string, "\n";
    }
    else {
        print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
        $csv->error_diag();
    }
}
while ($memcntb < '500') {
    $band = '1';
    $memcntb += 1;
    my $fillline = sprintf("%s,%s%s", $memcntb, $blankline, $band);
    if ($csv->parse($fillline)) {
        print $ftm400fhb $csv->string, "\n";
    }
    else {
        print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
        $csv->error_diag();
    }
}


# Close the file handles.
close $vkrdfh;
close $ftm400fha;
close $ftm400fhb;

exit
