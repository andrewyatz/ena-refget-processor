#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

package Rest;

use Moose::Role;
use HTTP::Tiny;
use JSON qw/decode_json/;

has 'http' => ( isa => 'HTTP::Tiny', is => 'ro', required => 1, default =>  sub { return HTTP::Tiny->new() } );

sub get_json {
  my ($self, $url) = @_;
  my $response = $self->get($url, { 'Accept' => 'application/json' });
  return decode_json($response->{content});
}

sub get_text {
  my ($self, $url) = @_;
  my $response = $self->get($url, { 'Accept' => 'text/plain' });
  return $response->{content};
}

sub get {
  my ($self, $url, $headers) = @_;
  my $http = $self->http();
  my $response = $http->get($url, { headers => $headers });
  if(!$response->{success}) {
    confess(sprintf("Could not make valid request for URL %s: %s (%d) ", $url, $response->reason(), $response->code()));
  }
  return $response;
}

1;
