# $Id: 01-compile.t,v 1.1.1.1 2003-01-19 20:33:34 dstuart Exp $
###############################################################################
# Authen::Krb5::Simple Test Script
#
# File: 01-compile.t
#
# Purpose: Make sure the modules compiles and loads with no error
#
###############################################################################
#
my $loaded;

BEGIN { print "1..1\n" }

use Authen::Krb5::Simple;

$loaded++;

print "ok 1\n";

END { print "not ok 1\n" unless $loaded }

###EOF###
