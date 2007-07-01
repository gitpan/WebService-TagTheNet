# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'WebService::TagTheNet' ); }

my $object = WebService::TagTheNet->new ();
isa_ok ($object, 'WebService::TagTheNet');


