package NetApp::Aggregate;

use strict;
use warnings;

use Scalar::Util qw( weaken );
use NetApp::Aggregate::Raid;

our $VERSION 	= '0.01';
our @ATTRIBUTES = qw( name raid );
our @COUNTERS 	= qw( user_reads user_read_blocks user_write_blocks total_transfers );

{
	no strict 'refs';

	foreach my $attr ( @ATTRIBUTES ) {
		*{ __PACKAGE__ . "::$attr" } = sub {
			my $self = shift;
			return $self->{$attr}
		}
	}

	foreach my $counter ( @COUNTERS ) {
		*{ __PACKAGE__ . "::$counter" } = sub {
			my $self = shift;
			return $self->{__netapp}
				->object( 'aggregate' )
				->instance( $self->{name} )
				->counter( 'user_reads' )
		}
	}

}

sub new {
	my ( $class, $parent, $aggr ) = @_;
	my $self = bless {}, $class;
	weaken ( $self->{__netapp} = $parent );

	$self->{name}	= $aggr->child_get_string('aggregate-name');
	$self->{raid}	= NetApp::Aggregate::Raid->new( $aggr->child_get('aggr-raid-attributes') );
	$self->{object} = 'aggregate';

	return $self
}

sub _user_reads {
	my $self = shift;
	return $self->{__netapp}->object( 'aggregate' )->instance( $self->{name} )->counter( 'user_reads' )
}

1;
