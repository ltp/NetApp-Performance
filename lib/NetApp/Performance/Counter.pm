package NetApp::Performance::Counter;

use strict;
use warnings;

use lib "/usr/lib64/perl5/NetApp";

use NaServer;
use NaElement;
use Carp qw(croak);

our %ATTR = (
	name			=> 'name',
	desc			=> 'description',
	properties		=> 'properties',
	unit			=> 'unit',
	type			=> 'type',
	'privilege-level'	=> 'privilege_level',
	labels			=> 'labels'
);

{
	no strict 'refs';

	foreach my $attr ( keys %ATTR ) {
		*{ __PACKAGE__ . "::$ATTR{$attr}" } = sub {
			my $self = shift;
			return ( exists $self->{ $attr } ) ? $self->{ $attr } : undef ;
		}
	}
}

sub new {
        my ( $class, $counters ) = @_;

	my $self = bless {}, $class;

	for my $counter ( @$counters ) {
		$self->{ $counter->{name} } = ( 
			$counter->has_children
				? ( $counter->children_get )[0]->{content}
				: $counter->{content} 
			)
	}

        for my $attr ( qw( name desc properties unit privilege-level ) ) {
                $self->{$attr} || croak "Mandatory argument $attr not provided.\n";
        }

	#map { $self->{$_} = $object->{$_} } @objects;

	#map {
	#	$self->{ $_->{'name'} } = $_->{'content'}
	#} $object->children_get;
	
	
        return $self;
}

1;

__END__
$VAR1 = [
          bless( {
                   'content' => 'Disk I/O latency histogram',
                   'name' => 'desc',
                   'children' => [],
                   'attrvals' => [],
                   'attrkeys' => []
                 }, 'NaElement' ),
          bless( {
                   'content' => '',
                   'name' => 'labels',
                   'children' => [
                                   bless( {
                                            'content' => '0 - <1ms,1 - <2ms,2 - <4ms,4 - <6ms,6 - <8ms,8 - <10ms,10 - <12ms,12 - <16ms,16 - <20ms,20 - <30ms,30 - <40ms,40 - <50ms,50 - <
60ms,60 - <70ms,70 - <80ms,80 - <90ms,90 - <100ms,100 - <120ms,120 - <140ms,140 - <160ms,160 - <180ms,180 - <200ms,200 - <400ms,400 - <600ms,600 - <800ms,800 - <1000ms,1000 - <1500ms,15
00 - <2000ms,2000 - <2500ms,2500 - <3000ms,3000 - <3500ms,3500 - <4000ms,4000 - <8000ms,8000 - <12000ms,12000 - <16000ms,>16000ms',
                                            'name' => 'label-info',
                                            'children' => [],
                                            'attrvals' => [],
                                            'attrkeys' => []
                                          }, 'NaElement' )
                                 ],


$VAR1 = bless( {
                 'content' => '',
                 'name' => 'counter-info',
                 'children' => [
                                 bless( {
                                          'content' => 'Time base for disk_busy calculation',
                                          'name' => 'desc',
                                          'children' => [],
                                          'attrvals' => [],
                                          'attrkeys' => []
                                        }, 'NaElement' ),
                                 bless( {
                                          'content' => 'base_for_disk_busy',
                                          'name' => 'name',
                                          'children' => [],
                                          'attrvals' => [],
                                          'attrkeys' => []
                                        }, 'NaElement' ),
                                 bless( {
                                          'content' => 'basic',
                                          'name' => 'privilege-level',
                                          'children' => [],
                                          'attrvals' => [],
                                          'attrkeys' => []
                                        }, 'NaElement' ),
                                 bless( {
                                          'content' => 'delta,no-display',
                                          'name' => 'properties',
                                          'children' => [],
                                          'attrvals' => [],
                                          'attrkeys' => []
                                        }, 'NaElement' ),
                                 bless( {
                                          'content' => 'none',
                                          'name' => 'unit',
                                          'children' => [],
                                          'attrvals' => [],
                                          'attrkeys' => []
                                        }, 'NaElement' )
                               ],
                 'attrvals' => [],
                 'attrkeys' => []
               }, 'NaElement' );



$VAR1 = bless( {
                 'content' => '',
                 'name' => 'results',
                 'children' => [
                                 bless( {
                                          'content' => '',
                                          'name' => 'counters',
                                          'children' => [
                                                          bless( {
                                                                   'content' => '',
                                                                   'name' => 'counter-info',
                                                                   'children' => [
                                                                                   bless( {
                                                                                            'content' => 'Time base for disk_busy calculation',
                                                                                            'name' => 'desc',
                                                                                            'children' => [],
                                                                                            'attrvals' => [],
                                                                                            'attrkeys' => []
                                                                                          }, 'NaElement' ),
                                                                                   bless( {
                                                                                            'content' => 'base_for_disk_busy',
                                                                                            'name' => 'name',
                                                                                            'children' => [],
                                                                                            'attrvals' => [],
                                                                                            'attrkeys' => []
                                                                                          }, 'NaElement' ),

 							
										bless( {
                                                                                            'content' => '',
                                                                                            'name' => 'labels',
                                                                                            'children' => [
                                                                                                            bless( {
                                                                                                                     'content' => 'urgent,deadline,besteffort,background',
                                                                                                                     'name' => 'label-info',
                                                                                                                     'children' => [],
                                                                                                                     'attrvals' => [],
                                                                                                                     'attrkeys' => []
                                                                                                                   }, 'NaElement' )
                                                                                                          ],
                                                                                            'attrvals' => [],
                                                                                            'attrkeys' => []
                                                                                          }, 'NaElement' ),

