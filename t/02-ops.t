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

use Test;

use Authen::Krb5::Simple;

BEGIN { plan tests => 7 };

# Get test user params (if any)
#
my ($tuser, $tpw) = get_test_user();

my $krb = Authen::Krb5::Simple->new();

# Valid object.
#
ok(ref($krb) =~ /Authen::Krb5::Simple/);

my $verbose = $ENV{verbose} || 0;

my $ret;

# Good pw
#
if($tuser and $tpw) {
    $ret = $krb->authenticate($tuser, $tpw);
    my $errcode = $krb->errcode();
    my $errstr = $krb->errstr();

    print STDERR "\nGPW RET: $ret (code=$errcode, str=$errstr)\n" if($verbose);

    ok($ret);

    # Valid error conditions
    ok($errcode == 0);
    ok($errstr eq '');
} else {
    skip(1,'Skipped user auth');
    skip(1,'Skipped user auth errcode');
    skip(1,'Skipped user auth errstr');
}

# Bad pw
#
$ret = $krb->authenticate('_xxx', '_xxx');
print STDERR "\nBPW RET: $ret\n" if($verbose);
ok($ret == 0);

# Valid error conditions
ok($krb->errcode() != 0);
ok($krb->errstr());

sub get_test_user {
    my ($user, $pw);

    unless(open(CONF, "<CONFIG")) {
        print STDERR "\nUnable to read CONFIG file: $!\nSkipping user auth tests\n";
        return undef;
    }

    while(<CONF>) {
        chomp;
        next if(/^\s*#|^\s*$/);

        $user = $1 if(/^\s*TEST_USER\s+(.*)/);
        $pw = $1 if(/^\s*TEST_PASS\s+(.*)/);
    }
    close(CONF);

    return(($user && $pw) ? ($user, $pw) : undef);  
}

###EOF###
