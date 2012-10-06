package POSIX::strftime::GNU;

=head1 NAME

POSIX::strftime::GNU - Skeleton for new modules

=head1 SYNOPSIS

This is a skeleton useful for new modules which are built with
L<Module::Builder>.

The C<master> branch contains the versioned files without all automaticly
generated content and the C<cpan> branch contains the files which are
distributed as CPAN package.

=for readme stop

=cut


use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

use POSIX;

eval {
    require XSLoader;
    my $pkg = __PACKAGE__ . '::XS';
    XSLoader::load($pkg, $VERSION);
    no strict 'refs';
    no warnings;
    *strftime = *{$pkg . '::strftime'};
} or do {
    *strftime = sub { die 'Not implemented'; };
};

sub import {
    my ($class) = @_;
    no strict 'refs';
    *POSIX::strftime = *strftime;
};

=head1 METHODS

=over

=item hello

Prints "Hello world!" message.

=back

=cut

sub hello {
    print "Hello world!\n";
    return;
};

1;


=for readme continue

=head1 PREREQUISITES

For distribution archive: 

=over 2

=item *

L<Module::Build>

=item *

L<Pod::Readme> (if C<create_readme> is used)

=item *

L<Software::License> (if C<create_license> is used)

=item *

L<Module::Signature> (if C<sign> is used)

=back

For extra tests (called as C<prove -Ilib xt>)

=over 2

=item *

L<Test::CheckChanges>

=item *

L<File::Slurp>

=item *

L<Readonly>

=item *

L<Test::Distribution>

=item *

L<Test::Kwalitee>

=item *

L<Test::Perl::Critic>

=item *

L<Test::Pod>

=item *

L<Test::Pod::Coverage>

=item *

L<Test::Spelling>

=item *

L<Test::Signature>

=back

=head1 SEE ALSO

L<Module::Build>.

=head1 BUGS

If you find the bug or want to implement new features, please report it at
L<https://github.com/dex4er/perl-DEXTER-Module-Skeleton/issues>

The code repository is available at
L<http://github.com/dex4er/perl-DEXTER-Module-Skeleton>

=head1 AUTHOR

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2012 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See L<http://dev.perl.org/licenses/artistic.html>
