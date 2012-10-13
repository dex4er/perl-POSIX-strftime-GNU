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

our $VERSION = '0.02';

use POSIX::strftime::GNU::PP;

use Carp ();
use Config;
use POSIX ();

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

my %format = (
    $^O eq 'MSWin32' ? (h => sub { '%b' }) : (),
    $^O eq 'MSWin32' ? (r => sub { '%I:%M:%S %p' }) : (),
    $^O eq 'MSWin32' ? (s => sub { Time::Local::timegm(@_) }) : (),
    z => \&POSIX::strftime::GNU::PP::tzoffset,
    Z => \&POSIX::strftime::GNU::PP::tzname,
);

my $formats = join '', sort keys %format;

=head1 FUNCTIONS

=over

=item $str = strftime ($format, @time)

This is replacement for L<POSIX::strftime|POSIX/strftime> function.

=back

=cut

no warnings 'once';
*strftime = *xs_strftime;


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
