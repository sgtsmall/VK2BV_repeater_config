#!/opt/local/bin/perl

# read vkrepdir remove colums Latitude and Longitude
#!/opt/local/bin/perl

=pod
=head1 NAME
prune-columns.pl - prune columns from a CSV file
=head1 USAGE
    prune-columns.pl csvfile regex [regex ...]
=head1 DESCRIPTION
The script reads from the CSV file specified in argument B<csvfile>, flags the
columns to be removed in memory, and prints to STDOUT a new CSV file that is
missing the indicated columns.
The original CSV file is not altered. You'll need to capture the script output
to get the new CSV file.
=head1 TO DO
At some point it might be nice to have code that removes by column index as
well, but what I need now is just to remove by pattern.
=cut

use strict;
use warnings FATAL => 'all';
use Data::Dumper;
use Pod::Usage;
use Text::CSV_XS;

# homebrew argument parser, maybe upgrade to Getopt::Long?
pod2usage() unless @ARGV;

my ($csvfile, @regexes) = @ARGV;
pod2usage("CSV file '$csvfile' not found.") unless -f $csvfile;
pod2usage("Please specify one or more regular expressions.") unless @regexes;

my @columns = columns($csvfile);    # my list of CSV columns
my %deleted;                        # empty hash of column indices to "delete"

# find indices of columns matching regex(es)
foreach my $regex (@regexes) {
    foreach my $i (0 .. ($#columns )) {
        my $col = $columns[$i];
        $deleted{$i} = $col if $col =~ /$regex/;
    }
}

warn Dumper(\%deleted);

# construct the "array slice" to apply (keep these columns)
my @slice = grep { !$deleted{$_} } 0 .. $#columns - 1;

# Read the CSV file line by line and slice out the columns we want to keep as
# we print.
open my $fh, "<", $csvfile or die "$csvfile: $!";
while (my $row = csv()->getline($fh)) {
    my @fields = @$row;
    csv()->print(*STDOUT, [ @fields[@slice] ]) or csv()->error_diag;
}
close $fh or die $!;


my $CSV;
sub csv {
    $CSV ||= Text::CSV_XS->new({ quote_char => undef,
                                 binary => 1,
                                 auto_diag => 3,
                                 allow_loose_quotes => 1,
                                 sep_char => ',',
                                 eol => $/ });
}

my $_columns;
sub columns {
    my $csvfile = shift;
    $_columns ||= do {
        open(my $fh, '<', $csvfile) or die $!;
        my @cols = @{ csv()->getline($fh) };
        close $fh or die $!;
        for (@cols) { s/^\s+//; s/\s+$//; }
        \@cols;
    };
  #  print @{$_columns};
    return @{ $_columns };
}
