#!/usr/bin/perl


use strict;
use warnings;

use NetApp;
use Data::Dumper;

my $n = NetApp->new(
		server	 => 'AA.BB.CC.DD',
		username => 'username',
		password => 'passw0rd' )
	|| die "Couldn't connect to server: $!\n";

my $interval = 60;

print "="x50 . "\n";

foreach my $aggr ( $n->get_aggrs ) {
	next if $aggr->raid->has_local_root eq 'true';

	my $dc 		= $aggr->raid->disk_count;
	my $ttr_1 	= $aggr->total_transfers;
	my $urb_1 	= $aggr->user_read_blocks;
	my $uwb_1	= $aggr->user_write_blocks;
	my $trw_1	= $urb_1 + $uwb_1;
	sleep $interval;
	my $ttr_2 	= $aggr->total_transfers;
	my $urb_2 	= $aggr->user_read_blocks;
	my $uwb_2	= $aggr->user_write_blocks;
	my $trw_2	= $urb_2 + $uwb_2;

	# Total_transfers rate = ( total_transfers at t2 - total transfers at t1)/(t2 - t1)
	#
	# Total MB-s of read/write data = ( ( user_read_blocks + user_write_blocks at t2 ) - 
	# 					( user_read_blocks + user_write_blocks at t1 ) ) * 64 
	# 					/ ( ( t2 - t1 ) * 1024 )
	#
	# IOPS per disk = ( total_transfers_rate ) / ( disk_count )
	#
	# Throughput per disk = ( Total MB-s of disk or read/write data ) / ( disk_count )

	my $ttr = ( $ttr_2 - $ttr_1 ) / $interval;
	my $trw = ( ( $trw_2 - $trw_1 ) * 64 ) / ( $interval * 1024 );
	my $ipd = $ttr / $dc;
	my $tpd = $trw / $dc;

	printf( "Name:%40s\nDisk count:%40s\nTotal transfer rate:%40s\nTotal MB-s of read/write data:%40s\nIOPS per disk:%40s\nThroughput per disk:%40s\n",
		$aggr->name, $aggr->raid->disk_count, $ttr, $trw, $ipd, $tpd );
	#printf( "ttr_1:%40s\nurb_1:%40s\nuwb_1:%40s\ntrw_1:%40s\nttr_2:%40s\nurb_2:%40s\nuwb_2:%40s\ntrw_2:%40s\n",
	#	$ttr_1, $urb_1, $uwb_1, $trw_1, $ttr_2, $urb_2, $uwb_2, $trw_2 );
	print "="x50 . "\n";
}

