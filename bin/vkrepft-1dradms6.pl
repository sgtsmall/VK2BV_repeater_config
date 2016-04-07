#!/usr/bin/env perl
#
# Creates a data file for the Yaesu FT-1DR ADMS6
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

my $csv = Text::CSV_XS->new({sep_char => ','});

#open vkrepdir.csv
my $file1 = $ARGV[0] or die "Need to main CSV file on the command line\n";

# open vkrepft-1dradms6.csv
my $file2 = $ARGV[1] or die "Need to merge CSV file on the command line\n";
my @CallUuniq;
my $cnt        = 0;
my $call       = '';
my $cntfld     = '';

# Load arrays with file contents
#Open input file
open(my $vkrdfh, '<', $file1) or die "Could not open '$file1' $!\n";

#open output file
open(my $ft1fh, '>', $file2) or die "Could not open '$file2' $!\n";
#
# my $newhea1 = 'Channel Number,Receive Frequency,Transmit Frequency,Offset Frequency,Offset Direction,Operating Mode,Name,Tone Mode,CTCSS,DCS,DCS Polarity,Tx Power,Skip,Step,Attenuator,Clock Shift,Half Dev,Vibrator,';
#  my $newhea2 = 'Fav,SYDCBD,VK2Sth,VK2Nth,VK2West,WICEN,MELCBD,VK3,VK4SE,VK4,VK5-8,VK6,VK7,APRS,Test,BANK16,BANK17,BANK18,BANK19,BANK20,BANK21,BANK22,Marine Fav,Marine,';
#  my $newhea3 = 'Comment,User CTCSS,S-Meter Squelch,Bell,';
my $newhea1 =
  'Channel Number,Priotiry Channel,Receive Frequency,Transmit Frequency,Offset Frequency,Offset Direction,Operating Mode,Name,Tone Mode,CTCSS,DCS,DCS Polarity,User CTCSS,Tx Power,Skip,Step,,Attenuator,S-Meter Squelch,Bell,Vibrator,Half Dev,Clock Shift,';
my $newhea2 =
  'Fav,SYDCBD,VK2Sth,VK2Nth,VK2West,WICEN,MELCBD,VK3,VK4SE,VK4,VK5-8,VK6,VK7,APRS,Test,BANK16,BANK17,BANK18,BANK19,BANK20,BANK21,C4FM,Marine Fav,Marine,';
my $newhea3 = 'Comment,';

# print "$newhead,$newhea2,$newhea3\n";
my $newhead = sprintf("%s%s%s", $newhea1, $newhea2, $newhea3);
#
#if ($csv->parse ($newhead)) {
#  print $ft1fh $csv->string, "\n";
#} else {
#  print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
#  $csv->error_diag ();
#}

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
#Channel Number,Priotiry Channel,Receive Frequency,Transmit Frequency
#
        my $newdata =
          sprintf("%d,0,%3.5f,%3.5f,", $cnt, $data{'Output'}, $data{'Input'});

#my $newdata = sprintf(",%s,%s,", $data{'Output'}, $data{'Input'});
#
#Offset Frequency,Offset Direction,Operating Mode

        my $newdat1 = sprintf("%.4f,%s,NFM,", $data{'absoff'}, $data{'trpt'});

#    my $newdat1 = sprintf("%.4f,-RPT,NFM,", $data{'absoff'});

        my $CallUufld = sprintf("%s", $data{'Call U'});
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
#
        my $tonemode = '';

#TONE,Repeater Tone,RPT1USE,
        if ($data{'Tone'} eq '-') {
            $tonemode = 'OFF,';
        }
        else {
            $tonemode = sprintf("TONE SQL,%s Hz", $data{'Tone'});
        }
        my $newdat2 = sprintf("%.16s,%s,", $name, $tonemode);


#
#DCS,DCS Polarity,User CTCSS,Tx Power,Skip,Step,,Attenuator,S-Meter Squelch,Bell,Vibrator,Half Dev,Clock Shift,
#    my $newdat3 = sprintf(",,,%s,,,,,,,,,,", $data{'txpower'});
#my $newdat3 = sprintf("023,RX Normal TX Normal,1600 Hz,HIGH,OFF,12.5KHz,0,0,OFF,OFF,SIGNALING,0,0,");
        my $newdat3 = sprintf("023,,1600 Hz,HIGH,OFF,12.5KHz,,,,,,,,");
#
#  Favourite Logic here for Bank1
#
#BANK1
#
        my $BankFav = ',';
        if (grep { $data{'Call'} eq $_ } @Favourft) {
            $BankFav = '1,';
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

                        #               2345667890123
                        $BankLoc = '0,0,0,0,1,0,0,0,0,0,0,0,';
                    }
                    elsif ($distcsyd <= '60000') {

#DEBUG  print "lt 60000\n";
                        #           2234567890123
                        $BankLoc = '1,0,0,0,0,0,0,0,0,0,0,0,';
                    }
                    else {
                        if ($dirn eq '') {

                            #               2345667890123
                            $BankLoc = '0,0,0,0,1,0,0,0,0,0,0,0,';
                        }
                        else {
                            $dirs = $dirn + 157.5;
                            if ($dirs lt 180) {    #West

                                #                   2345567890123
                                $BankLoc = '0,0,0,1,0,0,0,0,0,0,0,0,';
                            }
                            elsif ($dirs gt 360) {    #West

                                #                   2345567890123
                                $BankLoc = '0,0,0,1,0,0,0,0,0,0,0,0,';
                            }
                            elsif ($dirs lt 270) {    #North

                                #                   2344567890123
                                $BankLoc = '0,0,1,0,0,0,0,0,0,0,0,0,';
                            }
                            elsif ($dirs le 360) {    #South

                                #                   2334567890123
                                $BankLoc = '0,1,0,0,0,0,0,0,0,0,0,0,';
                            }
                        }
                    }
                }
                elsif ($prefix eq 'VK3') {

#    print ("when3 $cnt $prefix ");
                    if ($distcmel eq '') {

                        #           2345667890123
                        $BankLoc = '0,0,0,0,1,0,0,0,0,0,0,0,';
                    }
                    elsif ($distcmel <= '80000') {

#DEBUG  print "lt 60000\n";
                        #           2345677890123
                        $BankLoc = '0,0,0,0,0,1,0,0,0,0,0,0,';
                    }
                    else {
                        #           2345678890123
                        $BankLoc = '0,0,0,0,0,0,1,0,0,0,0,0,';
                    }
                }
                elsif ($prefix eq 'VK4') {

#    print ("when4 $cnt $prefix ");
                    if ($distctmb eq '') {

                        #           2345667890123
                        $BankLoc = '0,0,0,0,1,0,0,0,0,0,0,0,';
                    }
                    elsif ($distctmb <= '80000') {

#DEBUG  print "lt 60000\n";
                        #           2345678990123
                        $BankLoc = '0,0,0,0,0,0,0,1,0,0,0,0,';
                    }
                    else {
                        #           2345678900123
                        $BankLoc = '0,0,0,0,0,0,0,0,1,0,0,0,';
                    }
                }
                elsif (($prefix eq 'VK5') || ($prefix eq 'VK8')) {

#  print ("when5 $cnt $prefix ");
                    #       2345678901123
                    $BankLoc = '0,0,0,0,0,0,0,0,0,1,0,0,';
                }
                elsif ($prefix eq 'VK6') {

#    print ("when6 $cnt $prefix ");
                    #       2345678901223
                    $BankLoc = '0,0,0,0,0,0,0,0,0,0,1,0,';
                }
                elsif ($prefix eq 'VK7') {

#  print ("when7 $cnt $prefix ");
                    #       2345678901233
                    $BankLoc = '0,0,0,0,0,0,0,0,0,0,0,1,';
                }
                else {
#  print ("got to default $prefix");
                    #       234567890123
                    $BankLoc = '0,0,0,0,0,0,0,0,0,0,0,0,';
                }
            }
        }
        else {
            $BankLoc = '0,0,0,0,0,0,0,0,0,0,0,0,';
            if ($bankfld eq '6') {
                $BankLoc = '0,0,0,0,1,0,0,0,0,0,0,0,';
            }
        }

# BANK14,15
        my $BankAPRS = '0,';
        if ($prefix eq 'APR') {
            $BankAPRS = '1,';
        }
        my $BankTest = '0,';
        if ($bankfld eq '15') {
            $BankTest = '1,';
        }

# BANK16,..,21,
#                       678901
        my $BankRest = '0,0,0,0,0,0,';
# BANK22
        my $BankC4FM ='0,';
        if ($data{'band'} eq 'C4FM') {
            $BankC4FM ='1,'
        }
# BANK23,24,
        my $BankMarine = '0,0,';
#
        my $newbank = sprintf("%s%s%s%s%s%s%s",
            $BankFav, $BankLoc, $BankAPRS, $BankTest, $BankRest, $BankC4FM, $BankMarine);


# Comment,
#
        my $newdat4 = sprintf("%s,1,", $name);
#
        my $newline = sprintf("%s%s%s%s%s%s",
            $newdata, $newdat1, $newdat2, $newdat3, $newbank, $newdat4);
#
#
        if ($csv->parse($newline)) {
            print $ft1fh $csv->string, "\n";
        }
        else {
            print STDERR "parse () failed on argument: ", $csv->error_input,
              "\n";
            $csv->error_diag();
        }
    }
}
my $blankline = sprintf(
    "0,,,,,,,,,,,,,,,1,0,,,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,1,"
);

while ($cnt < '900') {
    $cnt += 1;
    my $fillline = sprintf("%s,%s", $cnt, $blankline);
    if ($csv->parse($fillline)) {
        print $ft1fh $csv->string, "\r\n";
    }
    else {
        print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
        $csv->error_diag();
    }
}


# Close the file handles.
close $vkrdfh;
close $ft1fh;

exit
