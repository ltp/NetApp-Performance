package NetApp::LUN;

use strict;
use warnings;

use Scalar::Util qw( weaken );
use NetApp::Aggregate::Raid;

our $VERSION 	= '0.01';
our @ATTRIBUTES = ( 'alignment', 'block-size', 'class', 'comment', 'creation-timestamp', 'is-clone',
			'is-clone-autodelete-enabled', 'is-restore-inaccessible', 'is-space-alloc-enabled',
			'is-space-reservation-enabled', 'mapped', 'multiprotocol-type', 'online', 'path',
			'prefix-size', 'qtree', 'read-only', 'serial-number', 'share-state', 'size',
			'size-used', 'staging', 'suffix-size', 'uuid', 'volume', 'vserver' );
our @COUNTERS 	= qw( avg_latency queue_full total_ops );

{
	no strict 'refs';

	foreach my $attr ( @ATTRIBUTES ) {
		( my $mattr = $attr ) =~ s/-/_/g;
		*{ __PACKAGE__ . "::$mattr" } = sub {
			my $self = shift;
			return $self->{$mattr}
		}
	}

	foreach my $counter ( @COUNTERS ) {
		*{ __PACKAGE__ . "::$counter" } = sub {
			my $self = shift;
			return $self->{__netapp}
				->object( 'lun' )
				->instance( $self->{uuid} )
				->counter( $counter )
		}
	}

}

sub new {
        my ( $class, $parent, $lun ) = @_;
        my $self = bless {}, $class;
        weaken ( $self->{__netapp} = $parent );

	$self->{name}   = $lun->child_get_string('volume');
        
        foreach my $attr ( @ATTRIBUTES ) {
                ( my $mattr = $attr ) =~ s/-/_/g;
                $self->{$mattr} = $lun->child_get_int( $attr );
	}

        $self->{object} = 'lun';

        return $self
}

sub _avg_latency {
        my $self = shift;
        return $self->{__netapp}->object( 'lun' )->instance( $self->{uuid} )->counter( 'avg_latency' )
}

1;
