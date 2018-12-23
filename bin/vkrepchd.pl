#!/opt/local/bin/perl
#
# Creates a data file for the Chirp
#
#
#Location,Name,Frequency,Duplex,Offset,Tone,rToneFreq,cToneFreq,DtcsCode,DtcsPolarity,Mode,TStep,Skip,Comment,URCALL,RPT1CALL,RPT2CALL
#0,,146.010000,,0.600000,,88.5,88.5,023,NN,FM,5.00,,,,,,

use strict;
use warnings;
no warnings 'experimental::smartmatch';


use Text::CSV_XS;
our @Favourds;
our @FavdstrUR;
our @FavdstrR1;
our @Favtsqlr;
require My::Favourites;

my $csv = Text::CSV_XS->new({sep_char => ','});

#open vkrepdir.csv
my $file1 = $ARGV[0] or die "Need to main CSV file on the command line\n";

# open vkrepft-2dr.csv
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

open(my $icgfh1, '>', sprintf("%sirpx.csv", $file2pre)) or die "Could not open '$file2pre' $!\n";
#
my $newhea1 = 'Location,Name,Frequency,Duplex,Offset,Tone,rToneFreq,cToneFreq,';
my $newhea2 = 'DtcsCode,DtcsPolarity,Mode,TStep,Skip,Comment,URCALL,RPT1CALL,RPT2CALL';

my $newhead = sprintf("%s%s", $newhea1, $newhea2);
#
if ($csv->parse($newhead)) {
    print $icgfh1 $csv->string, "\n";

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
        && ($data{'Output'} < '490.0'))
    {
#        $cnt +=1;
        my $CallUufld = sprintf("%s", $data{'Call U'});
	  my $CallUdfld = $CallUufld;
	  if (length $CallUufld > 6 ) {
	  	my $CallUxfld = substr($CallUdfld, 6, 1, '-');
	}
#	  print STDERR "DEBUG: CallUufld: ", $CallUufld, " CallUdfld: ", $CallUdfld, "\n";

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

#DEBUG      print "Station: $data{'Call U'}, Output: $data{Output}\n";
#
        my $CallG  = '';
        my $Urcall = '';
        if ($data{'mode'} eq 'DV') {
            $CallG = sprintf("%.7sG", $data{'Call U'});
            $Urcall = 'CQCQCQ';
        }
        my $prefix6  = sprintf("%.6s", $data{'Call U'});
# Name,Sub Name,
        my $dispname = '';
        my $ldispname = '';
        if ($data{'mNemonic'} eq '-') {
            $dispname = sprintf("%.16s", $data{'Location'});
            $ldispname = sprintf("%s %s", $CallUufld, $data{'Location'});
        }
        else {
            $dispname = sprintf("%.16s", $data{'mNemonic'});
            $ldispname = sprintf("%s %s", $CallUufld, $data{'mNemonic'});
        }


#TONE,Repeater Tone,RPT1USE,
#TONE - Tone only, TSQL - Tone Squelch
        my $tonemode = '';
        if ($data{'Tone'} eq '-') {
            $tonemode = ',88.5,88.5';
        }
        elsif ( grep { $CallUdfld eq $_ } @Favtsqlr) {
		  $tonemode = sprintf("TSQL,%s,%s", $data{'Tone'},$data{'Tone'});
	  }
	  else {
#            $tonemode = sprintf("TSQL,%s,%s", $data{'Tone'},$data{'Tone'});
            $tonemode = sprintf("Tone,%s,%s", $data{'Tone'},$data{'Tone'});
        }
#	  print STDERR "DEBUG: CallUufld: ", $CallUufld, " CallUdfld: ", $CallUdfld, " tonemode:", $tonemode,"\n";

#my $newdat4 = sprintf("%s,%s,", $tonemode, $Rptuseg);

#Name,Frequency,Duplex,Offset,Tone,rToneFreq,cToneFreq,DtcsCode,DtcsPolarity,Mode,
        my $newdab1 = sprintf("%s,",$ldispname);
        my $newdab2 = sprintf("%s,%s,%s,%s,023,NN,%s,",
            $data{'Output'}, $data{'sign'}, $data{'absoff'},$tonemode,$data{'mode'});

        my $Rptskip = 'S';
        if (grep { $prefix6 eq $_ } @Favourds) {
            $Rptskip = '';
        }

#TStep,Skip,Comment,
        my $newdab3 = sprintf("5.00,%s,%s,",$Rptskip,$ldispname);

#,URCALL,RPT1CALL,RPT2CALL
        my $newdab4 = sprintf("%s,%s,%s", $Urcall, $CallUufld, $CallG);

#
        my $dirn   = sprintf("%s", $data{'dirkat'});
        my $dirs = '';
        my $distcsyd = sprintf("%s", $data{'distsyd'});

#    my $distcmel = sprintf ("%s",$data{'distmel'});
#    my $distctmb = sprintf ("%s",$data{'disttmb'});
#DEBUG print ("$data{'Call U'}-$dirn-$dirs-$distc\n");

        my $prefix = sprintf("%.3s", $data{'Call U'});

#DEBUG print "$cnt,$prefix ";
#get this working with the array!!!

        my $grpnum = '';
        my $grpnam = '';
        my $outfh  = $icgfh1;
        my $chnum  = 'UNDEF';
        my $bchnum = 'UNDEF';

        my $newlinb = sprintf("%s,%s%s%s%s", $cnt, $newdab1, $newdab2, $newdab3, $newdab4);
        if ($csv->parse($newlinb)) {
            print $outfh $csv->string, "\n";
        }
        else {
            print STDERR "parse () failed on argument: ", $csv->error_input, "\n";
            $csv->error_diag();
        }
        $cnt += 1;
        if (($data{'mode'} eq 'DV') && (grep { $prefix6 eq $_ } @FavdstrR1)) {
            foreach  (@FavdstrUR) {
            #    $cnt += 1;
           #print $dmrlabtg , "\n" ;
                my @dstinfo = split('-',$_);
                my $dstlab = $dstinfo[0];
                my $dstUR = $dstinfo[1];
                $ldispname = sprintf("%s %s",$CallUufld, $dstlab);
                $Urcall = sprintf("%8s",$dstUR);
                my $newdab1 = sprintf("%s,",$ldispname);
#TStep,Skip,Comment,
                my $newdab3 = sprintf("5.00,%s,%s,",$Rptskip,$ldispname);

#,URCALL,RPT1CALL,RPT2CALL
                my $newdab4 = sprintf("%s,%s,%s", $Urcall, $CallUufld, $CallG);
                my $newlinb = sprintf("%s,%s%s%s%s", $cnt, $newdab1, $newdab2, $newdab3, $newdab4);
                if ($csv->parse($newlinb)) {
                    print $outfh $csv->string, "\n";
                }
                else {
                    print STDERR "parse () failed on argument: ",
                    $csv->error_input, "\n";
                    $csv->error_diag();
                }
                $cnt += 1;
            }
        }
    }
}

# Close the file handles.
close $vkrdfh;
close $icgfh1;

exit
