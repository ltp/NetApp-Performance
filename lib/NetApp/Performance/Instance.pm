package NetApp::Performance::Instance;

use strict;
use warnings;

use lib "/usr/lib64/perl5/NetApp";

use NaServer;
use NaElement;
use Scalar::Util qw(weaken);
use Carp qw(croak);

{
	no strict 'refs';

	foreach my $attr ( qw( name uuid ) ) {
		*{ __PACKAGE__ . "::$attr" } = sub {
			my $self = shift;
			return ( exists $self->{ $attr } ) ? $self->{ $attr } : undef ;
		}
	}
}

sub new {
        my ( $class, $conn, $object, $instances ) = @_;

	my $self = bless {}, $class;
	$self->{__object} = $object;
	weaken ( $self->{__conn} = $conn );

	for my $inst ( @$instances ) {
		$self->{ $inst->{name} } = ( 
			$inst->has_children
				? ( $inst->children_get )[0]->{content}
				: $inst->{content} 
			)
	}

        for my $attr ( qw( name uuid ) ) {
                $self->{$attr} || croak "Mandatory argument $attr not provided.\n";
        }

        return $self;
}

sub counter {
	my ( $self, $counter ) = @_;

        my $xml = NaElement->new("perf-object-get-instances");
        $xml->child_add_string( 'objectname', $self->{__object} );
        my $instances = NaElement->new("instances");
        $instances->child_add_string( 'instance', $self->{name} );
	my $counters = NaElement->new('counters');
	$counters->child_add_string('counter', $counter );
        $xml->child_add( $instances );
        $xml->child_add( $counters );
        my $res = $self->{__conn}->invoke_elem( $xml );

	croak( $res->results_reason . "\n" ) if ( $res->results_status eq 'failed' );

	$res = $res	->child_get( 'instances' )
			->child_get('instance-data' )
			->child_get('counters' )
			->child_get('counter-data' )
			->child_get_int('value' )
			;

	return $res	
}

1;

__END__
#   bless( {
#	    'content' => 'aggregate',
#	    'name' => 'name',
#	    'children' => [],
#	    'attrvals' => [],
#	    'attrkeys' => []
#	  }, 'NaElement' ),
#   bless( {
#	    'content' => 'aggregate',
#	    'name' => 'uuid',
#	    'children' => [],
#	    'attrvals' => [],
#	    'attrkeys' => []
#	  }, 'NaElement' )

