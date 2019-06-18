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

package Log::NoFasta;

use Moose;
with 'Log::Base';

sub headers {
  return [qw/timestamp accession version/];
}

sub columns {
  my ($self) = @_;
  my $m = $self->metadata();
  return [
    $self->timestamp()->ymdhms(),
    $m->accession(),
    $m->version(),
  ];
}

__PACKAGE__->meta->make_immutable;

1;
