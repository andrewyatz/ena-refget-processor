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

package ProcessSeq;

use Moose;

with 'BaseProcess';

has 'seq' =>  ( isa => 'Bio::PrimarySeqI', is => 'ro', required => 1 );
has 'metadata' =>  ( isa => 'Metadata', is => 'ro', required => 1 );

sub process {
  my ($self) = @_;
  my $metadata = $self->metadata();
  my $target_dir = $self->get_target_dir($metadata);
  my $target = $target_dir->child($metadata->trunc512());
  $target->spew($self->seq()->seq());
  $self->check_content($target, $metadata->md5());
  return $target;
}

__PACKAGE__->meta->make_immutable;

1;
