package Time::HiRes;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

@EXPORT = qw( );
@EXPORT_OK = qw (time alarm sleep);

( $VERSION ) = '$Revision: 1.1 $ ' =~ /\$Revision\:\s+([^\s]+)/; $VERSION = join(".", map { $_ = sprintf ("%2.2d", $_) } split (/\./, $VERSION));

bootstrap Time::HiRes $VERSION;

# Preloaded methods go here.

sub tv_interval {
    # probably could have been done in C
    my ($a, $b) = @_;
    $b = [&gettimeofday] unless defined($b);
    (${$b}[0] - ${$a}[0]) + ((${$b}[1] - ${$a}[1]) / 1_000_000);
}

sub alarm {
    # definitely should have been done in C, but this is educational!
    my ($seconds, $interval) = @_;
    $interval = 0 unless defined($interval);
    ualarm ($seconds*1_000_000, $interval*1_000_000);
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Time::HiRes - Perl extension for ualarm, usleep, and gettimeofday

=head1 SYNOPSIS

  use Time::HiRes;

  Time::HiRes::usleep ($microseconds);

  Time::HiRes::ualarm ($microseconds, $interval_microseconds);

  $t0 = [Time::HiRes::gettimeofday];
  ($seconds, $microseconds) = Time::HiRes::gettimeofday;

  $elapsed = Time::HiRes::tv_interval ( $t0, [$seconds, $microseconds]);
  $elapsed = Time::HiRes::tv_interval ( $t0, [Time::HiRes::gettimeofday]);
  $elapsed = Time::HiRes::tv_interval ( $t0 );

  $now_fractions = Time::HiRes::time;

  Time::HiRes::sleep ($floating_seconds);

  Time::HiRes::alarm ($floating_seconds);
  Time::HiRes::alarm ($floating_seconds, $floating_interval);
 
  use Time::HiRes qw ( time alarm sleep );
  $now_fractions = time;
  sleep ($floating_seconds);
  alarm ($floating_seconds);

=head1 DESCRIPTION

The C<Time::HiRes> package implements a Perl interface to usleep, ualarm,
and gettimeofday system calls. See the EXAMPLES section below and the test
scripts for usage; see your system documentation for the description of
the underlying gettimeofday, usleep, and ualarm calls.

=item gettimeofday

Returns a 2 element array with the second and microseconds since the epoch.

=item usleep ( $useconds )

Issues a usleep for the # of microseconds specified. See also 
Time::HiRes::sleep.

=item ualarm ( $useconds [, $interval_useconds ] )

Issues a ualarm call; interval_useconds is optional and will be 0 if 
unspecified, resulting in alarm-like behaviour.

=item tv_interval ( $ref_to_gettimeofday [, $ref_to_later_gettimeofday] )

Returns the floating seconds between the two times, which should have been 
returned by Time::HiRes::gettimeofday. If the second is omitted, then the
current time is use.

=item time 

Returns a floating seconds since the epoch. This function can be exported,
resulting in a nice drop-in replacement for the C<time> provided with perl,
see the EXAMPLES below.

=item sleep ( $floating_seconds )

Converts $floating_seconds to microseconds and issues a usleep for the 
result.  This function can be exported, resulting in a nice drop-in 
replacement for the C<sleep> provided with perl, see the EXAMPLES below.

=item alarm ( $floating_seconds [, $interval_floating_seconds ] )

Converts $floating_seconds and $interval_floating_seconds and issues a
ualarm for the results.  $interval_floating_seconds is optional and will 
be 0 if unspecified, resulting in alarm-like behaviour.  This function can 
be exported, resulting in a nice drop-in 
replacement for the C<alarm> provided with perl, see the EXAMPLES below.

=head1 EXAMPLES

  use Time::HiRes;

  $microseconds = 750_000;
  Time::HiRes::usleep ($microseconds);

  # signal alarm in 2.5s & every .1 s thereafter
  Time::HiRes::ualarm (2_500_000, 100_000);	

  # get seconds and microseconds since the epoch
  ($s, $usec) = Time::HiRes::gettimeofday;

  # measure elapsed time 
  # (could also do by subtracting 2 Time::HiRes:gettimeofday_f return values)
  $t0 = [Time::HiRes::gettimeofday];
  # do bunch of stuff here
  $t1 = [Time::HiRes::gettimeofday];
  # do more stuff here
  $t0_t1 = Time::HiRes::tv_interval ($t0, $t1);
  
  $elapsed = Time::HiRes::tv_interval ($t0, [Time::HiRes::gettimeofday]);
  $elapsed = Time::HiRes::tv_interval ($t0);	# equivalent code

  #
  # replacements for time, alarm and sleep that know about floating seconds
  #
  use Time::HiRes;
  $now_fractions = Time::HiRes::time;
  Time::HiRes::sleep (2.5);
  Time::HiRes::alarm (10.6666666);
 
  use Time::HiRes qw ( time alarm sleep );
  $now_fractions = time;
  sleep (2.5);
  alarm (10.6666666);

=head1 AUTHOR

D. Wegscheid <wegscd@whirlpool.com>

=head1 REVISION

$Id: HiRes.pm,v 1.1 1996/10/17 20:53:31 wegscd Exp $

$Log: HiRes.pm,v $
Revision 1.1  1996/10/17 20:53:31  wegscd
Fix =head1 being next to __END__ so pod2man works

Revision 1.0  1996/09/03 18:25:15  wegscd
Initial revision


=head1 COPYRIGHT

Copyright (c) 1996 Douglas E. Wegscheid.
All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=cut

sub ualarm
 {
  my ($useconds, $uinterval) = @_;
  $uinterval = 0 unless defined($uinterval);
  ualarm ($useconds, $uinterval);
 }
