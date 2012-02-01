
#    Copyright © 2010 Brandon L Black <blblack@gmail.com>
#
#    This file is part of gdnsd.
#
#    gdnsd is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    gdnsd is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with gdnsd.  If not, see <http://www.gnu.org/licenses/>.
#

#
# This tests that the test infrastructure basically works,
#  and that we can spawn a gdnsd instance with an absolutely
#  minimal configuration and get it to succesfully answer the
#  easiest query imaginable.  All significant (like failure
#  to control the daemon or load modules) failures here result
#  in BAIL_OUT, as there's no point continuing the test suite if
#  those things don't work.
#
#  There is a lot more verbosity in this test than will be
#  required in the later ones, to test basic assumptions.
#

use Test::More tests => 9;
BEGIN { use_ok("FindBin") or BAIL_OUT("Perl broken (no FindBin)"); }
BEGIN { use_ok("File::Spec") or BAIL_OUT("Perl broken (no File::Spec)"); }
BEGIN { use_ok("Net::DNS") or BAIL_OUT("Net::DNS broken"); }
BEGIN { use_ok("Net::DNS::Resolver") or BAIL_OUT("Net::DNS::Resolver broken"); }
BEGIN { use_ok("LWP::UserAgent") or BAIL_OUT("LWP::UserAgent broken"); }
BEGIN { use_ok("_GDT") or BAIL_OUT("Test suite broken (no _GDT)"); }

my $pid = _GDT->test_spawn_daemon(File::Spec->catfile($FindBin::Bin, 'gdnsd.conf'));

_GDT->test_dns(
    qname => 'ns1.example.com',
    answer => 'ns1.example.com 86400 A 192.0.2.42',
);

_GDT->test_kill_daemon($pid);
