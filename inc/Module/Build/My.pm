package Module::Build::My;

use 5.006;

use strict;
use warnings;

use base 'Module::Build';

use Config;
use ExtUtils::CBuilder;

my $cc = ExtUtils::CBuilder->new;

my %objs;

sub ACTION_xs_config {
    my $self = shift;
    return if $self->args('pp');

    my $config_h = 'xs/xs_config.h';
    $self->add_to_cleanup($config_h);

    require ExtUtils::CChecker;

    my $chk = ExtUtils::CChecker->new(
        defines_to => $config_h,
    );

    foreach my $kw (qw( __restrict __restrict__ _Restrict restrict )) {
        last if $chk->try_compile_run(
            define => "restrict $kw",
            source => << "EOF" );
typedef int * int_ptr;
int foo (int_ptr $kw ip) {
    return ip[0];
}
int
main ()
{
    int s[1];
    int * $kw t = s;
    t[0] = 0;
    return foo(t);
    return 0;
}
EOF
    }

    $chk->try_compile_run(
        define => 'HAVE_DECL_TZNAME 1',
        source => << "EOF" );
#include <time.h>
int main () {
#ifndef tzname
    (void) tzname;
#endif
    return 0;
}
EOF

    foreach my $m (qw( E O 1 )) {
        $chk->try_compile_run(
            define => "HAVE_STRFTIME_${m}_MODIFIER 1",
            source => << "EOF" );
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int
main()
{
    char outstr[200];
    time_t t;
    struct tm *tmp;

    t = time(NULL);
    tmp = localtime(&t);
    if (tmp == NULL)
        exit(1);
    if (strftime(outstr, sizeof(outstr), "%${m}y", tmp) == 0)
        exit(1);
    if (strncmp(outstr, "%${m}y", 4) == 0 || strncmp(outstr, "y", 4) == 0)
        exit(1);
    return 0;
}
EOF
    };

    return 1;
};

sub ACTION_gnulib {
    my $self = shift;
    return if $self->args('pp');

    $self->depends_on('xs_config');

    if (my $o = $cc->object_file(my $c = 'xs/time_r.c')) {
        $self->add_to_cleanup($o);
        $cc->compile(source => $c, object_file => $o, include_dirs => 'xs', extra_compiler_flags => $self->extra_compiler_flags)
            unless $self->up_to_date($c, $o);
        push @{$self->{properties}{objects}}, $o;
    }

    if (my $o = $cc->object_file(my $c = 'xs/gnu_strftime.c')) {
        $self->add_to_cleanup($o);
        $cc->compile(source => $c, object_file => $o, include_dirs => 'xs', extra_compiler_flags => $self->extra_compiler_flags)
            unless $self->up_to_date($c, $o);
        push @{$self->{properties}{objects}}, $o;
    }

    return 1;
};

sub ACTION_code {
    my $self = shift;
    $self->depends_on('gnulib');
    return $self->SUPER::ACTION_code(@_);
};

1;
