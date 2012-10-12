#!/usr/bin/perl -c

package POSIX::strftime::GNU;

=head1 NAME

POSIX::strftime::GNU - strftime with GNU extensions

=head1 SYNOPSIS

  use POSIX::strftime::GNU;
  use POSIX 'strftime';
  print POSIX::strftime('%a, %d %b %Y %T %z', localtime);

command line:

  C:\> set PERL_ANYEVENT_LOG=filter=debug
  C:\> perl -MPOSIX::strftime::GNU -MAnyEvent -e "AE::cv->send"

=head1 DESCRIPTION

This is a wrapper for L<POSIX::strftime|POSIX/strftime> which implements more
character sequences compatible with GNU systems.

It can be helpful if you run some software on operating system where these
extensions, especially C<%z> sequence, are not supported, i.e. on Microsoft
Windows. On such system some software can work incorrectly, i.e. logging for
L<Plack> and L<AnyEvent> modules might be broken.

The XS module is used if compiler is available and can module can be loaded.
The XS is mandatory if C<PERL_POSIX_STRFTIME_GNU_XS> environment variable is
true.

The PP module is used when XS module can not be loaded or
C<PERL_POSIX_STRFTIME_GNU_PP> environment variable is true.

=for readme stop

=cut


use 5.006;
use strict;
use warnings;

our $VERSION = '0.02';

use Carp ();
use POSIX ();

=head1 FUNCTIONS

=over

=item $str = strftime (@time)

This is replacement for L<POSIX::strftime|POSIX/strftime> function.

=back

=cut

my $xs_loaded;

if ($ENV{PERL_POSIX_STRFTIME_GNU_XS} or not $ENV{PERL_POSIX_STRFTIME_GNU_PP}) {
    $xs_loaded = eval {
        require POSIX::strftime::GNU::XS;
        no warnings 'once';
        *strftime = *POSIX::strftime::GNU::XS::strftime;
        1;
    };
    die $@ if $@ and $ENV{PERL_POSIX_STRFTIME_GNU_XS};
};

if (not $xs_loaded) {
    require POSIX::strftime::GNU::PP;
    no warnings 'once';
    *strftime = *POSIX::strftime::GNU::PP::strftime;
};

sub import {
    my ($class) = @_;
    *POSIX::strftime = *strftime;
    return 1;
};

1;


=for readme continue

=head1 BUGS

XS extension does not implement all character sequences in C code, yet,
especially C<%z> and C<%Z> and requires some Perl code for its job. It means
that it is as slow on Microsoft Windows as PP extension.

If you find the bug or want to implement new features, please report it at
L<https://github.com/dex4er/perl-POSIX-strftime-GNU/issues>

The code repository is available at
L<http://github.com/dex4er/perl-POSIX-strftime-GNU>

=head1 AUTHOR

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2012 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See L<http://dev.perl.org/licenses/artistic.html>
