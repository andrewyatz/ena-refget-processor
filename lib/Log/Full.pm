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

package Log::Full;

use Moose;
use DateTime::Tiny;

with 'Log::Base';

has 'ena_type'  =>  ( isa => 'Str', is => 'ro', required => 1 );

sub headers {
  return [qw/timestamp trunc512 md5 length sha512 trunc512_base64 insdc ena_type/];
}

sub columns {
  my ($self) = @_;
  my $metadata = $self->metadata();
  return [
    $self->timestamp()->ymdhms(),
    $metadata->trunc512(),
    $metadata->md5(),
    $metadata->length(),
    $metadata->sha512(),
    $metadata->trunc512_base64(),
    $metadata->versioned_accession(),
    $self->ena_type(),
  ];
}

__PACKAGE__->meta->make_immutable;

1;
