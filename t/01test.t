# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use Time::HiRes;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

print "gettimeofday...";
($s, $us) = Time::HiRes::gettimeofday; 
print "$s:$us\nok 2\n";

print "time...";
$f = Time::HiRes::time; 
print "$f\nok 3\n";

print "usleep...";
$f = Time::HiRes::time; 
($s, $us) = Time::HiRes::gettimeofday; 
Time::HiRes::usleep(500_000);
$f2 = Time::HiRes::time;
($s2, $us2) = Time::HiRes::gettimeofday;
print $f2 - $f, "\nok 4\n";

print "tv_interval...";
print Time::HiRes::tv_interval([$s, $us], [$s2, $us2]), "\nok 5\n";

print "sleep...";
$r = [Time::HiRes::gettimeofday];
Time::HiRes::sleep (0.5);
$r2 = [Time::HiRes::gettimeofday];
print Time::HiRes::tv_interval($r, $r2), "\nok 6\n";

print "tv_interval (1 arg)...";
print Time::HiRes::tv_interval($r), "\nok 7\n";

$r = [Time::HiRes::gettimeofday];
$i = 5;
Time::HiRes::ualarm(2_000_000, 500_000);
$SIG{ALRM} = "tick";
while ($i)
 {
  select (undef, undef, undef, 10);
  print "Select returned! ", Time::HiRes::tv_interval ($r), "\n";
 }

sub tick
 {
  print "Tick! ", Time::HiRes::tv_interval ($r), "\n";
  $i--;
 }
$SIG{ALRM} = 'DEFAULT';
print "ok 8\n";
