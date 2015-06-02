package NetApp::Aggregate::Raid;

use strict;
use warnings;

our $VERSION	= '0.01';
our @ATTRIBUTES	= ( 'disk-count', 'has-local-root' );

{
	no strict 'refs';

	foreach my $attr ( @ATTRIBUTES ) {
		( my $mattr = $attr ) =~ s/-/_/g;

		*{ __PACKAGE__ . "::$mattr" } = sub {
			my $self = shift;
			return $self->{$mattr}
		}
	}
}

sub new {
	my ( $class, $raid ) = @_;
	my $self = bless {}, $class;

	foreach my $attr ( @ATTRIBUTES ) {
		( my $mattr = $attr ) =~ s/-/_/g;
		$self->{$mattr} = $raid->child_get_int( $attr );
	}

	return $self
}

1;
