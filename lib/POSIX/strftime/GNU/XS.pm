package POSIX::strftime::GNU::XS;

=head1 NAME

POSIX::strftime::GNU::XS - XS extension for POSIX::strftime

=head1 SYNOPSIS

  $ export PERL_POSIX_STRFTIME_GNU_XS=1

=head1 DESCRIPTION

This is XS extension for POSIX::strftime which implements more character
sequences compatible with GNU systems.

=for readme stop

=cut


use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

use Carp ();
use Config;
use POSIX ();

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

if ($Config{d_tm_tm_zone}) {
    *strftime = *xs_strftime;
}
else {
    require POSIX::strftime::GNU::PP;

    my %format = (
        z => $POSIX::strftime::GNU::PP::tzoffset,
        Z => $POSIX::strftime::GNU::PP::offset2zone,
    );

    *strftime = sub {
        my ($fmt, @t) = @_;

        Carp::croak 'Usage: POSIX::strftime(fmt, sec, min, hour, mday, mon, year, wday = -1, yday = -1, isdst = -1)'
            unless @t >= 6 and @t <= 9;

        $fmt =~ s/%([zZ])/$format{$1}->(@t)/ge;

        return xs_strftime($fmt, @t);
    };
};

1;


=for readme continue

=head1 SEE ALSO

L<POSIX::strftime::GNU>.

=head1 AUTHOR

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2012 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See L<http://dev.perl.org/licenses/artistic.html>
