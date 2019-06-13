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

package Log::Loader;

use Moose;
with 'Log::Base';

has 'completed'  =>  ( isa => 'Bool', is => 'ro', required => 1 );
has 'path'      =>  ( isa => 'Path::Tiny', is => 'ro', required => 1 );

sub headers {
  return [qw/timestamp completed trunc512 md5 path/];
}

sub columns {
  my ($self) = @_;
  my $metadata = $self->metadata();
  return [
    $self->timestamp()->ymdhms(),
    $self->completed(),
    $metadata->trunc512(),
    $metadata->md5(),
    $self->path(),
  ];
}

__PACKAGE__->meta->make_immutable;

1;
