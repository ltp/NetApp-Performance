#!/usr/bin/perl

#
# Implements the calculations in section 4.2 - Using LUN counters - of the Performance 
# Management Design Guide (https://communities.netapp.com/servlet/JiveServlet/previewBody/1044-102-2-7517/Performance_Management_DesignGuide.pdf)
#
# i.e. 
#	Queuefull/sec = (queuefull rate at time t2 - queuefull rate at t1) / (t2 - t1)
#	avg_latency = (avg_latency at time t2 - avg_latency at time t1) / (total_ops at time t2 - total_ops at time t1) 
#
# Example output;
#
# ===========================================================================
# Lun performance counters
# ===========================================================================
#
# Lun                      Average latency (ms)     Queue full rate (-s)
# ====================     ====================     ====================
# Lun1                     0.368                    0.000
# Lun2                     2.420                    0.000
# Lun3                     0.000                    0.000
# Lun4                     0.299                    0.000
# ...

BEGIN { unshift @INC, '.' };

use strict;
use warnings;

use NetApp;

my $c;
my $duration = 30;
my $n = NetApp->new(
		server	 => 'AA.BB.CC.DD',
		username => 'username',
		password => 'passw0rd' )
	|| die "Couldn't connect to target: $!\n";

print "="x75 . "\n Lun performance counters\n" . "="x75 . "\n";

foreach my $lun ( $n->get_luns ) {
	next if ( $lun->mapped eq 'false' );

	my $total_ops_t1	= $lun->total_ops;
	my $avg_latency_t1	= $lun->avg_latency;
	my $queue_full_t1	= $lun->queue_full;
	sleep $duration;

	my $total_ops_t2	= $lun->total_ops;
	my $avg_latency_t2	= $lun->avg_latency;
	my $queue_full_t2	= $lun->queue_full;

	my $avg_latency = ( ( $total_ops_t2 - $total_ops_t1 ) 
				? ( ( $avg_latency_t2 - $avg_latency_t1 ) / ( $total_ops_t2 - $total_ops_t1 ) )
				: 0 );

	my $queue_full	= ( ( $queue_full_t2 - $queue_full_t1 ) / $duration );

	headers() if ( $c++ %20 == 0 )
	printf ( "%-25s%-25.3f%-25.3f\n", $lun->volume, $avg_latency, $queue_full );
}

sub headers {
	printf ( "\n%-25s%-25s%-25s\n", "Lun", "Average latency (ms)", "Queue full rate (-s)" );
	printf ( "%-25s%-25s%-25s\n", "====================", "====================", "====================" );
}
