package POSIX::strftime::GNU::PP;

=head1 NAME

POSIX::strftime::GNU::PP - Pure-Perl extension for POSIX::strftime::GNU

=head1 SYNOPSIS

  $ export PERL_POSIX_STRFTIME_GNU_PP=1

=head1 DESCRIPTION

This is PP extension for POSIX::strftime which implements more character
sequences compatible with GNU systems.

=for readme stop

=cut


use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

use Carp ();
use POSIX ();
use Time::Local ();

our $tzoffset = sub {
    my @t = @_;

    my $s = Time::Local::timegm(@t) - Time::Local::timelocal(@t);

    return sprintf '%+03d%02u', int($s/3600), $s % 3600;
};

my $isoweeknum = sub {
    my @t = @_;

    CALC:

    # http://en.wikipedia.org/wiki/ISO_8601
    # week 01 is the week with the year's first Thursday in it (the ISO 8601 definition)
    my $year = $t[5];

    my $first_day = strftime_orig('%w', 0, 0, 0, 1, 0, $year);
    my $last_day = strftime_orig('%w', 0, 0, 0, 31, 11, $year);

    my $number = my $isonumber = strftime_orig('%W', @t);

    $isonumber-- if $first_day == 1;

    if ($first_day >= 1 && $first_day <= 4) {
        $isonumber++;
    }
    elsif ($number == 0) {
        @t = (0, 0, 0, 31, 11, $year - 1);
        goto CALC;
    };

    if ($isonumber == 53 && ($last_day == 1 || $last_day == 2 || $last_day == 3)) {
        $isonumber = 1;
    };

    return sprintf('%02d', $isonumber);
};

my $isoyearnum = sub {
    my @t = @_;

    my $year = $t[5] + 1900;

    if ($t[4] == 0 and $isoweeknum->(@t) > 5) {
        $year--;
    }
    elsif ($t[4] == 11 and $isoweeknum->(@t) < 50) {
        $year++;
    };

    return $year;
};

my %offset2zone_std = (
    '-1100' => 'MIT',  # Midway Islands Time
    '-1000' => 'HAST', # Hawaii Standard Time
    '-0900' => 'AKST', # Alaska Standard Time
    '-0800' => 'PST',  # Pacific Standard Time
    '-0700' => 'MST',  # Mountain Standard Time
    '-0600' => 'CST',  # Central Standard Time
    '-0500' => 'EST',  # Eastern Standard Time
    '-0400' => 'PRT',  # Puerto Rico and US Virgin Islands Time
    '-0330' => 'CNT',  # Canada Newfoundland Time
    '-0300' => 'AGT',  # Argentina Standard Time
    '-0300' => 'BET',  # Brazil Eastern Time
    '-0100' => 'CAT',  # Central African Time
    '+0000' => 'GMT',  # Universal Coordinated Time/Greenwich Mean Time
    '+0000' => 'WET',  # Western European Time
    '+0100' => 'CET',  # Central European Time
    '+0200' => 'EET',  # Eastern European Time
    '+0200' => 'ART',  # (Arabic) Egypt Standard Time
    '+0300' => 'EAT',  # Eastern African Time
    '+0330' => 'MET',  # Middle East Time
    '+0400' => 'NET',  # Near East Time
    '+0500' => 'PLT',  # Pakistan Lahore Time
    '+0530' => 'IST',  # India Standard Time
    '+0600' => 'BST',  # Bangladesh Standard Time
    '+0700' => 'ICT',  # Indochina Time
    '+0800' => 'CTT',  # China Taiwan Time
    '+0800' => 'AWST', # Australia Western Time
    '+0900' => 'JST',  # Japan Standard Time
    '+0930' => 'ACST', # Australia Central Time
    '+1000' => 'AEST', # Australia Eastern Time
    '+1100' => 'SST',  # Solomon Standard Time
    '+1200' => 'NZST', # New Zealand Standard Time
);

my %offset2zone_dst = (
    '-0800' => 'AKDT', # Alaska Daylight Saving Time
    '-0700' => 'PDT',  # Pacific Daylight Saving Time
    '-0600' => 'MDT',  # Mountain Daylight Saving Time
    '-0500' => 'CDT',  # Central Daylight Saving Time
    '-0400' => 'EDT',  # Eastern Daylight Saving Time
    '+0100' => 'WEST', # Western European Summer Time
    '+0200' => 'CEST', # Central European Summer Time
    '+0300' => 'EEST', # Eastern European Summer Time
    '+1300' => 'NZST', # New Zealand Daylight Saving Time
);

our $offset2zone = sub {
    my @t = @_;

    my $off = $tzoffset->(@t);

    my $zone = $t[8] ? $offset2zone_dst{$off} : $offset2zone_std{$off};

    return $zone if defined $zone;

    if ($off =~ /^([+-])(\d\d)00$/) {
        return sprintf 'GMT%s%d', $1, $2;
    };

    return 'Etc';
};

my %format = (
    C => sub { 19 + int $_[5] / 100 },
    D => sub { '%m/%d/%y' },
    e => sub { sprintf '%2d', $_[3] },
    F => sub { '%Y-%m-%d' },
    G => $isoyearnum,
    g => sub { $isoyearnum->(@_) % 100 },
    h => sub { '%b' },
    k => sub { sprintf '%2d', $_[2] },
    l => sub { sprintf '%2d', $_[2] % 12 + ($_[2] % 12 == 0 ? 12 : 0) },
    n => sub { "\n" },
    P => sub { lc strftime_orig('%p', @_) },
    r => sub { '%I:%M:%S %p' },
    R => sub { '%H:%M' },
    s => sub { POSIX::mktime(@_) },
    t => sub { "\t" },
    T => sub { '%H:%M:%S' },
    u => sub { my $dw = strftime_orig('%w', @_); $dw += ($dw == 0 ? 7 : 0); $dw },
    V => $isoweeknum,
    z => $tzoffset,
    Z => $offset2zone,
);

my $formats = join '', sort keys %format;

sub strftime ($@) {
    my ($fmt, @t) = @_;

    Carp::croak 'Usage: POSIX::strftime(fmt, sec, min, hour, mday, mon, year, wday = -1, yday = -1, isdst = -1)'
        unless @t >= 6 and @t <= 9;

    $fmt =~ s/%E([CcXxYy])/%$1/;
    $fmt =~ s/%O([deHIMmSUuVWwy])/%$1/;
    $fmt =~ s/%([$formats])/$format{$1}->(@t)/ge;

    return strftime_orig($fmt, @t);
};

if (not defined *strftime_orig{CODE}) {
    *strftime_orig = *POSIX::strftime;
};

1;


=for readme continue

=head1 SEE ALSO

L<POSIX::strftime::GNU>.

=head1 AUTHOR

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2012 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See L<http://dev.perl.org/licenses/artistic.html>
