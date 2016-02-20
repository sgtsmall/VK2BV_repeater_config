#!/usr/bin/env perl
#
# Creates a data file for the Yaesu FT-2DR
#
# The best way to manage this radio seems to be by Using Banks.
# The data is organised into several banks
#
use strict;
use warnings;

use Text::CSV_XS;

our @Favourft;
require My::Favourites;
#use List::Util qw(first);
#use Scalar::Util qw(looks_like_number);

my $csv = Text::CSV_XS->new({sep_char => ','});

#open vkrepdir.csv
my $file1 = $ARGV[0] or die "Need main CSV file on the command line\n";

# open vkrepft-2dr.csv
my $file2 = $ARGV[1] or die "Need merge CSV file on the command line\n";
my @CallUuniq;
my $cnt        = 0;
my $call       = '';
my $cntfld     = '';

# Load arrays with file contents
#Open input file
open(my $vkrdfh, '<', $file1) or die "Could not open '$file1' $!\n";

#open output file
open(my $ft2fh, '>', $file2) or die "Could not open '$file2' $!\n";
#
my $newhea1 =
  'Channel Number,Receive Frequency,Transmit Frequency,Offset Frequency,Offset Direction,Operating Mode,Name,Tone Mode,CTCSS,DCS,DCS Polarity,Tx Power,Skip,Step,Attenuator,Clock Shift,Half Dev,Vibrator,';
my $newhea2 =
  'Fav,SYDCBD,VK2Sth,VK2Nth,VK2West,WICEN,MELCBD,VK3,VK4SE,VK4,VK5-8,VK6,VK7,APRS,Test,BANK16,BANK17,BANK18,BANK19,BANK20,BANK21,BANK22,Marine Fav,Marine,';
my $newhea3 = 'Comment,User CTCSS,S-Meter Squelch,Bell,';

# print "$newhead,$newhea2,$newhea3\n";
my $newhead = sprintf("%s%s%s", $newhea1, $newhea2, $newhea3);
#
if ($csv->parse($newhead)) {
    print $ft2fh $csv->string, "\n";
}
else {
    print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
    $csv->error_diag();
}

#read the header line of the main input
my @fields = @{$csv->getline($vkrdfh)};

# Read each line from the CSV file, and store it in @rows
my @rows;
while (my $row = $csv->getline($vkrdfh)) {
    my %data;
    @data{@fields} = @$row;    # This is a hash slice

    push @rows, \%data;

# This radio can handle DV-C4FM and FM on 2 and 70
    if (   ($data{'mode'} ~~ ["DV", "FM"])
        && ($data{'band'} ~~ ["7", "2", "C4FM"]))
    {
        $cnt += 1;

#DEBUG      print "Station: $data{'Call U'}, Output: $data{Output}\n";
#
#Channel Number,Receive Frequency,Transmit Frequency
#
        my $newdata =
          sprintf("%d,%s,%s,", $cnt, $data{'Output'}, $data{'Input'});

#my $newdata = sprintf(",%s,%s,", $data{'Output'}, $data{'Input'});
#
#Offset Frequency,Offset Direction,Operating Mode
#
        my $newdat1 = sprintf("%.3f MHz,%s,%s,",
            $data{'absoff'}, $data{'tsign'}, $data{'mode'});

        my $CallUufld = sprintf("%s", $data{'Call U'});
        if (grep { $CallUufld eq $_ } @CallUuniq) {

#        print "$CallUufld not unique\n";
            my $cuniq = '64';
            while (grep { $CallUufld eq $_ } @CallUuniq) {
                $cuniq += 1;
                my $ccuniq = chr($cuniq);
                my $tCallUufld = substr $CallUufld, 6, 1, $ccuniq;
            }
            print "Inserting $CallUufld\n";
            push @CallUuniq, $CallUufld;
        }
        else {
            push @CallUuniq, $CallUufld;
        }

        my $name = sprintf("%s %s %s", $CallUufld, $data{'mNemonic'},
            $data{'Location'});

#my $tonemode = 'None';
        my $tonemode = ($data{'CTCSS'} eq '-') ? 'None' : 'T Sql';
#
#Name,Tone Mode,CTCSS,
#
        my $newdat2 =
          sprintf("%.16s,%s,%s,", $name, $tonemode, $data{'CTCSS'});
#
# DCS,DCS Polarity,Tx Power,Skip,Step,Attenuator,Clock Shift,Half Dev,
#
        my $newdat3 = sprintf(",,%s,,,,,,", $data{'txpower'});
#
#  Favourite Logic here for Bank1
#
# Vibrator,BANK1
#
        my $BankFav = ',,';
        if (grep { $data{'Call'} eq $_ } @Favourft) {
            $BankFav = '1,1,';
        }
#
# BANK2,...,13
#
        my $BankLoc = '';
#
        my $dirn     = sprintf("%s", $data{'dirkat'});
        my $dirs     = '';
        my $distcsyd = sprintf("%s", $data{'distsyd'});
        my $distcmel = sprintf("%s", $data{'distmel'});
        my $distctmb = sprintf("%s", $data{'disttmb'});
        my $bankfld  = sprintf("%s", $data{'bank'});

#DEBUG print ("$data{'Call U'}-$dirn-$dirs-$distc\n");

        my $prefix = sprintf("%.3s", $data{'Call U'});

#DEBUG print "$cnt,$prefix ";
        if ($bankfld eq '') {
            for ($prefix) {
                if (($prefix eq 'VK1') || ($prefix eq 'VK2')) {

#  print ("when1 or 2 $cnt $prefix ");

                    if ($distcsyd eq '') {

                        #           2345667890123
                        $BankLoc = ',,,,1,,,,,,,,';
                    }
                    elsif ($distcsyd <= '60000') {

#DEBUG  print "lt 60000\n";
                        #           2234567890123
                        $BankLoc = '1,,,,,,,,,,,,';
                    }
                    else {
                        if ($dirn eq '') {

                            #           2345667890123
                            $BankLoc = ',,,,1,,,,,,,,';
                        }
                        else {
                            $dirs = $dirn + 157.5;
                            if ($dirs lt 180) {    #West

                                #           2345567890123
                                $BankLoc = ',,,1,,,,,,,,,';
                            }
                            elsif ($dirs gt 360) {    #West

                                #           2345567890123
                                $BankLoc = ',,,1,,,,,,,,,';
                            }
                            elsif ($dirs lt 270) {    #North

                                #           2344567890123
                                $BankLoc = ',,1,,,,,,,,,,';
                            }
                            elsif ($dirs le 360) {    #South

                                #           2334567890123
                                $BankLoc = ',1,,,,,,,,,,,';
                            }
                        }
                    }
                }
                elsif ($prefix eq 'VK3') {

#    print ("when3 $cnt $prefix ");
                    if ($distcmel eq '') {

                        #           2345667890123
                        $BankLoc = ',,,,1,,,,,,,,';
                    }
                    elsif ($distcmel <= '80000') {

#DEBUG  print "lt 60000\n";
                        #           2345677890123
                        $BankLoc = ',,,,,1,,,,,,,';
                    }
                    else {
                        #           2345678890123
                        $BankLoc = ',,,,,,1,,,,,,';
                    }
                }
                elsif ($prefix eq 'VK4') {

#    print ("when4 $cnt $prefix ");
                    if ($distctmb eq '') {

                        #           2345667890123
                        $BankLoc = ',,,,1,,,,,,,,';
                    }
                    elsif ($distctmb <= '80000') {

#DEBUG  print "lt 60000\n";
                        #           2345678990123
                        $BankLoc = ',,,,,,,1,,,,,';
                    }
                    else {
                        #           2345678900123
                        $BankLoc = ',,,,,,,,1,,,,';
                    }
                }
                elsif (($prefix eq 'VK5') || ($prefix eq 'VK8')) {

#  print ("when5 $cnt $prefix ");
                    #           2345678901123
                    $BankLoc = ',,,,,,,,,1,,,';
                }
                elsif ($prefix eq 'VK6') {

#    print ("when6 $cnt $prefix ");
                    #           2345678901223
                    $BankLoc = ',,,,,,,,,,1,,';
                }
                elsif ($prefix eq 'VK7') {

#  print ("when7 $cnt $prefix ");
                    #           2345678901233
                    $BankLoc = ',,,,,,,,,,,1,';
                }
                else {
#  print ("got to default $prefix");
                    #           234567890123
                    $BankLoc = ',,,,,,,,,,,,';
                }
            }
        }
        else {
            $BankLoc = ',,,,,,,,,,,,';
            if ($bankfld eq '6') {
                $BankLoc = ',,,,1,,,,,,,,';
            }
        }

# BANK14,15
        my $BankAPRS = ',';
        if ($prefix eq 'APR') {
            $BankAPRS = '1,';
        }
        my $BankTest = ',';
        if ($bankfld eq '15') {
            $BankTest = '1,';
        }

# BANK16,..,24,
#                       678901234
        my $BankRest = ',,,,,,,,,';
#
        my $newbank = sprintf("%s%s%s%s%s",
            $BankFav, $BankLoc, $BankAPRS, $BankTest, $BankRest);

# Comment, User CTCSS,S-Meter Squelch,Bell,
#
        my $newdat4 = sprintf("%s,,,", $name);
#
        my $newline = sprintf("%s%s%s%s%s%s",
            $newdata, $newdat1, $newdat2, $newdat3, $newbank, $newdat4);
#
#
        if ($csv->parse($newline)) {
            print $ft2fh $csv->string, "\n";
        }
        else {
            print STDERR "parse () failed on argument: ", $csv->error_input,
              "\n";
            $csv->error_diag();
        }
    }
}

# Close the file handles.
close $vkrdfh;
close $ft2fh;

exit
