#!/usr/bin/perl

use strict;
use warnings;

use NetApp::Performance;

my $server	= 'AA.BB.CC.DD';
my $username	= 'username';
my $password	= 'passw0rd';

my $n = NetApp::Performance->new(
				server	 => $server,
				username => $username,
				password => $password )
	|| die "Couldn't connect to server: $!\n";

print "="x100 . "\nPrinting user read statistics for aggregate controller01_aggr0\n" . "="x100 . "\n\n";
headers();

my $pr	= 'NA';
my $t	= 0;
my $c	= 1;

while ( sleep 5 ) {
	my $r = $n->object('aggregate')->instance('controller01_aggr0')->counter( 'user_reads' );

	if ( $pr eq 'NA' ) { $pr = $r; next }

	$t += ( $r - $pr );
	printf ( "%20s%20s%20.3f%20.3f\n", $r, $t, ( ( $r - $pr ) / 5 ) , $t / ( 5 * $c++ ) );
	$pr = $r;
	headers() if ( $c % 20 == 0 )
}

sub headers {
	printf ( "%20s%20s%20s%20s\n", "User reads-5s", "Total reads", "Avg Reads-5s", "Avg Reads" );
	printf ( "%20s%20s%20s%20s\n", "=============", "===========", "============", "=========" );
}

# Example output
#
#someone@tty1:somebox:~$ perl list_aggregate_reads.pl 
#====================================================================================================
#Printing user read statistics for aggregate controller01_aggr0
#====================================================================================================
#
#       User reads-5s         Total reads        Avg Reads-5s           Avg Reads
#       =============         ===========        ============           =========
#           141799701                   4               0.800               0.800
#           141799705                   8               0.800               0.800
#           141799709                  12               0.800               0.800
#           141799714                  17               1.000               0.850
#           141799718                  21               0.800               0.840
#           141799722                  25               0.800               0.833
#           141799726                  29               0.800               0.829
#           141799730                  33               0.800               0.825
#           141799734                  37               0.800               0.822
#           141799738                  41               0.800               0.820
#           141799740                  43               0.400               0.782
#           141799744                  47               0.800               0.783
#           141799748                  51               0.800               0.785
#           141799752                  55               0.800               0.786
#           141799756                  59               0.800               0.787
#           141799760                  63               0.800               0.787
#           141799764                  67               0.800               0.788
#           141799768                  71               0.800               0.789
#           141799773                  76               1.000               0.800
#       User reads-5s         Total reads        Avg Reads-5s           Avg Reads
#       =============         ===========        ============           =========
#           141799777                  80               0.800               0.800
#           141799781                  84               0.800               0.800
#           141799783                  86               0.400               0.782
# ...
#
