package Plack::Debugger::Panel::Dancer2::TemplateVariables;

use strict;
use warnings;

use Data::Dump qw(dump);
use Cache::FastMmap;
use Sereal::Decoder;

use parent 'Plack::Debugger::Panel::Dancer2';

sub new {
    my $class = shift;

    my %args = @_ == 1 && ref $_[0] eq 'HASH' ? %{ $_[0] } : @_;

    $args{title} ||= 'Dancer2::TemplateVariables';
    $args{'formatter'} ||= 'pass_through';

    $args{'after'} = sub {
        my ( $self, $env, $resp ) = @_;

        my $tokens  = $self->dancer2_cache_get('template_variables') || {};
        return unless $tokens;

        my $html =
          '<table><thead><tr><th>Key</th><th>Value</th></tr></thead><tbody>';

        foreach my $key ( sort keys %$tokens ) {
            $html .=
                '<tr><td>'
              . $key
              . '</td><td><pre>'
              . vardump( $tokens->{$key} )
              . '</pre></td></tr>';
        }

        $html .= '</tbody></table>';

        $self->set_result($html);
    };

    $class->SUPER::new( \%args );
}

sub vardump {
    my $scalar = shift;
    return '(undef)' unless defined $scalar;
    return "$scalar" unless ref $scalar;
    '<pre>' . Data::Dump::dump($scalar) . '</pre>';
}

1;