package NetApp::Performance::Object;

use strict;
use warnings;

use lib "/usr/lib64/perl5/NetApp";

use NaServer;
use NaElement;
use NetApp::Performance::Counter;
use NetApp::Performance::Instance;
use Carp qw(croak);
use Scalar::Util qw(weaken);

sub new {
        my ( $class, $object, $conn ) = @_;

	my $self = bless {}, $class;
	weaken ( $self->{__conn} = $conn );
	map { 
		$self->{ $_->{'name'} } = $_->{'content'}
	} $object->children_get;
	
	
        return $self;
}

sub name 		{ return $_[0]->{'name'} 		}

sub description		{ return $_[0]->{'description'} 	}

sub privilege_level	{ return $_[0]->{'privilege-level'} 	}

sub counters_like {
	my ( $self, $regex ) = @_;

	return grep { $_->{name} =~ /$regex/i } $self->counters
}

sub counters {
	my $self = shift;

	my $res	= $self->{__conn}->invoke( 'perf-object-counter-list-info', 'objectname', $self->{name} );

        croak( $res->results_reason . "\n" ) if ( $res->results_status eq 'failed' );

        return map {
                NetApp::Performance::Counter->new( $_->{children} )
        } $res->child_get( 'counters' )->children_get;
}

sub instance {
	my ( $self, $instance ) = @_;
	
	my ( $res ) = grep { $_->name eq $instance || $_->uuid eq $instance } $self->instances;

	return $res
}

sub instances {
	my $self = shift;

	my $res	= $self->{__conn}->invoke( 'perf-object-instance-list-info-iter', 'objectname', $self->{name} );

        croak( $res->results_reason . "\n" ) if ( $res->results_status eq 'failed' );

        return map {
                NetApp::Performance::Instance->new( $self->{__conn}, $self->{name}, $_->{children} )
        } $res->child_get( 'attributes-list' )->children_get;
}

1;

__END__
	  bless( {
		   'content' => '',
		   'name' => 'object-info',
		   'children' => [
				   bless( {
					    'content' => 'These counters report activity from the CIFS Witness protocol.',
					    'name' => 'description',
					    'children' => [],
					    'attrvals' => [],
					    'attrkeys' => []
					  }, 'NaElement' ),
				   bless( {
					    'content' => 'instance_uuid',
					    'name' => 'get-instances-preferred-counter',
					    'children' => [],
					    'attrvals' => [],
					    'attrkeys' => []
					  }, 'NaElement' ),
				   bless( {
					    'content' => 'witness:vserver',
					    'name' => 'name',
					    'children' => [],
					    'attrvals' => [],
					    'attrkeys' => []
					  }, 'NaElement' ),
				   bless( {
					    'content' => 'advanced',
					    'name' => 'privilege-level',
					    'children' => [],
					    'attrvals' => [],
					    'attrkeys' => []
					  }, 'NaElement' )

