package NetApp::Performance;

use strict;
use warnings;

use lib "/usr/lib64/perl5/NetApp";

use NaServer;
use NaElement;
use NetApp::Performance::Object;
use NetApp::Performance::Counter;
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
	#print Dumper( $perf_obj );
	$perf_obj	= $s->invoke_elem( $perf_obj );
	
        if ( $perf_obj->results_status() eq 'failed' ) {
                print( $perf_obj->results_reason() . "\n" );
                exit(-2)
        }
	
	#print Dumper( $perf_obj );
}

sub add_elements($$$$) {
        my $data_in      = shift;
        my $in_name      = shift;
        my $in_name_type = shift;
        my $na_array_ref = shift;

        my $input_name = NaElement->new($in_name);

        tellus(2, "Adding: $in_name of $in_name_type type:");
        my $na_array_i;
        foreach $na_array_i (@$na_array_ref) {
                tellus(2, "   $na_array_i: ");
                $input_name->child_add_string($in_name_type, $na_array_i);
        }
        $data_in->child_add($input_name);
}

