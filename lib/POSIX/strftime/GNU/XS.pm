#!/usr/bin/perl -c

package POSIX::strftime::GNU::XS;

=head1 NAME

POSIX::strftime::GNU::XS - XS extension for POSIX::strftime::GNU

=head1 SYNOPSIS

  $ export PERL_POSIX_STRFTIME_GNU_XS=1

=head1 DESCRIPTION

This is XS extension for POSIX::strftime which implements more character
sequences compatible with GNU systems.

=cut


use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

use POSIX::strftime::GNU::Util;

use Carp ();
use Config;
use POSIX ();

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

my %format = (
    $^O eq 'MSWin32' ? (h => sub { '%b' }) : (),
    $^O eq 'MSWin32' ? (r => sub { '%I:%M:%S %p' }) : (),
    $^O eq 'MSWin32' ? (s => sub { Time::Local::timegm(@_) }) : (),
    z => \&POSIX::strftime::GNU::Util::tzoffset,
    Z => \&POSIX::strftime::GNU::Util::tzname,
);

my $formats = join '', sort keys %format;

if ($^O eq 'MSWin32' or not $Config{d_tm_tm_zone}) {
    require POSIX::strftime::GNU::PP;

    *strftime = sub {
        my ($fmt, @t) = @_;

        Carp::croak 'Usage: POSIX::strftime(fmt, sec, min, hour, mday, mon, year, wday = -1, yday = -1, isdst = -1)'
            unless @t >= 6 and @t <= 9;

        if ($^O eq 'MSWin32') {
            $fmt =~ s/%E([CcXxYy])/%$1/;
            $fmt =~ s/%O([deHIMmSUuVWwy])/%$1/;
        };
        $fmt =~ s/%([$formats])/$format{$1}->(@t)/ge;

        return xs_strftime($fmt, @t);
    };
}
else {
    *strftime = *xs_strftime;
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
