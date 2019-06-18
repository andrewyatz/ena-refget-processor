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

package RestEmbl;

use Moose;
use EmblVersion;

with 'Rest';

has 'server'      => ( isa => 'Str', is => 'ro', required => 1, default => q{https://www.ebi.ac.uk} );
has 'url_format'  => ( isa => 'Str', is => 'ro', required => 1, default => sub {
  my ($self) = @_;
  $self->server().q{/ena/browser/api/versions/%s}
});

sub get_versions {
  my ($self, $accession) = @_;
  confess "No accession given" unless $accession;
  my $json = $self->get_json(sprintf($self->url_format(), $accession));
  my @versions = map { EmblVersion->new(%{$_}) } @{$json->{versions}};
  return \@versions;
}

sub get_embl {
  my ($self, $embl_version) = @_;
  confess "No EmblVersion object given" unless $embl_version;
  return $self->get_text($embl_version->text());
}

sub get_fasta {
  my ($self, $embl_version) = @_;
  confess "No EmblVersion object given" unless $embl_version;
  confess "Cannot get FASTA because the EmblVersion has no FASTA url" unless $embl_version->has_fasta();
  return $self->get_text($embl_version->fasta());
}

__PACKAGE__->meta->make_immutable;

1;
