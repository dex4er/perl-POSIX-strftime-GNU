# NAME

POSIX::strftime::GNU - strftime with GNU extensions

# SYNOPSIS

    use POSIX::strftime::GNU;
    use POSIX 'strftime';
    print POSIX::strftime('%a, %d %b %Y %T %z', localtime);

command line:

    C:\> set PERL_ANYEVENT_LOG=filter=debug
    C:\> perl -MPOSIX::strftime::GNU -MAnyEvent -e "AE::cv->send"

# DESCRIPTION

This is a wrapper for [POSIX::strftime](http://search.cpan.org/perldoc?POSIX#strftime) which implements more
character sequences compatible with GNU systems.

It can be helpful if you run some software on operating system where these
extensions, especially `%z` sequence, are not supported, i.e. on Microsoft
Windows. On such system some software can work incorrectly, i.e. logging for
[Plack](http://search.cpan.org/perldoc?Plack) and [AnyEvent](http://search.cpan.org/perldoc?AnyEvent) modules might be broken.

The XS module is used if compiler is available and can module can be loaded.
The XS is mandatory if `PERL_POSIX_STRFTIME_GNU_XS` environment variable is
true.

The PP module is used when XS module can not be loaded or
`PERL_POSIX_STRFTIME_GNU_PP` environment variable is true.

# FUNCTIONS

- $str = strftime (@time)

This is replacement for [POSIX::strftime](http://search.cpan.org/perldoc?POSIX#strftime) function.

# BUGS

XS extension does implement all character sequences in C code, yet, especially
`%z` and `%Z` and requires some Perl code for its job. It means that it is
as slow on Microsoft Windows as PP extension.

If you find the bug or want to implement new features, please report it at
[https://github.com/dex4er/perl-POSIX-strftime-GNU/issues](https://github.com/dex4er/perl-POSIX-strftime-GNU/issues)

The code repository is available at
[http://github.com/dex4er/perl-POSIX-strftime-GNU](http://github.com/dex4er/perl-POSIX-strftime-GNU)

# AUTHOR

Piotr Roszatycki <dexter@cpan.org>

# LICENSE

Copyright (c) 2012 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See [http://dev.perl.org/licenses/artistic.html](http://dev.perl.org/licenses/artistic.html)
