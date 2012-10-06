package Module::Build::My;

use 5.006;

use strict;
use warnings;

use base 'Module::Build';

use ExtUtils::CBuilder;
use ExtUtils::CChecker;

my $cc = ExtUtils::CBuilder->new;

my %objs;

sub ACTION_config_gnulib {
    my $self = shift;

    my $chk = ExtUtils::CChecker->new(
        defines_to => 'gnulib/config.h',
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

    $chk->define('my_strftime gnu_strftime');

    return 1;
};

sub ACTION_gnulib {
    my $self = shift;
    $self->depends_on("config_gnulib");

    {
        my $o = $cc->compile(source => 'gnulib/lib/time_r.c', include_dirs => [qw( gnulib gnulib/lib )], extra_compiler_flags => $self->extra_compiler_flags);
        $self->add_to_cleanup($o);
        $objs{$o} = $o;
    }

    {
        my $o = $cc->compile(source => 'gnulib/lib/strftime.c', include_dirs => [qw( gnulib gnulib/lib )], extra_compiler_flags => $self->extra_compiler_flags);
        $self->add_to_cleanup($o);
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
