# $Id: 02-ops.t,v 1.1.1.1 2003-01-19 20:33:34 dstuart Exp $
###############################################################################
# Authen::Krb5::Simple Test Script
#
# File: 02-ops.t
#
# Purpose: Make sure we can create and use an Authen::Krb5::Simple object.
#
###############################################################################
#
use strict;

use Test::More tests => 16;

use Authen::Krb5::Simple;

# Get test user params (if any)
#
my $tdata = get_test_data();

my $krb = Authen::Krb5::Simple->new();

# (1) Valid object.
#
isa_ok($krb, 'Authen::Krb5::Simple', 'Valid object check');

my $verbose = $ENV{verbose} || 0;

my $ret;

# (2-7) Good pw
#
my $no_user_data = 1;

$no_user_data = 0 if(defined($tdata->{user}) and defined($tdata->{password}));

SKIP: {
    skip "No user/password data provided", 6 if($no_user_data);

    my $tuser = $tdata->{user};
    my $tpass = $tdata->{password};

    $tuser .= "\@$tdata->{realm}" if(defined($tdata->{realm}));

    $ret = $krb->authenticate($tuser, $tpass) unless($no_user_data);

    my $errcode = $krb->errcode();
    my $errstr  = $krb->errstr();

    print STDERR "\nGPW RET: $ret (code=$errcode, str=$errstr)\n" if($verbose);

    ok($ret, 'Expected good username and password');

    # Valid error conditions
    ok($errcode == 0, 'Error code should be 0');
    ok($errstr eq '', "Error string should be empty: Got '$errstr'");

    # Now munge the pw and make sure we get the expected responses
    #
    $ret = $krb->authenticate($tuser, "x$tpass") unless($no_user_data);

    $errcode = $krb->errcode();
    $errstr  = $krb->errstr();

    diag("GPW2 RET: $ret (code=$errcode, str=$errstr)")
        if($verbose and $no_user_data == 0);

    ok(!$ret, "Return value should not be true: Got '$ret'");

    ok($errcode != 0, "Error code should not be 0: Got '$errcode'");
    ok($errstr ne '', 'Expected a non-empty error string.');

}

# (8-13) Null and Empty password
#
$ret = $krb->authenticate('_not_a_user_');
ok($ret==0, "Null password should return 0: Got '$ret'");
ok($krb->errcode() eq 'e1', "Null password error code was not 'e1'");
ok($krb->errstr() =~ /Null or empty password not supported/,
   "Unexpected Null password error string");

$ret = $krb->authenticate('_not_a_user_', '');
ok($ret==0, "Empty password should return 0: Got '$ret'");
ok($krb->errcode() eq 'e1', "Empty password error code was not 'e1'");
ok($krb->errstr() =~ /Null or empty password not supported/,
   "Unexpected Empty password error string");

# (14) Bad user and pw
#
$ret = $krb->authenticate('_xxx', '_xxx');
print STDERR "\nBPW RET: $ret\n" if($verbose);
ok($ret == 0);

# (15-16) Valid error conditions
ok($krb->errcode() != 0);
ok($krb->errstr());

## End of Tests ##

sub get_test_data {
    my %tdata;

    unless(open(CONF, "<CONFIG")) {
        print STDERR "\nUnable to read CONFIG file: $!\nSkipping user auth tests\n";
        return undef;
    }

    while(<CONF>) {
        chomp;
        next if(/^\s*#|^\s*$/);

        $tdata{user} = $1 if(/^\s*TEST_USER\s+(.*)/);
        $tdata{password} = $1 if(/^\s*TEST_PASS\s+(.*)/);
        $tdata{realm} = $1 if(/^\s*TEST_REALM\s+(.*)/);
    }
    close(CONF);

    return(\%tdata);  
}

###EOF###
