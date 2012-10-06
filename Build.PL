#!/usr/bin/perl

use 5.006;

use strict;
use warnings;

use lib 'inc';
use Module::Build::My;

use Config;

my $module = 'POSIX::strftime::GNU';

(my $dist = $module) =~ s/::/-/g;

my $cflags = '-Wall -g';
$cflags .= ' -DHAVE_TM_GMTOFF' if $Config{d_tm_tm_gmtoff};
$cflags .= ' -DHAVE_TM_ZONE'   if $Config{d_tm_tm_zone};
$cflags .= ' -DHAVE_TZNAME'    if $Config{d_tzname};

my $build = Module::Build::My->new(
    module_name             => $module,
    license                 => 'perl',
    requires                => {
        'perl'                  => 5.006,
        'XSLoader'              => 0,
    },
    recommends              => {
    },
    build_requires          => {
        'ExtUtils::CBuilder'    => 0,
        'ExtUtils::CChecker'    => 0,
        'Test::More'            => 0,
    },
    include_dirs            => [
        'xslib',
    ],
    xs_files                => {
        'xs/strftime.xs' => 'lib/POSIX/strftime/GNU/XS.xs',
    },
    extra_compiler_flags    => $cflags,
    auto_configure_requires => 0,
    create_makefile_pl      => 'traditional',
    create_readme           => 1,
    create_license          => 1,
    recursive_test_files    => 0,
    add_to_cleanup          => [
        '*.bak', '*.gz', '*.tgz', '*.ppd', '*.ppmx', '*.deb', '*.bat',
        'Makefile', 'pm_to_blib', 'cover_db', 'Debian_CPANTS.txt',
        "$dist-*",
    ],
    meta_merge              => {
        resources               => {
            bugtracker => "http://github.com/dex4er/perl-$dist/issues",
            repository => "http://github.com/dex4er/perl-$dist",
        },
    },
);

$build->create_build_script;
