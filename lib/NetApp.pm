package NetApp;

use strict;
use warnings;

use lib "/usr/lib64/perl5/NetApp";

use NaServer;
use NaElement;
use NetApp::LUN;
use NetApp::Aggregate;
use NetApp::Performance::Object;
use Carp qw( croak );

our $VERSION = '0.01';

sub new {
	my ( $class, %args ) = @_;
	my $self = bless {}, $class;

	for my $att ( qw( server username password ) ) {
		$args{$att} || croak "Mandatory argument $att not provided.\n";
		$self->{$att} = $args{$att}
	}
	$self->connect;

	return $self
}

sub connect {
	my $self = shift;
	
	$self->{__conn}	= NaServer->new( $self->{server}, 1, 0 );
        $self->{__conn}->set_transport_type( "HTTP" );
        $self->{__conn}->set_style( "LOGIN" );
        $self->{__conn}->set_admin_user( $self->{username}, $self->{password} );

	return 1
}

sub aggr {
	my ( $self, %args ) = @_;

	( exists $args{'name'} || exists $args{'uuid'} ) || return undef;

}

sub get_aggrs {
	my $self = shift;
	my $res = $self->{__conn}->invoke( 'aggr-get-iter' );
	my @res = map { NetApp::Aggregate->new( $self, $_ ) } @{ $res->{children}->[0]->{children} };

	return @res	
}

sub get_luns {
	my $self = shift;
	my $res = $self->{__conn}->invoke( 'lun-get-iter' );
	my @res = map { NetApp::LUN->new( $self, $_ ) } @{ $res->{children}->[0]->{children} };

	return @res	
}

sub object {
	my ( $self, $object ) = @_;

	my ( $res ) = grep { $_->{name} eq $object } $self->get_perf_objects;

	return $res
}

sub get_perf_objects {
	my $self = shift;

	my $res = $self->{__conn}->invoke_elem( NaElement->new('perf-object-list-info') );

	croak( $res->results_reason . "\n" ) if ( $res->results_status eq 'failed' );

	return map {  
		NetApp::Performance::Object->new( $_, $self->{__conn} )
	} $res->child_get( 'objects' )->children_get;
}

sub get_perf_object_counters {
        my ( $self, $object ) = @_;

	my $res = $self->{__conn}->invoke( 'perf-object-counter-list-info', 'objectname', $object );
	
	croak( $res->results_reason . "\n" ) if ( $res->results_status eq 'failed' );

	return map { 
		NetApp::Performance::Counter->new( $_->{children} ) 
	} $res->child_get( 'counters' )->children_get;
}

sub get_perf_object_instances {
	my ( $self, $object ) = @_;

#	my $res = $self->__{conn}->invoke( 'perf-object-instance-list-info-iter', 
}

sub _get_object_instance_list_iter {
        my ( $s, $o ) = @_;

        my $perf_obj	= NaElement->new("perf-object-instance-list-info-iter");
	$perf_obj->child_add_string( 'objectname', $o );
	$perf_obj	= $s->invoke_elem( $perf_obj );

        if ( $perf_obj->results_status() eq 'failed' ) {
                print( $perf_obj->results_reason() . "\n" );
                exit(-2)
        }

	print Dumper( $perf_obj );
}

sub get_object_instances {
        my ( $s, $o, $u ) = @_;

        my $perf_obj	= NaElement->new("perf-object-get-instances");
	$perf_obj->child_add_string( 'objectname', $o );
        my $uuids	= NaElement->new("instance-uuids");
	$uuids->child_add_string( 'instance-uuid', $u );
	$perf_obj->child_add( $uuids );
	$perf_obj	= $s->invoke_elem( $perf_obj );
	
        if ( $perf_obj->results_status() eq 'failed' ) {
                print( $perf_obj->results_reason() . "\n" );
                exit(-2)
        }
	
}

1;

__END__

=head1 NAME

NetApp - Perl  interface to NetApp CDOT devices

=head1 SYNOPSIS

	use NetApp::Performance;

	my $netapp = NetApp::Performance->new(
					server	 => 'AA.BB.CC.DD';
					username => 'username',
					password => 'Passw0rd' )
		|| die "Couldn't connect to server: $!\n";

	
	# Get the cluster aggregates as a list of NetAPP::Aggregate objects.
	my @aggr = $netapp->get_aggrs;

	# Print the user_read_blocks and user_write_blocks for each aggregate
	foreach my $aggr ( @aggrs ) {
		printf ( "%-20s%-20d%-20d", 
			$aggr->name,
			$aggr->user_read_blocks,
			$aggr->user_write_blocks
		);
	}

	# Get a list of offline luns
	map { print $_->name . "\n" if ( $_->online eq 'flase' } $netapp->luns;


=head1 ABOUT

This module (and other modules within the NetApp space) extend 

=head1 METHODS

=head2 new ( %ARGS )

Constructor - creates a new NetApp

=head1 AUTHOR

Luke Poskitt, C<< <ltp at cpan dot org > >>

=cut
