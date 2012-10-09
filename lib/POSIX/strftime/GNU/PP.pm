#!/usr/bin/perl -c

package POSIX::strftime::GNU::PP;

=head1 NAME

POSIX::strftime::GNU::PP - Pure-Perl extension for POSIX::strftime::GNU

=head1 SYNOPSIS

  $ export PERL_POSIX_STRFTIME_GNU_PP=1

=head1 DESCRIPTION

This is PP extension for POSIX::strftime which implements more character
sequences compatible with GNU systems.

=cut


use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

use POSIX::strftime::GNU::Util;

use Carp ();
use POSIX ();

my %format = (
    C => sub { 19 + int $_[5] / 100 },
    D => sub { '%m/%d/%y' },
    e => sub { sprintf '%2d', $_[3] },
    F => sub { '%Y-%m-%d' },
    G => \&POSIX::strftime::GNU::Util::isoyearnum,
    g => sub { sprintf '%02d', POSIX::strftime::GNU::Util::isoyearnum(@_) % 100 },
    h => sub { '%b' },
    k => sub { sprintf '%2d', $_[2] },
    l => sub { sprintf '%2d', $_[2] % 12 + ($_[2] % 12 == 0 ? 12 : 0) },
    n => sub { "\n" },
    P => sub { lc POSIX::strftime::GNU::Util::strftime('%p', @_) },
    r => sub { '%I:%M:%S %p' },
    R => sub { '%H:%M' },
    s => sub { POSIX::mktime(@_) },
    t => sub { "\t" },
    T => sub { '%H:%M:%S' },
    u => sub { my $dw = POSIX::strftime::GNU::Util::strftime('%w', @_); $dw += ($dw == 0 ? 7 : 0); $dw },
    V => \&POSIX::strftime::GNU::Util::isoweeknum,
    z => \&POSIX::strftime::GNU::Util::tzoffset,
    Z => \&POSIX::strftime::GNU::Util::tzname,
);

my $formats = join '', sort keys %format;

sub strftime ($@) {
    my ($fmt, @t) = @_;

    Carp::croak 'Usage: POSIX::strftime(fmt, sec, min, hour, mday, mon, year, wday = -1, yday = -1, isdst = -1)'
        unless @t >= 6 and @t <= 9;

    $fmt =~ s/%E([CcXxYy])/%$1/;
    $fmt =~ s/%O([deHIMmSUuVWwy])/%$1/;
    $fmt =~ s/%([$formats])/$format{$1}->(@t)/ge;

    return POSIX::strftime::GNU::Util::strftime($fmt, @t);
};

1;


=head1 SEE ALSO

L<POSIX::strftime::GNU>.

=head1 AUTHOR

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2012 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See L<http://dev.perl.org/licenses/artistic.html>
