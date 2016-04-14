#!/usr/bin/env perl
#my @array = qw( your array here );
#my $search_for = "here";
#my( $index )= grep { $array[$_] eq $search_for } 0..$#array;
#my @array = ( 'Name: Mr. Jones', 
#              'Phone: 555-555', 
#              'Email: jones@example.com' 
#);
my @fmchan = ('VK2ROZ 7','VK2ROT 7','VK2RCG 7');
my @fmscanhead = ( 'FAVFM','YSYDFM','YMELFM','MELFM','SYDFM','TMBFM','XMELFM' );
my $CallUufld = '';
my $fmscanlist = 'MELFM';

foreach $CallUufld (@fmchan) {
my ( $index )= grep { $fmscanhead[$_] =~ /^$fmscanlist/ } 0..$#fmscanhead;
print "index $index\n";

                    print "index of $scanlistfm = $index\n";
                    print "value of index = $fmscanhead[$index]\n";
                    
                    #if (my ($matched) = grep $_ eq $scanlistfm, @fmscantmp) {
                    #print "found it: $index\n";
                    my $newfmscan = sprintf('%s;%s',$fmscanhead[$index],$CallUufld);
                    print "found it: $newfmscan \n";
                    splice(@fmscanhead,$index,1,$newfmscan);
                    }
                    print "@fmscanhead \n";