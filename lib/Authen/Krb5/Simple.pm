# $Id: Simple.pm,v 1.3 2003-01-19 21:04:58 dstuart Exp $
###############################################################################
#
# File:    Simple.pm
#
# Author:  Damien S. Stuart
#
# Purpose: Perl module for basic authenication using Kerberose 5.
#
#
###############################################################################
#
package Authen::Krb5::Simple;

use 5.006;
use strict;
use warnings;
use Carp;

require DynaLoader;

our @ISA = qw(DynaLoader);

our $VERSION = '0.30';

bootstrap Authen::Krb5::Simple $VERSION;

# Create the Kerberos 5 object.
#
sub new {
    my $class   = shift;
    my (%args)  = @_;

    bless {
        _err_code   => 0,
        _def_realm  => $args{realm} || ''
    }, $class
}

# Perform the authentication
#
sub authenticate {
    my $self = shift;
    my $user = shift || croak "Missing arg: username\n";
    my $pw   = shift; 

    croak "Missing arg: password\n" unless(defined($pw));

    if($pw eq '') {
        carp "Empty passwords are not supported.\n" if($pw eq '');
        return 0;
    }

    # If a realm is specified, prepend it to the username (as long as the
    # username does not already have a realm component).
    #
    if($self->{_realm} and $user !~ /@\S+$/) {
        $user .= "\@$self->{_realm}";
    }

    return(($self->{_err_code} = krb5_auth($user, $pw)) == 0);
}

# Return the error string from the most recent authenticate function.
#
sub errstr {
    my $self = shift;

    return '' if($self->{_err_code} == 0);

    return krb5_errstr($self->{_err_code});
}

# Return the error code from the most recent authenticate function.
#
sub errcode {
    my $self = shift;
    return $self->{_err_code};
}

# Get or set the default realm
#
sub realm {
    my $self    = shift;
    my $arg     = shift;

    $self->{_realm} = $arg if(defined($arg));

    return $self->{_realm};
}

1;

__END__

=head1 NAME

Authen::Krb5::Simple - Basic user authentication using Kerberos 5

=head1 SYNOPSIS

  use Authen::Krb5::Simple;

  my $krb = Authen::Krb5::Simple->new([realm => 'MY.KRB.REALM']);

  # Authenticate a user.
  #
  my $authen = $krb->authenticate($user, $password);

  unless($authen) {
      my $errmsg = $krb->errstr();
      die "User: $user authentication failed: $errmsg\n";
  }

  # Get the current default realm.
  #
  my $realm = $krb->realm();

  # Set the current realm
  #
  $krb->realm('MY.NEW.REALM');


=head1 DESCRIPTION

The C<Authen::Krb5::Simple> module provides a means to authenticate a
user/password using Kerberos 5 protocol.  The module's authenticate function
takes a username (or user@kerberos_realm) and a password, and authenticates
that user using the local Kerberos 5 installation.  It was initially created
to allow perl scripts to perform authentication against a Microsoft Active
Directory (AD) server.

It is important to note: This module only performs simple authentication.  It
does not get, grant, use, or retain any kerberos tickets.  It will check
use credentials against the Kerberos server (as configured on the local
system) each time the I<authenticate> method is called.

=head1 CONSTRUCTOR

B<new>

=over

The I<new> method creates the I<Authen::Krb5::Simple> object.  It can take an
optional argument hash.  At present the only recognized argument is C<realm>.

If no realm is specified, the default realm for the local host will be
assumed.  Once set, the specified realm will be used for all subsequent 
authentication calls.  The realm can be changed using the I<realm> function
(see below).

B<Examples:>

Using the default realm:

  my $krb = Authen::Krb5::Simple->new();

specifying a realm:

  my $krb = Authen::Krb5::Simple->new(realm => 'another.realm.net');

=back

=head1 METHODS

B<authenticate(%user[@realm], $password)>

=over

the I<authenticate> method takes the user (or user@realm) and a password, and
uses kerberos 5 (the local systems installation) to authenticate the user.

if the user/password is good, I<authenticate> will return true (1). Otherwise,
a false value is returned and the error code is stored in the object.

  if($krb->authenticate($user, $pw)) {
      print "$user authentication successful\n";
  } else {
      print "$user authentication failed\n";
  }
        
=back
   
B<realm([NEW.REALM])>

=over

The I<realm> method is used to set or get the current default realm.  If an
argument is passed to this method, the default realm is set to its value. If
no argument is supplied, the current realm is returned.

=back

B<errstr>

=over

The I<errstr> method will return the error message from the most recent
I<authentication> call.

=back

B<errcode>

=over

The I<errstr> method will return the krb5 error code from the most recent
I<authentication> call.  This value will not be very useful.  Use the 
I<errstr> method to get a meaningful error message.

=back

=head1 BUGS

This version of I<Authen::Krb5::Simple> does not support empty passwords.  If you
pass C<''> as a password I<authenticate> will print a warning and return false.
However there will be no error code or string when C<errstr> is called.

=head1 AUTHOR

Damien S. Stuart, E<lt>damien.stuart@usi.net<gt>

=head1 SEE ALSO

L<perl>, Kerberos5 documentation.

=cut

###EOF###
