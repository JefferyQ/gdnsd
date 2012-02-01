
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

# plugin_weighted tests
# note the wrapping of tests in looped blocks:
#  this is to give random weighting a chance to
#  screw up the results.

use _GDT ();
use FindBin ();
use File::Spec ();
use Test::More tests => 13;

my $soa = 'example.com 86400 SOA ns1.example.com hostmaster.example.com 1 7200 1800 259200 900';

my $pid = _GDT->test_spawn_daemon(File::Spec->catfile($FindBin::Bin, 'gdnsd.conf'));

_GDT->test_dns(
    qname => 'example.com', qtype => 'SOA',
    answer => $soa,
);

_GDT->test_dns(
    qname => 'wdep-addrs.example.com', qtype => 'A',
    rep => 20,
    limit_v4 => 1,
    answer => [
        'wdep-addrs.example.com 86400 A 192.0.2.171',
        'wdep-addrs.example.com 86400 A 192.0.2.172',
        'wdep-addrs.example.com 86400 A 192.0.2.173',
    ],
);

_GDT->test_dns(
    qname => 'wdep-cnames.example.com', qtype => 'A',
    rep => 20,
    # CNAME auto-limits to 1 RR
    answer => [
        'wdep-cnames.example.com 86400 CNAME foo.example.net',
        'wdep-cnames.example.com 86400 CNAME fox.example.net',
    ],
);

_GDT->test_dns(
    qname => 'weighta.example.com', qtype => 'A',
    rep => 20,
    limit_v4 => 1,
    answer => [
        'weighta.example.com 86400 A 192.0.2.171',
        'weighta.example.com 86400 A 192.0.2.172',
        'weighta.example.com 86400 A 192.0.2.173',
    ],
);

_GDT->test_dns(
    qname => 'weighta6.example.com', qtype => 'AAAA',
    rep => 20,
    limit_v6 => 1,
    answer => [
        'weighta6.example.com 43200 AAAA 2001:DB8::1234',
        'weighta6.example.com 43200 AAAA 2001:DB8::5678',
    ],
);

_GDT->test_dns(
    qname => 'weightam.example.com', qtype => 'A',
    rep => 20,
    wrr_v4 => { 'weightam.example.com' => 1 },
    answer => [
        'weightam.example.com 86400 A 192.0.2.174',
        'weightam.example.com 86400 A 192.0.2.175',
        'weightam.example.com 86400 A 192.0.2.176',
    ],
);

_GDT->test_dns(
    qname => 'weightc.example.com', qtype => 'A',
    rep => 10,
    # CNAME auto-limits to 1 RR
    answer => [
        'weightc.example.com 86400 CNAME bar.example.net',
        'weightc.example.com 86400 CNAME box.example.net',
    ],
);

_GDT->test_dns(
    qname => 'weightg.example.com', qtype => 'A',
    multi_rrset_break => { 'weightg.example.com' => [ 3, 2 ] },
    rep => 100,
    wrr_v4 => { 'weightg.example.com' => { multi => 0, groups => [3, 2] }},
    answer => [
        'weightg.example.com 43200 A 192.0.2.191',
        'weightg.example.com 43200 A 192.0.2.192',
        'weightg.example.com 43200 A 192.0.2.193',
        # -- group break --
        'weightg.example.com 43200 A 192.0.2.201',
        'weightg.example.com 43200 A 192.0.2.202',
    ],
);

_GDT->test_dns(
    qname => 'weightgm.example.com', qtype => 'A',
    wrr_v4 => { 'weightgm.example.com' => { multi => 1, groups => [3, 2] }},
    rep => 100,
    answer => [
        'weightgm.example.com 86400 A 192.0.2.194',
        'weightgm.example.com 86400 A 192.0.2.195',
        'weightgm.example.com 86400 A 192.0.2.196',
        # -- group break --
        'weightgm.example.com 86400 A 192.0.2.203',
        'weightgm.example.com 86400 A 192.0.2.204',
    ],
);

_GDT->test_dns(
    qname => 'weightmixc.example.com', qtype => 'A',
    rep => 10,
    # CNAME auto-limits to 1 RR
    answer => [
        'weightmixc.example.com 86400 CNAME a.example.net',
        'weightmixc.example.com 86400 CNAME b.example.net',
    ],
);

_GDT->test_dns(
    qname => 'weightmixa.example.com', qtype => 'A',
    rep => 20,
    wrr_v4 => { 'weightmixa.example.com' => 0 },
    wrr_v6 => { 'weightmixa.example.com' => 1 },
    answer => [
        'weightmixa.example.com 43200 A 192.0.2.22',
        'weightmixa.example.com 43200 A 192.0.2.33',
    ],
    addtl => [
        'weightmixa.example.com 43200 AAAA 2001:DB8::2222',
        'weightmixa.example.com 43200 AAAA 2001:DB8::3333',
    ]
);

_GDT->test_kill_daemon($pid);
