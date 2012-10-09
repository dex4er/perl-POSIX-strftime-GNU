package Module::Build::My;

use 5.006;

use strict;
use warnings;

use base 'Module::Build';

use Config;
use ExtUtils::CBuilder;

my $cc = ExtUtils::CBuilder->new;

my %objs;

sub ACTION_config_gnulib {
    my $self = shift;
    return if $self->args('pp');

    my $config_h = 'gnulib/config.h';
    $self->add_to_cleanup($config_h);

    require ExtUtils::CChecker;

    my $chk = ExtUtils::CChecker->new(
        defines_to => $config_h,
    );

    foreach my $func (qw( localtime_r gmtime_r )) {
        $chk->define(sprintf 'HAVE_%s', uc($func))
            if $Config{"d_$func"};
    };

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
        define => "HAVE_DECL_TZNAME 1",
        source => << "EOF" );
#include <time.h>
int main () {
#ifndef tzname
    (void) tzname;
#endif
    return 0;
}
EOF

    $chk->define('my_strftime gnu_strftime');

    return 1;
};

sub ACTION_gnulib {
    my $self = shift;
    return if $self->args('pp');

    $self->depends_on("config_gnulib");

    if (my $o = $cc->object_file(my $c = 'gnulib/lib/time_r.c')) {
        $self->add_to_cleanup($o);
        $cc->compile(source => $c, object_file => $o, include_dirs => [qw( gnulib gnulib/lib )], extra_compiler_flags => $self->extra_compiler_flags)
            unless $self->up_to_date($c, $o);
        $objs{$o} = $o;
    }

    if (my $o = $cc->object_file(my $c = 'gnulib/strftime_r.c')) {
        $self->add_to_cleanup($o);
        $cc->compile(source => $c, object_file => $o, include_dirs => [qw( gnulib gnulib/lib )], extra_compiler_flags => $self->extra_compiler_flags)
            unless $self->up_to_date($c, $o);
        $objs{$o} = $o;
    }

    return 1;
};

sub ACTION_code {
    my $self = shift;
    $self->depends_on("gnulib");
    $self->extra_linker_flags(keys %objs);
    return $self->SUPER::ACTION_code(@_);
};

1;
