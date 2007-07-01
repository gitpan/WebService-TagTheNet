package WebService::TagTheNet;

use strict;
use Carp qw/croak/;
use LWP::UserAgent;
use XML::XPath;

our $VERSION = '0.01';

sub new {
   my ($class, %args) = @_;

   my $self = bless ({}, ref ($class) || $class);

   $self->{'_opts'} = {
      uri       => 'http://tagthe.net/api/',
      agent     => 'WebService::TagTheNet v.'.$VERSION,
      count     => 10,
      %args
   };
   $self->{'_lwp'} = LWP::UserAgent->new(agent => $self->{'_opts'}->{'agent'});

   return $self;
}

sub text {
   my ($self, $text) = @_;
   croak "No text found" unless($text);

   return $self->_post('text', $text);
}

sub url {
   my ($self, $url) = @_;
   croak "No URL found" unless($url);

   return $self->_post('url', $url);
}

sub _post {
   my ($self, $k, $v) = @_;
   my $status = $self->{'_lwp'}->post(
      $self->{'_opts'}->{'uri'},
      { $k => $v, count => $self->{'_opts'}->{'count'} }
   );
   croak ("Can't connect to ", $self->{'_opts'}->{'uri'},": ", 
           $status->status_line) unless($status->is_success);
   return $self->_xml2hash($status->content);
}

sub _xml2hash {
   my ($self, $xml) = @_;

   my %result = ();
   my $xp = XML::XPath->new(xml => $xml);
   my $nodeset = $xp->find('/memes/meme/dim');
   foreach my $node ($nodeset->get_nodelist) {
      my $type = $node->getAttribute('type');
      foreach my $child ($node->getChildNodes) {
         next unless(ref $child eq 'XML::XPath::Node::Element');
         push @{$result{$type}}, $child->string_value;
      }
    }
   return \%result;
}
#################### main pod documentation begin ###################

=head1 NAME

WebService::TagTheNet - Retrieve tags using the tagthe.net REST API

=head1 SYNOPSIS

  use WebService::TagTheNet;

  my $ttn = WebService::TagTheNet->new(count => 5);
  my $result = $ttn->url('http://tagthe.net/');

  print "Tags: ", join ", ", @{$result->{'topic'}};

=head1 DESCRIPTION

C<WebService::TagTheNet> - Retrieve tags using the tagthe.net REST API

=head2 METHODS

The following methods can be used

=head3 new

C<new> creates a new C<WebService::TagTheNet> object.

=head4 options

=over 5

=item uri

If for some obscure reason you do not want to use the default
L<http://tagthe.net/api/> URI, you can specify your own one here.

=item agent

The agent string used for L<LWP::UserAgent>. Defaults to
C<'WebService::TagTheNet v.'.$VERSION>

=item count

Define the amount of topics/tags you'd like to receive. Defaults
to 10.

=back

=head3 text

Accepts a scalar and will pass that on to tagthe.net for analysis. It
returns a hashref with the results (or croaks if something goes wrong).

=head3 url

Accepts an URL and will pass that on to tagthe.net for analysis. It
returns a hashref with the results (or croaks if something goes wrong).

=head2 RETURN VALUES

The hash with API results may contain any of these fields:

=head3 text

=over 5

=item language

=item topic

=item location

=item person

=back

=head3 url

=over 5

=item title

=item size

=item content-type

=item author

=back

Please see L<http://www.tagthe.net/fordevelopers> for more information.

=head1 SEE ALSO

L<http://tagthe.net/>, L<http://tagthe.net/fordevelopers>

=head1 BUGS

Please report any bugs to L<http://rt.cpan.org/Ticket/Create.html?Queue=WebService::TagTheNet>.

=head1 AUTHOR

M. Blom,
E<lt>blom@cpan.orgE<gt>,
L<http://menno.b10m.net/perl/>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
#################### main pod documentation end ###################

1;
